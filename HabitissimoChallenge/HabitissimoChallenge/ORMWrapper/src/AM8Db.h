//
//  AM8Db.h
//  ORMWrapper
//
//  Created by Eduard Borras Ruiz on 1/12/2020.
//

#import <UIKit/UIKit.h>


#import <FMDB/FMDatabase.h>
#import <FMDB/FMDatabaseAdditions.h>
#import <FMDB/FMDatabaseQueue.h>
//#import "FMDatabase.h"
//#import "FMDatabaseAdditions.h"
#import "FMResultSet+Additions.h"
#import "AM8ORMEntity.h"
#import "AM8SqlGenerator.h"
#import "AM8DbPropertyCache.h"
#import "AM8BaseRuntimeSupport.h"
#import "AM8DbEntityCache.h"
#import "AM8DbSQLCache.h"
#import "AM8NSExceptionDb.h"


@class AM8DbSQLCache;
@class AM8DbEntityCache;
@class AM8ORMEntity;

//Level for recursion between ONE_TO_MANY and MANY_TO_ONE
//sample
//        Contacts
//                Int id;
//                Account *account;
//
//        Account
//                NSArray *contacts;

static NSString * const _dbError       = @"DBError";
static NSString * const _dateFormat1   = @"yyyy-MM-dd'T'HH:mm:ss";
static NSString * const _dateFormat2   = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
static NSString * const _time          = @"T00:00:00";
static NSString * const _cero          = @"0";
static NSString * const _one           = @"1";
static NSString * const _subguionTable_s           = @"%@%@%@";
static NSString * const _subguionTable = @"%@%@";
static NSString * const _typeInteger   = @"I";
static NSString * const _selectFromWhere   = @"SELECT * FROM [%@] WHERE %@ = %@";
static NSString * const _selectFromWhereId   = @"SELECT * FROM [%@] WHERE id = %@";
static NSString * const _keyStack     = @"%@|%@|%@|%@";
static NSString * const _db           = @"Db_";
static NSString * const _selectFromWhere11           = @"SELECT * FROM [%@] WHERE 1 = 1 ";
static NSString * const _range = @" LIMIT %@ OFFSET %@ ";
static NSString * const _selectCount = @"SELECT count(1) FROM [%@]";
static NSString * const _conditionSameValue = @" and %@ = %@ ";
static NSString * const _emptyString   = @"";
static NSString * const _subguion      = @"_";
static NSString * const _subguion_s    = @"_s";


@interface AM8Db : NSObject {
}

/**
 *  Wrapper for SQLite low level implementation
 */
@property (strong, nonatomic) FMDatabase *theDb;

/**
 *  Caching entities to resolve relations. By default is Permitted
 */
@property (nonatomic) BOOL isEntityCachingPermitted;

/**
 *  Caching SQL statements. By default is Permitted
 */
@property (nonatomic) BOOL isSQLCachingPermitted;
@property (strong, nonatomic) AM8DbEntityCache *entityCache;
@property (strong, nonatomic) AM8DbSQLCache *SQLCache;

@property (nonatomic) NSInteger entityCacheLimit;
@property (nonatomic) NSInteger SQLCacheLimit;

/**
 *  Init Database file.
 *
 *  @param path                       path where database is allocated.
 *
 *  @return Database (AM8Db instance)
 */
-(id)initWithName:(NSString *)path;

/**
 *  Init Database file.
 *
 *  @param path                       path where database is allocated.
 *  @param maxDeepLevel               max number of relations to resolve in SQL.
 *  @param maximCascadeRecursiveLevel max number of reflexive relations to resolve for entity.
 *
 *  @return Database (AM8Db instance)
 */
-(id)initWithName:(NSString *)path
     maxDeepLevel:(NSUInteger)maxDeepLevel
maximCascadeRecursiveLevel:(NSUInteger)maximCascadeRecursiveLevel;


+(BOOL)dbIsSet;

/**
 *  Get an instance of the currentdb by defaultname.
 *
 *  @return Instance of Db.
 */
+(AM8Db *)currentDb;

/**
 *  Get an instance of the currentdb by name.
 *
 *  @return Instance of Db.
 */
+(AM8Db *)currentDb:(NSString *)name;

/**
 *  Begins SQL transaction.
 *
 *  @return ¿Transaction was initialized?
 */
-(BOOL)beginTransaction;

/**
 *  RollBack SQL transaction.
 */
-(void)rollbackTransaction;

/**
 *  Begins SQL transaction.
 *
 *  @return ¿Transaction was commited?
 */
-(BOOL)commitTransaction;

/**
 *  Check if Database is in the middle of transaction.
 *
 *  @return ¿Is Database in the middle of transaction?
 */
-(BOOL)inTransaction;

/**
 *  Creates Database file in "self.Path".
 *  @exception Database already exists. Database cannot be created. AM8NSExceptionDb is fired.
 */
-(void)createDb;

/**
 *  Open Database
 *  @exception Database already exists. Database cannot be created. AM8NSExceptionDb is fired.
 */
-(void)openDb;

/**
 *  Close Database. Cache is cleared.
 */
-(void)closeDataBase;

/**
 *  Check if database exists.
 *  @exception If path is not informed an AM8NSExceptionDb is fired.
 *
 *  @return ¿Exists DB?
 */
-(BOOL)existDb;

/**
 *  Check if database exists in path specified.
 *
 *  @param dbPath path.
 *
 *  @return ¿Exists DB?
 */
+(BOOL)existDb:(NSString *)dbPath;

/**
 *  Check the last error happened in Database
 *  @exception If Db had error AM8NSExceptionDb is fired.
 */
-(void)checkError;

/**
 *  Save List of entities
 *
 *  @param list The entities to Save
 *
 *  @return The array of entities that were saved
 */
-(NSArray *)saveList:(NSArray *)list;


/**
 *  Delete List of entities
 *
 *  @param list The entities to Delete
 *
 *  @return The array of deleted entities.
 */
-(NSArray *)deleteList:(NSArray *)list;


/**
 *  Update entity.
 *
 *  @param entity Entity to update.
 *
 *  @return ¬¨√∏was the entity updated?
 */
-(BOOL)update:(AM8ORMEntity *)entity;


/**
 *  Save entity.
 *
 *  @param entity Entity to save.
 *
 *  @return ¿was the entity saved?
 */
-(BOOL)save:(AM8ORMEntity *)entity;


/**
 *  Remove entity.
 *
 *  @param entity Entity to remove.
 *
 *  @return ¿was the entity removed?
 */
-(BOOL)remove:(AM8ORMEntity *)entity;

/**
 * Get entity from database by 'id'. If entity is cached, is not retrieved directly from database.
 * The entities & lookup (foreignkey) references are cached.
 * It is equivalent to:     "SELECT FIRST * FROM [%@] WHERE id = %d"
 *
 *  @param sql SQL Select to execute.
 *  @param cls Entity class to retrieve. It is equivalent to the tablename.
 *
 *  @return Entity retrieved from Database.
 */
-(id)findFirst:(NSString *)sql theClass:(Class)cls;

/**
 * Get entity from database by 'id'. If entity is cached, is not retrieved directly from database.
 * The entities & lookup (foreignkey) references are cached.
 * It is equivalent to:     "SELECT * FROM [%@] WHERE id = %d"
 * @param   cls         - (Class)       Entity to retrieve. It is equivalent to the tablename.
 * @param   theId       - (NSUInteger)  'Id' is the primary key for all tables.
 * @return  (id)        - Entity retrieved from Database.
 **/
-(id)findById:(Class)cls
        theId:(NSUInteger)theId;


/**
 *  Get entity from database by 'id'. The entities & lookup (foreignkey) references will not be retrieved from cache. It is equivalent to:     "SELECT * FROM [%@] WHERE id = %d"
 *
 *  @param class     Entity to retrieve. It is equivalent to the tablename.
 *  @param theId     'Id' is the primary key for all tables.
 *  @param applyLazy ¿Can Lazy property applied?
 *
 *  @return entity found
 */
-(id)findByIdNotCached:(Class)class
                 theId:(NSUInteger)theId
             applyLazy:(BOOL)applyLazy;




/**
 *  Find Entity by field & value.
 *
 *  @param cls       Class Object to find (tableName)
 *  @param fieldName FieldName of condition
 *  @param value     Value to compare.
 *
 *  @return entity found (instance of cls)
 */
-(id)findByFieldAndValue:(Class)cls
               fieldName:(NSString *)fieldName
                   value:(id)value;


/**
 *  Load SQL Select sentence. Cursor is returned.
 *
 *  @param sql SQL to execute.
 *
 *  @return Cursor to fetch data.
 */
-(FMResultSet *)load:(NSString *)sql;


/**
 *  Populate the 'list' with records from 'sql'.
 *
 *  @param sql          SQL sentence to execute.
 *  @param list         list to populate with records gotten from SQL sentence.
 *  @param cls          Entity to retrieve. It is equivalent to the tablename.
 *  @param getFromCache records ¿can be retrieved from cache?.
 *  @param applyLazy    ¿Can Lazy property applied?
 *  @param level        relation deep.
 */
-(void)recordSet:(NSString *)sql
            list:(NSMutableArray **)list
             cls:(Class)cls
    getFromCache:(BOOL)getFromCache
       applyLazy:(BOOL)applyLazy;;


/**
 *  Find One Entity by Criteria (NSDictionary)
 *
 *  @param cls             Class Object to find (tableName)
 *  @param fieldsAndValues NSDictionary with fieldNames & values
 *
 *  @return Entity found.
 */
-(id)findByCriteria:(Class)cls
    fieldsAndValues:(NSDictionary *)fieldsAndValues;

/**
 *  Find Entities by Criteria (NSDictionary)
 *
 *  @param cls             Class Object to find (tableName)
 *  @param fieldsAndValues NSDictionary with fieldNames & values
 *
 *  @return array of entities.
 */
-(NSArray *)findListByCriteria:(Class)cls
               fieldsAndValues:(NSDictionary *)fieldsAndValues;

/**
 *  Find Entities by Field & Value.
 *
 *  @param cls       Class Object to find (tableName)
 *  @param fieldName FieldName of condition
 *  @param value     Value to compare.
 *
 *  @return Entities found
 */
-(NSArray *)findListByFieldAndValue:(Class)cls
                          fieldName:(NSString *)fieldName
                              value:(id)value;

/**
 *  Find Entities by criteria.
 *
 *  @param cls             Class Object to find (tableName)
 *  @param fieldsAndValues NSDictionary with fieldNames & values
 *  @param range           Range to paginate.
 *
 *  @return array of entities matching criteria.
 */
-(NSArray *)findListByCriteria:(Class)cls
               fieldsAndValues:(NSDictionary *)fieldsAndValues
                         range:(NSRange)range;

/**
 *  Find Entities by field & value.
 *
 *  @param cls       Class Object to find (tableName)
 *  @param fieldName FieldName of condition
 *  @param value     Value to compare.
 *  @param range     Range to paginate.
 *
 *  @return array of entities matching criteria.
 */
-(NSArray *)findListByFieldAndValue:(Class)cls
                          fieldName:(NSString *)fieldName
                              value:(id)value
                              range:(NSRange)range;

/**
 *  Find entities by SQL statement (SELECT).
 *
 *  @param sql SQL statement (SELECT).
 *  @param cls Class to retrieve (TableName).
 *
 *  @return Array of entities found.
 */
-(NSArray *)findAndFill:(NSString *)sql
               theClass:(Class)cls;

/**
 *  Find entities by SQL statement (SELECT).
 *
 *  @param sql       SQL statement (SELECT).
 *  @param cls       Class to retrieve (TableName).
 *  @param fromCache records ¿can be retrieved from cache?.
 *
 *  @return Array of entities found.
 */
-(NSArray *)findAndFill:(NSString *)sql
               theClass:(Class)cls
           getFromCache:(BOOL)fromCache;

-(NSMutableArray *)findAndFillDict:(NSString *)sql
                            fields:(NSArray *)fields
                          theClass:(Class)cls;

/**
 *  Execute SQL (INSERT or UPDATE)
 *
 *  @param sql SQL to execute
 */
-(void)execute:(NSString *)sql;

/**
 *  Last Id inserted in Db.
 *
 *  @return last Id inserted.
 */
-(NSInteger)lastRowId;

/**
 *  Find all entities.
 *
 *  @param cls   Class to retrieve (TableName).
 *  @param range Range to paginate.
 *
 *  @return Array of entities found.
 */
-(NSArray *)findAll:(Class)cls
              range:(NSRange)range
;

/**
 *  Find entities by criteria and ordered.
 *
 *  @param cls       Class to retrieve (TableName).
 *  @param whereList Criteria to flter.
 *  @param orderList Order to apply.
 *  @param range     Range to paginate.
 *
 *  @return Array of entities found.
 */
-(NSArray *)findAll:(Class)cls
          whereList:(NSArray *)whereList
          orderList:(NSArray *)orderList
              range:(NSRange)range
;


/**
 *  <#Description#>
 *
 *  @param sql <#sql description#>
 *
 *  @return <#return value description#>
 */
-(NSInteger)intValue:(NSString *)sql;

/**
 *  Get count for a entity
 *
 *  @param tableName Name of entity.
 *
 *  @return Number of entities in tablename.
 */
-(NSInteger)count:(NSString *)tableName;

/**
 *  Check if column exists in TableName of Entity.
 *
 *  @param columnName Column name.
 *  @param tableName  Table name.
 *
 *  @return TRUE if column exists in tablename
 */
-(BOOL)columnExists:(NSString*)columnName
    inTableWithName:(NSString*)tableName;

/**
 *  Get Db columns of entity (tablename)
 *
 *  @param entity Tablename
 *
 *  @return Set with Columns
 */
-(NSMutableSet *)getDbColumns:(AM8ORMEntity *)entity;

#pragma mark Pragma functions
-(NSInteger)userDatabaseVersion;

/**
 *  Clear all caches.
 */
-(void)clearCache;

/**
 *  Clear cache for entity class.
 *
 *  @param entity Entity object name.
 */
-(void)clearCache:(NSString *)entity;

/**
 *  <#Description#>
 *
 *  @param newEntity <#newEntity description#>
 *  @param oldEntity <#oldEntity description#>
 *  @param isNew     <#isNew description#>
 */
-(void)refreshLookupInOneToMany:(AM8ORMEntity *)newEntity
                      oldEntity:(AM8ORMEntity *)oldEntity
                          isNew:(BOOL)isNew;

/**
 *  Update the entity cached.
 *
 *  @param entity Entity
 */
-(void)updateCachedEntity:(AM8ORMEntity *)entity;

/**
 * Execute a SQL sentence and return values as a dictionary
 */
-(NSArray *)loadAsDictArray:(NSString *)sql;

- (void) addColumn:(NSString*) column
   inTableWithName:(NSString*) tableName
          withType:(NSString*) type;

- (void) addColumn:(NSString*) column
   inTableWithName:(NSString*) tableName
          withType:(NSString*) type
           notNull:(BOOL) notNull
      defaultValue:(NSString*) defaultValue;

@end
