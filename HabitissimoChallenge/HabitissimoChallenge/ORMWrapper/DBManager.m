//
//  DBManager.m
//  HabitissimoChallenge
//
//  Created by Eduard Borras Ruiz on 23/04/2021.
//

#import "DBManager.h"
#import "AM8TableCounter.h"
#import "AM8DbPool.h"

#define MAXENTITYCACHESIZE  10000
#define MAXSQLCACHESIZE  75


static NSInteger const DB_VERSION = 1;
static NSString* const DB_CREATED_KEY = @"DBCreated";
static NSString* const DB_CURRENT_VERSION_KEY = @"DBCurrentVersion";

static NSString * const  k_DEFAULT_DB              = @"defaultDB";
static NSString * const  k_DB                      = @"habitissimoDB.db";

@implementation DBManager


// We have 2 tables for every updateable entity.
// "table" & "table_s" (saving modifications of "table").
// There is a view to join this 2 tables.
// We cannot repeat Id's

//  table           table_s
//  Id              Ids
//  -----           -------
//  1
//                  2
//  3
//                  4
//                  5
//                  6
//  7

- (id)init {
    if ((self = [super init])) {
        self.entityCacheLimit = MAXENTITYCACHESIZE;
        self.SQLCacheLimit = MAXSQLCACHESIZE;
        self.entityCache = [[AM8DbEntityCache alloc] initWithLimit:self.entityCacheLimit];
        self.SQLCache    = [[AM8DbSQLCache alloc] initWithLimit:self.SQLCacheLimit];
    }
	
	return self;
}

-(BOOL)save:(AM8ORMEntity *)entity {
    BOOL isNew;
    AM8ORMEntity *oldEntity=nil;
    
    if (!entity)
        return NO;
    
	[self openDb];
	if ((isNew = [entity _am8IsNew])) {
            //Asigning custom Id.
        entity.Id = [entity nextRowId];
	} else {
        oldEntity = [self findByIdNotCached:[entity class] theId:entity.Id  applyLazy:NO];
    }
    
	if (![entity isValid]) {
		return NO;
	}
	
	if (![entity beforeSave]) {
		[self checkError];
		
		return NO;
	}
    
    //Populating dynamic fields
    [entity refreshDynamicJSONField];
    [entity refreshDictionary];
    
    /*NSArray *sqlArray = [entity getUpdateSqlArray];
     [self executeUpdate:sqlArray[0] withParameterDictionary:sqlArray[1]];
     sqlArray = nil;*/
    
    NSString *sql = [entity getUpdateSql];
    
    if ([NSStringFromClass([entity class]) isEqualToString:@"SCKVisitUser"]) {
        //sql = [[SCKVisitUserDao sharedInstance] getSQLToSave:entity];
    }
    
    [self execute:sql];
    
    [self checkError];
    
    if (![entity isKindOfClass:[_AM8SynchroORMEntity  class]]){
        if ([entity _am8IsNew]) {
            entity.Id = [self lastRowId];
        }
    }
    
	
    NSDictionary *listsToSaveInCascade;
    if ((listsToSaveInCascade = [entity getChildsToSaveInCascade])){
        for (NSString *fieldName in [listsToSaveInCascade allKeys]) {
            NSArray *parts = [listsToSaveInCascade[fieldName] componentsSeparatedByString:_comma];
//          NSString *fieldType = [parts objectAtIndex:0];

//          NSString *fieldReferenceName = [[parts objectAtIndex:1] stringByAppendingString:@"Id"];
            NSString *fieldReferenceName = [parts objectAtIndex:1];
            
            NSArray *childs = [entity valueForKey:fieldName];
            for (AM8ORMEntity *child in childs){
                [child setValue:entity forKey:fieldReferenceName];
                if (![self save:child]) {
                    return NO;
                }
            }
        }
    }
    
    
	if (![entity afterSave]) {
		[self checkError];
		return NO;
	}

    [self updateCachedEntity:entity];
    [self refreshLookupInOneToMany:entity
                         oldEntity:oldEntity
                             isNew:isNew];
    
    
    return YES;
}

- (BOOL)remove:(AM8ORMEntity *)entity {
    return [super remove:entity];
}

-(BOOL)update:(AM8ORMEntity *)entity {
    return [super update:entity];
}

#pragma mark - Create Tables

- (void)createTables {
    
    [self createBudgetTable];
    
    [self createForNewVersions];
}

#pragma mark - Full Recovery DB

+(void)fullRecoveryDB {
    // Comprobar si es la primera ejecución
    if ([[AM8DbPool sharedInstance] existConnection:k_DEFAULT_DB]){
        [(DBManager *)[[AM8DbPool sharedInstance] getConnection:k_DEFAULT_DB] clearCache];
        [(DBManager *)[[AM8DbPool sharedInstance] getConnection:k_DEFAULT_DB] closeDataBase];
    }
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    // Creamos (o no) la BBDD
    NSString *createdBDKey = DB_CREATED_KEY;
    [settings setBool:NO forKey:createdBDKey];
    [settings synchronize];
    
    // Si marcamos la base de datos como no creada, marcamos la current version como 0.
    [settings setInteger:0 forKey:DB_CURRENT_VERSION_KEY];
    [settings synchronize];
    
    NSString *createdKeychainKey = @"KeychainCreated";
    [settings setBool:FALSE forKey:createdKeychainKey];
    [settings synchronize];
    
    [self configureDb];
}


#pragma mark -
#pragma mark ConfigureDb Methods

+(NSString *)getDbPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *lpath = [documentsDirectory stringByAppendingPathComponent:k_DB];
    
    return lpath;
}

+(void)createDataBase {
    NSString *lpath = [self getDbPath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:lpath]) {
        [[NSFileManager defaultManager] removeItemAtPath:lpath error:nil];
    }
    
    [[AM8DbPool sharedInstance] addConnection:k_DEFAULT_DB
                                     class:[DBManager class]
                                      path:lpath
                                 maxDeepLevel:0
                   maximCascadeRecursiveLevel:2];
    [[DBManager currentDb:k_DEFAULT_DB] createDb];
    // Set-up code here.
    
    
    //Create schema
	DBManager *db = (DBManager *)[DBManager currentDb:k_DEFAULT_DB];
    [db createTables];
    [(DBManager *)[[AM8DbPool sharedInstance] getConnection:k_DEFAULT_DB] closeDataBase];
}

+ (void)configureDb {
    // Comprobar si es la primera ejecuci√≥n
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    // Creamos (o no) la BBDD
    NSString *createdBDKey = DB_CREATED_KEY;
    if (![AM8Db existDb:[DBManager getDbPath]])
    {
        [DBManager createDataBase];
        
        [settings setBool:TRUE forKey:createdBDKey];
        [settings setInteger:DB_VERSION forKey:DB_CURRENT_VERSION_KEY];
        [settings synchronize];
    }
    
    // Crear la conexi√≥n con BBDD
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:k_DB];
    [[AM8DbPool sharedInstance] addConnection:k_DEFAULT_DB
                                        class:[DBManager class]
                                         path:path
                                 maxDeepLevel:0
                   maximCascadeRecursiveLevel:2];
#ifdef DEBUG
    
    // Simulate there is no version in userDefaults:
        [settings setInteger:0 forKey:DB_CURRENT_VERSION_KEY];
       [settings synchronize];
#endif
    
    
    [self migrateDBIfNeeded];
}


/*
 * This function update the database from older app-database versions to last DB_VERSION.
 *
 *  It will do it incrementally, because using this way, same method of migration can be used to
 *  update from different versions of the app to last one.
 */
+ (void)migrateDBIfNeeded {
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    NSInteger current_version = [settings integerForKey:DB_CURRENT_VERSION_KEY];
    
    // We put that if to avoid the execution of unnecessary code ( and more expensive) if current version is the same as correct version.
    // if current_version = 0, key has not been initialized (app prior to db versioning) or is a full recovery.
    if(current_version < DB_VERSION){
        
        DBManager *db = (DBManager *)[DBManager currentDb:k_DEFAULT_DB];
        
        while(current_version < DB_VERSION){
            //Must migrate from current version of app's db
            switch (current_version) {
                default:
                    break;
            }
            current_version++;
        }
        //Force to clear cache
        [db clearCache];
        [(DBManager *)[[AM8DbPool sharedInstance] getConnection:k_DEFAULT_DB] closeDataBase];
        [settings setInteger:DB_VERSION forKey:DB_CURRENT_VERSION_KEY];
        [settings synchronize];
    }
}




#pragma mark - Versions updates

-(void)createForNewVersions{
    
    //TODO: Call methods for new versions

}


- (void) addIndex:(NSString*)tablename forColumn:(NSString*)column {
    NSString* sql = [NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS idx_%@_%@ ON %@ (%@)", tablename, column, tablename, column];
        
    [self execute:sql];
}

#pragma mark - Update methods

//TODO: Implement methods for new versions

#pragma mark - Tables

-(void)createBudgetTable {
    
    [self execute:@"CREATE TABLE IF NOT EXISTS Budget"
     @"("
     @"Id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE,"
     @"descriptionBudget VARCHAR(200) NULL,"
     @"categoryName VARCHAR(200) NULL,"
     @"categoryId VARCHAR(200) NULL,"
     @"subCategoryName VARCHAR(200) NULL,"
     @"name VARCHAR(200) NULL,"
     @"email VARCHAR(200) NULL,"
     @"phoneNumber VARCHAR(200) NULL,"
     @"locationName VARCHAR(200) NULL"
     @")"];
    
}

@end
