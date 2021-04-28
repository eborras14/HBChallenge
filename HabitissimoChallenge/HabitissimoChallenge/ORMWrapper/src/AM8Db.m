//
//  Db.m
//  ORMWrapper
//
//  Created by Eduard Borras Ruiz on 1/12/2020.
//

#import "AM8Db.h"
#import "AM8DbPool.h"
#import "AM8NSExceptionDb.h"
#import "NSDate+DateFunctions.h"
#import "NSLocale+Neutral.h"
#import "NSString+Concatenate.h"
#import "NSArray+BlocksKit.h"


@interface AM8Db ()
@property (strong, nonatomic) NSString *path;
@property (nonatomic) BOOL isOpen;
@property (nonatomic) NSUInteger maxDeepLevel;
@property (nonatomic) NSUInteger maximCascadeRecursiveLevel;
@property (strong, nonatomic) NSMutableDictionary *sqlStack;
@property (strong, nonatomic) FMDatabaseQueue *sqlFMQueue;
@end

@implementation AM8Db

- (id)init {
    if ((self = [super init])) {
        self.path = @"";
        self.isOpen = NO;
        self.entityCache = [[AM8DbEntityCache alloc] initWithLimit:self.entityCacheLimit];
        self.SQLCache = [[AM8DbSQLCache alloc] initWithLimit:self.SQLCacheLimit];
        self.isEntityCachingPermitted = YES;
        self.isSQLCachingPermitted = YES;
        self.sqlStack = [[NSMutableDictionary alloc] init];
        self.maxDeepLevel = 0;
        self.maximCascadeRecursiveLevel = 3;
    }
    
    return self;
}

- (id)initWithName:(NSString *)path{
    if ((self = [self init])) {
        _path = [path copy];
        self.isOpen = NO;
    }
    
    return self;
}

- (id)initWithName:(NSString *)path
      maxDeepLevel:(NSUInteger)maxDeepLevel
maximCascadeRecursiveLevel:(NSUInteger)maximCascadeRecursiveLevel
{
    if ((self = [self initWithName:path])) {
        _path = [path copy];
        self.isOpen = NO;
        self.maxDeepLevel = maxDeepLevel;
        self.maximCascadeRecursiveLevel = maximCascadeRecursiveLevel;
    }
    
    return self;
}

- (void)dealloc
{
    [self closeDataBase];
}

- (void)clearCache {
    @autoreleasepool {
        [self.entityCache clearCache];
        self.entityCache = nil;
        self.entityCache = [[AM8DbEntityCache alloc] initWithLimit:self.entityCacheLimit];
        
        [self.SQLCache clearCache];
        self.SQLCache = nil;
        self.SQLCache = [[AM8DbSQLCache alloc] initWithLimit:self.SQLCacheLimit];
        
        [self.theDb clearCachedStatements];
    }
}

-(void)clearCache:(NSString *)entity {
    [self.entityCache clearCache:entity];
    [self.SQLCache clearCache:entity];
    [self.theDb clearCachedStatements];
}

+(BOOL)dbIsSet {
    return [[AM8DbPool sharedInstance] existConnection:[[AM8DbPool sharedInstance] defaultPoolName]];
}

+(id)currentDb {
    return [self currentDb:[[AM8DbPool sharedInstance] defaultPoolName]];
}

+(id)currentDb: (NSString *)name {
    return [[AM8DbPool sharedInstance] getConnection: name];
}

#pragma mark DbAdmin
-(void)createDb{
    if ([self existDb]) {
        NSException *e = [NSException
                          exceptionWithName:_dbError
                          reason:[NSString stringWithFormat:@"The database file %@ already exist.",self.path]
                          userInfo:nil];
        AM8NSExceptionDb *f = [[AM8NSExceptionDb alloc] initWithException:e];
        @throw f;
    }
    
    self.theDb = [FMDatabase databaseWithPath: self.path];
    self.sqlFMQueue = [FMDatabaseQueue databaseQueueWithPath:self.path];
    
    if (![self.theDb open]) {
        NSException *e = [NSException
                          exceptionWithName:_dbError
                          reason:@"Can't create database."
                          userInfo:nil];
        AM8NSExceptionDb *f = [[AM8NSExceptionDb alloc] initWithException:e];
        @throw f;
    }
    
    //Add File protection to DB
    NSError *error;
    [[NSFileManager defaultManager] setAttributes:[NSDictionary dictionaryWithObject:NSFileProtectionComplete
                                                                              forKey:NSFileProtectionKey]
                                     ofItemAtPath:self.path error:&error];
    
    
    [self.theDb close];
}

-(void)openDb{
    if (!_isOpen) {
        if (![self existDb]) {
            NSString *msg = [NSString stringWithFormat:@"Database file %@ not exist.",self.path];
            NSException *e = [NSException
                              exceptionWithName:_dbError
                              reason:msg
                              userInfo:nil];
            AM8NSExceptionDb *f = [[AM8NSExceptionDb alloc] initWithException:e];
            @throw f;
        }
        
        self.theDb = [FMDatabase databaseWithPath: self.path];
        self.sqlFMQueue = [FMDatabaseQueue databaseQueueWithPath:self.path];
        
        if (![self.theDb open]) {
            [self checkError];
            NSException *e = [NSException
                              exceptionWithName:_dbError
                              reason:@"Can't open database. Unknow reason"
                              userInfo:nil];
            AM8NSExceptionDb *f = [[AM8NSExceptionDb alloc] initWithException:e];
            @throw f;
        }
        
        _isOpen = YES;
        //        Not Working
        //        [self.theDb setShouldCacheStatements:YES];
        
        //Some optimization
        [self execute:@"PRAGMA cache_size = 2000"];
        [self execute:@"PRAGMA foreign_keys = ON"];
        
        NSLog(@"OpenDb: %@",self.path);
    }
}

-(void)closeDataBase{
    if (_isOpen) {
        [self clearCache];
        [self.theDb close];
        self.sqlFMQueue = nil;
        _isOpen = NO;
    }
}

-(BOOL)existDb {
    return [AM8Db existDb:self.path];
}

+(BOOL)existDb:(NSString *)dbPath {
    if (!dbPath) {
        NSException *e = [NSException
                          exceptionWithName:_dbError
                          reason:@"Bad data type."
                          userInfo:nil];
        AM8NSExceptionDb *f = [[AM8NSExceptionDb alloc] initWithException:e];
        @throw f;
    }
    
    return [[NSFileManager defaultManager] fileExistsAtPath: dbPath];
}

-(void)checkError{
    if ([self.theDb hadError]) {
        NSLog(@"Err %d: %@", [self.theDb lastErrorCode], [self.theDb lastErrorMessage]);
        
        NSException *e = [NSException
                          exceptionWithName:_dbError
                          reason:[self.theDb lastErrorMessage]
                          userInfo:nil];
        
        AM8NSExceptionDb *f = [[AM8NSExceptionDb alloc] initWithException:e];
        @throw f;
    }
}


/**
 *  <#Description#>
 *
 *  @param rs           <#rs description#>
 *  @param fieldName    <#fieldName description#>
 *  @param type         <#type description#>
 *  @param fieldType    <#fieldType description#>
 *  @param fatherId     <#fatherId description#>
 *  @param fatherEntity <#fatherEntity description#>
 *  @param level        <#level description#>
 *
 *  @return <#return value description#>
 */
-(id)valueForField:(FMResultSet *)rs
              Name:(NSString *)fieldName
              Type:(NSString *)type
         fieldType:(FieldType)fieldType
          fatherId:(NSNumber*)fatherId
      fatherEntity:(NSString *)fatherEntity
    recursionLevel:(int)level    {
    
    id fieldValue = nil;
    NSString *className;
    NSString *dateString;
    
    switch (fieldType) {
        case FIELDTYPE_CHAR:
        case FIELDTYPE_STRING:{
            fieldValue = [rs stringForColumn:fieldName];
        }
            break;
        case FIELDTYPE_DOUBLE:{
            fieldValue = [NSNumber numberWithDouble:[rs doubleForColumn:fieldName]];
        }
            break;
        case FIELDTYPE_FLOAT:{
            fieldValue = [NSNumber numberWithDouble:[rs doubleForColumn:fieldName]];
        }
            break;
        case FIELDTYPE_INTEGER:{
            fieldValue = @([rs longForColumn:fieldName]);
        }
            break;
        case FIELDTYPE_LONG:{
            fieldValue = @([rs longForColumn:fieldName]);
        }
            break;
            
        case FIELDTYPE_NUMBER:{
            fieldValue = [NSNumber numberWithDouble:[rs doubleForColumn:fieldName]];
            if ([fieldValue isEqual:[NSNull null]]){
                fieldValue = nil;
            }
        }
            break;
        case FIELDTYPE_BOOLEAN:{
            fieldValue = [rs stringForColumn:fieldName];
            //Is really a boolean?
            if ([fieldValue isEqualToString:_cero] || [fieldValue isEqualToString:_one]) {
                fieldValue = @([fieldValue intValue]);
            } else {
                fieldValue = @(0);
            }
        }
            break;
        case FIELDTYPE_DATETIME:{
            dateString = [rs stringForColumn:fieldName];
            
            NSString *dateFormat = _dateFormat1;
            if ([dateString length] == 10){
                dateString = [NSString concatenateStrings:dateString,_time,nil];
            }
            if ([dateString length] > 20){
                dateFormat = _dateFormat2;
            }
            
            if (dateString) {
                fieldValue  = [NSDate dateFromISOString:dateString   dateFormat:dateFormat];
            }
            else
            {
                fieldValue = nil;
            }
        }
            break;
        case FIELDTYPE_DECIMAL:{
            fieldValue = [rs stringForColumn :fieldName];
            if (fieldValue) {
                fieldValue = [NSDecimalNumber decimalNumberWithString:fieldValue];
            } else {
                fieldValue = [NSDecimalNumber zero];
            }
        }
            break;
        case FIELDTYPE_OBJECT:{
            className = [type substringWithRange:NSMakeRange(2, [type length]-3)];
            Class theClass = NSClassFromString(className);
            
            if (classDescendsFrom(theClass, [AM8ORMEntity class])) {
                //Load the record...
                NSInteger Id = [rs intForColumn:[NSString concatenateStrings:fieldName,_suffixID,nil]];
                if (!Id) {
                    fieldValue = nil;
                } else {
                    level++;
                    fieldValue = [self findByIdStacking:theClass
                                                  theId:Id
                                               fatherId:fatherId
                                     fieldReferenceName:fieldName
                                           fatherEntity:(NSString *)fatherEntity
                                           inverseField:nil
                                           inverseValue:nil
                                         recursionLevel:level];
                    level--;
                }
            }
        }
        case FIELDTYPE_ARRAY:
        case FIELDTYPE_MUTABLEARRAY:
        default:
            break;
    }
    
    
    className = nil;
    dateString = nil;
    
    return fieldValue;
}

#pragma mark Transactions
-(BOOL)beginTransaction {
    if (![self inTransaction]) {
        return [self.theDb beginTransaction];
    }
    return NO;
}

-(void)rollbackTransaction {
    if ([self inTransaction]) {
        [self.theDb rollback];
    }
}

-(BOOL)commitTransaction {
    if ([self inTransaction]) {
        return [self.theDb commit];
    }
    return NO;
}

-(BOOL)inTransaction {
    [self openDb];
    return [self.theDb isInTransaction];
}

#pragma mark Save & retrieval
-(NSArray *)saveList: (NSArray *)list {
    [self beginTransaction];
    NSMutableArray *errors  = [NSMutableArray array];
    
    @try {
        [list enumerateObjectsUsingBlock:^(AM8ORMEntity *record, NSUInteger index, BOOL *stop) {
            @autoreleasepool {
                if (![self save:record]) {
                    [errors addObject:record ? [record errorsAsString] : @"nil"];
                    [self rollbackTransaction];
                    *stop = YES;
                }
            }
        }];
    }
    @catch (NSException * e) {
        [self rollbackTransaction];
        
        AM8NSExceptionDb *f = [[AM8NSExceptionDb alloc] initWithException:e];
        @throw f;
    }
    @finally {
        [self commitTransaction];
        return errors;
    }
}

-(NSArray *)deleteList: (NSArray *)list {
    [self beginTransaction];
    NSMutableArray *errors  = [NSMutableArray array];
    
    @try {
        [list enumerateObjectsUsingBlock:^(AM8ORMEntity *record, NSUInteger index, BOOL *stop) {
            @autoreleasepool {
                if (![self remove:record]) {
                    [errors addObject:[record errorsAsString]];
                    [self rollbackTransaction];
                    *stop = YES;
                }
            }
        }];
    }
    @catch (NSException * e) {
        [self rollbackTransaction];
        
        AM8NSExceptionDb *f = [[AM8NSExceptionDb alloc] initWithException:e];
        @throw f;
    }
    @finally {
        [self commitTransaction];
        return errors;
    }
}

-(void)updateCachedEntity:(AM8ORMEntity *)entity {
    if (!_isEntityCachingPermitted) return;
    if (!entity.Id) return;
    AM8ORMEntity *cachedEntity = [self.entityCache getEntity:[entity class]
                                                          Id:entity.Id];
    if (cachedEntity){
        [[[entity cachedProperties] allKeys] enumerateObjectsUsingBlock:^(NSString * fieldName, NSUInteger index, BOOL *stop) {
            @autoreleasepool {
                [cachedEntity  setValue:[entity valueForKey:fieldName]
                                 forKey:fieldName];
            }
        }];
    }
}

/**
 *  <#Description#>
 *
 *  @param entity <#entity description#>
 */
-(void)deleteCachedEntity:(AM8ORMEntity *)entity {
    if (!entity) return;
    [self.SQLCache clearCache:[entity tableName]];
    [self.theDb clearCachedStatements];
    
    [self.entityCache removeEntity:[entity class] Id:entity.Id];
    [self.entityCache removeEntityByTableName:[NSString stringWithFormat:_subguionTable_s,_subguion,[entity tableName],_subguion_s] Id:entity.Id];
    [self.entityCache removeEntityByTableName:[NSString stringWithFormat:_subguionTable,_subguion,[entity tableName]] Id:entity.Id];
    
    [[[entity lookupOneToManyProperties] allKeys] enumerateObjectsUsingBlock:^(NSString * fieldName, NSUInteger index, BOOL *stop) {
        @autoreleasepool {
            AM8ORMEntity *fieldValue = [entity valueForKey:fieldName];
            if (fieldValue){
                [self deleteCachedEntity:fieldValue];
            }
        }
    }];
}

-(void)refreshLookupInOneToMany:(AM8ORMEntity *)newEntity
                      oldEntity:(AM8ORMEntity *)oldEntity
                          isNew:(BOOL)isNew {
    [self.SQLCache clearCache:[newEntity tableName]];
    [self.theDb clearCachedStatements];
    if (isNew){
        [[[newEntity lookupOneToManyProperties] allKeys] enumerateObjectsUsingBlock:^(NSString * fieldName, NSUInteger index, BOOL *stop) {
            @autoreleasepool {
                AM8ORMEntity *lookUpFromNew = [newEntity valueForKey:fieldName];
                [self deleteCachedEntity:lookUpFromNew];
            }
        }];
    } else {
        [[[newEntity lookupOneToManyProperties] allKeys] enumerateObjectsUsingBlock:^(NSString * fieldName, NSUInteger index, BOOL *stop) {
            @autoreleasepool {
                AM8ORMEntity *lookUpFromNew = [newEntity valueForKey:fieldName];
                AM8ORMEntity *lookUpFromOld = [oldEntity valueForKey:fieldName];
                //            if (lookUpFromNew.Id != lookUpFromOld.Id){
                [self deleteCachedEntity:lookUpFromNew];
                [self deleteCachedEntity:lookUpFromOld];
                //            }
            }
        }];
    }
}

/**
 * Update Entity.
 * @param entity            - (AM8ORMEntity *)  Entity to update.
 * @return (BOOL)           it was updated or not.
 **/
-(BOOL)update:(AM8ORMEntity *)entity {
    
    __block AM8ORMEntity *oldEntity=nil;
    if (!entity)
        return NO;
    
    if ([entity _am8IsNew])
        return NO;
    
    [self openDb];
    if (![entity beforeSave]) {
        //        [self checkError];
        
        return NO;
    }
    
    oldEntity = [self findByIdNotCached:[entity class] theId:entity.Id  applyLazy:NO];
    
    /*
     NSArray *sqlArray = [entity getUpdateSqlArray];
     [self executeUpdate:sqlArray[0] withParameterDictionary:sqlArray[1]];
     */
    NSString *sql = [entity getUpdateSql];
    [self execute:sql];
    
    //	[self checkError];
    
    
    [self updateCachedEntity:entity];
    [self refreshLookupInOneToMany:entity
                         oldEntity:oldEntity
                             isNew:NO];
    
    sql = nil;
    oldEntity = nil;
    return YES;
}

/**
 * Save Entity.
 * @param entity            - (AM8ORMEntity *)  Entity to save.
 * @return (BOOL)           it was saved or not.
 **/
-(BOOL)save:(AM8ORMEntity *)entity {
    __block BOOL isNew;
    __block AM8ORMEntity *oldEntity=nil;
    
    
    if (!entity)
        return NO;
    
    //    if (![entity isValid]) {
    //        return NO;
    //    }
    
    [self openDb];
    if (![entity beforeSave]) {
        //        [self checkError];
        
        return NO;
    }
    
    //Populating dynamic fields
    [entity refreshDynamicJSONField];
    
    if ((isNew = [entity _am8IsNew])) {
        //Asigning custom Id.
        entity.Id = [entity nextRowId];
    } else {
        oldEntity = [self findByIdNotCached:[entity class] theId:entity.Id  applyLazy:NO];
    }
    
    NSDictionary *listOneToOneToSave = [entity getOneToOneToSaveImmediatly];
    
    [[listOneToOneToSave allKeys] enumerateObjectsUsingBlock:^(NSString * oneToOneReferenceFieldName, NSUInteger index, BOOL *stop) {

        @autoreleasepool {
            AM8ORMEntity *oneToOne = [entity valueForKey:oneToOneReferenceFieldName];
            if (!oneToOne) return;
            
            NSString *oneToOneReferenceFieldNameChild = listOneToOneToSave[oneToOneReferenceFieldName];
            if (![oneToOneReferenceFieldNameChild isEqualToString:_emptyString]) {
                [oneToOne setValue:nil forKey:oneToOneReferenceFieldNameChild];
            }
            [self save:oneToOne];
            [entity setValue:oneToOne forKey:oneToOneReferenceFieldName];
        }
    }];
    
    /*NSArray *sqlArray = [entity getUpdateSqlArray];
     [self executeUpdate:sqlArray[0] withParameterDictionary:sqlArray[1]];*/
    NSString *sql = [entity getUpdateSql];
    [self execute:sql];
    
    //	[self checkError];
    
    //sqlArray = nil;
    sql = nil;
    
    if (isNew) {
        entity.Id = [self lastRowId];
    }
    
    [[listOneToOneToSave allKeys] enumerateObjectsUsingBlock:^(NSString * oneToOneReferenceFieldName, NSUInteger index, BOOL *stop) {
        //        if ([oneToOneReferenceFieldName isEqualToString:@"inspectionSeverityRepairMethod"] || [oneToOneReferenceFieldName isEqualToString:@"inspectionSeverities"]){
        //            DLog(@"");
        //        }
        @autoreleasepool {
            AM8ORMEntity *oneToOne = [entity valueForKey:oneToOneReferenceFieldName];
            NSString *oneToOneReferenceFieldNameChild = listOneToOneToSave[oneToOneReferenceFieldName];
            if (!oneToOne){
                NSString *className = [[entity class] getCustomObjectType:oneToOneReferenceFieldName];
                NSMutableArray *childsInDbPrior = [NSMutableArray arrayWithArray:[self findListByFieldAndValueStacking:NSClassFromString(className)
                                                                                                             fieldName:[NSString concatenateStrings:oneToOneReferenceFieldNameChild,_suffixID,nil]
                                                                                                                 value:@(entity.Id)
                                                                                                              fatherId:@(entity.Id)
                                                                                                    fieldReferenceName:oneToOneReferenceFieldName
                                                                                                          fatherEntity:className
                                                                                                          inverseField:nil
                                                                                                          inverseValue:nil
                                                                                                        recursionLevel:0
                                                                                                          getFromCache:NO]];
                
                [childsInDbPrior enumerateObjectsUsingBlock:^(AM8ORMEntity *item, NSUInteger index, BOOL *stop) {
                    [self remove:item];
                }];
                
                childsInDbPrior = nil;
                className = nil;
                return;
            }
            if ([oneToOneReferenceFieldNameChild isEqualToString:_emptyString]) return;
            [oneToOne setValue:entity forKey:oneToOneReferenceFieldNameChild];
            [self save:oneToOne];
        }
    }];
    
    listOneToOneToSave = nil;
    
    NSDictionary *listsToSaveInCascade;
    if ((listsToSaveInCascade = [entity getChildsToSaveInCascade])){
        [[listsToSaveInCascade allKeys] enumerateObjectsUsingBlock:^(NSString *fieldName, NSUInteger index, BOOL *stop) {
            @autoreleasepool {
                NSString *value = listsToSaveInCascade[fieldName];
                
                if ([value rangeOfString:_barra].location != NSNotFound){ //MANYTOMANY
                    NSArray *parts = [value componentsSeparatedByString:_barra];
                    NSString *M2MEntity = fieldName;
                    NSString *fieldReferenceA = [parts objectAtIndex:0];
                    NSString *fieldReferenceB = [parts objectAtIndex:1];
                    NSString *fieldReferenceNameA = [NSString concatenateStrings:fieldReferenceA,_suffixID,nil];
                    NSString *fieldArrayName = [parts objectAtIndex:2];
                    
                    //Recuperar con un cursor y haciendo selects
                    int level = 0;
                    NSMutableArray *childsInDbPrior = [NSMutableArray arrayWithArray:[self findListByFieldAndValueStacking:NSClassFromString(M2MEntity)
                                                                                                                 fieldName:fieldReferenceNameA
                                                                                                                     value:@(entity.Id)
                                                                                                                  fatherId:@(entity.Id)
                                                                                                        fieldReferenceName:fieldArrayName
                                                                                                              fatherEntity:M2MEntity
                                                                                                              inverseField:fieldReferenceA
                                                                                                              inverseValue:entity
                                                                                                            recursionLevel:level
                                                                                                              getFromCache:NO]
                                                       ];
                    
                    NSMutableArray *toInsert = [NSMutableArray arrayWithCapacity:((NSArray *)[entity valueForKey:fieldArrayName]).count];
                    [[entity valueForKey:fieldArrayName] enumerateObjectsUsingBlock:^(AM8ORMEntity * object, NSUInteger index, BOOL *stop) {
                        @autoreleasepool {
                            AM8ORMEntity *matcher = [childsInDbPrior bk_match:^BOOL (AM8ORMEntity *evaluatedObject) {
                                return ((AM8ORMEntity *)[evaluatedObject valueForKey:fieldReferenceA]).Id == entity.Id && ((AM8ORMEntity *)[evaluatedObject valueForKey:fieldReferenceB]).Id == object.Id;
                            }];
                            
                            
                            AM8ORMEntity *temp;
                            if (matcher){
                                [childsInDbPrior removeObject:matcher];
                            } else {
                                temp = [[NSClassFromString(M2MEntity) alloc] init];
                                [temp setValue:entity forKey:fieldReferenceA];
                                [temp setValue:object forKey:fieldReferenceB];
                                [toInsert addObject:temp];
                            }
                            
                            matcher = nil;
                            temp = nil;
                        }
                    }];
                    
                    //              childsInDbPrior - childs -> ToDelete
                    [childsInDbPrior enumerateObjectsUsingBlock:^(AM8ORMEntity * item, NSUInteger index, BOOL *stop) {
                        @autoreleasepool {
                            [self remove:item];
                        }
                    }];
                    
                    [toInsert enumerateObjectsUsingBlock:^(AM8ORMEntity * item, NSUInteger index, BOOL *stop) {
                        @autoreleasepool {
                            [self save:item];
                        }
                    }];
                    childsInDbPrior = nil;
                    toInsert = nil;
                    parts = nil;
                    M2MEntity = nil;
                    fieldReferenceA = nil;
                    fieldReferenceB = nil;
                    fieldReferenceNameA = nil;
                    fieldArrayName = nil;
                    
                } else {
                    NSArray *parts = [[listsToSaveInCascade objectForKey:fieldName] componentsSeparatedByString:_comma];
                    NSString *entityNameOfChild     = [parts objectAtIndex:0];
                    NSString *fieldReferenceName    = [parts objectAtIndex:1];
                    
                    int level = 0;
                    
                    NSMutableArray *childsInDbPrior = [NSMutableArray arrayWithArray:[self findListByFieldAndValueStacking:NSClassFromString(entityNameOfChild)
                                                                                                                 fieldName:[NSString concatenateStrings:fieldReferenceName,_suffixID,nil]
                                                                                                                     value:@(entity.Id)
                                                                                                                  fatherId:@(entity.Id)
                                                                                                        fieldReferenceName:fieldName
                                                                                                              fatherEntity:entityNameOfChild
                                                                                                              inverseField:fieldReferenceName
                                                                                                              inverseValue:entity
                                                                                                            recursionLevel:level
                                                                                                              getFromCache:NO]];
                    
                    
                    NSArray *childs = [entity valueForKey:fieldName];
                    [childs enumerateObjectsUsingBlock:^(AM8ORMEntity * child, NSUInteger index, BOOL *stop) {
                        //                  childsInDbPrior - childs -> ToDelete
                        @autoreleasepool {
                            AM8ORMEntity *matcher = [childsInDbPrior bk_match:^BOOL (AM8ORMEntity *obj) {
                                return obj.Id == child.Id;
                            }];
                            
                            if (matcher) [childsInDbPrior removeObject:matcher];
                            [child setValue:entity  forKey:fieldReferenceName];
                            [self save:child];
                        }
                    }];
                    [childsInDbPrior enumerateObjectsUsingBlock:^(AM8ORMEntity * item, NSUInteger index, BOOL *stop) {
                        @autoreleasepool {
                            [self remove:item];
                        }
                    }];
                    
                    parts = nil;
                    entityNameOfChild     = nil;
                    fieldReferenceName    = nil;
                    childsInDbPrior = nil;
                    childs = nil;
                }
                value = nil;
            }
        }];
    }
    
    listsToSaveInCascade = nil;
    
    [self updateCachedEntity:entity];
    [self refreshLookupInOneToMany:entity
                         oldEntity:oldEntity
                             isNew:isNew];
    
    oldEntity=nil;
    return YES;
}

// Determinar si hace un delete logico
-(BOOL)remove:(AM8ORMEntity *)entity {
    if (!entity)
        return NO;
    
    [self openDb];
    
    if (![entity beforeDelete]) {
        //		[self checkError];
        return NO;
    }
    
    /*NSArray *sqlArray = [entity getDeleteSqlArray];
     __block NSString *sql = sqlArray[0];*/
    __block NSString *sql = [entity getDeleteSql];
    
    //    if ([sql isEqualToString:@"DELETE FROM [BCACondition] WHERE Id = 49"]){
    //        DLog(@"");
    //    }
    
    NSDictionary * referencesFieldsToDelete = [entity getToDeleteImmediatly];
    for (NSString *fieldName in [referencesFieldsToDelete allKeys]) {
        @autoreleasepool {
            NSString *value = referencesFieldsToDelete[fieldName];
            
            if ([value rangeOfString:_barra].location != NSNotFound){ //MANYTOMANY
                NSArray *parts = [value componentsSeparatedByString:_barra];
                NSString *M2MEntity = fieldName;
                NSString *fieldReferenceA = [parts objectAtIndex:0];
                //            NSString *fieldReferenceB = [parts objectAtIndex:1];
                NSString *fieldReferenceNameA = [NSString concatenateStrings:fieldReferenceA,_suffixID,nil];
                NSString *fieldArrayName = [parts objectAtIndex:2];
                
                int level = 0;
                NSArray *childs = [self findListByFieldAndValueStacking:NSClassFromString(M2MEntity)
                                                              fieldName:fieldReferenceNameA
                                                                  value:@(entity.Id)
                                                               fatherId:@(entity.Id)
                                                     fieldReferenceName:fieldArrayName
                                                           fatherEntity:M2MEntity
                                                           inverseField:fieldReferenceA
                                                           inverseValue:entity
                                                         recursionLevel:level
                                                           getFromCache:NO];
                
                //            [self deleteList:childs];
                
                [childs enumerateObjectsUsingBlock:^(AM8ORMEntity * itemToDelete, NSUInteger index, BOOL *stop) {
                    @autoreleasepool {
                        [self remove:itemToDelete];
                    }
                }];
                
                [self clearCache:M2MEntity];
                
                parts = nil;
                M2MEntity = nil;
                fieldReferenceA = nil;
                fieldReferenceNameA = nil;
                fieldArrayName = nil;
                childs = nil;
                
                
            } else {
                FieldType type = [[entity class] getType:fieldName];
                if (type == FIELDTYPE_ARRAY || type == FIELDTYPE_MUTABLEARRAY){
                    [[entity valueForKey:fieldName] enumerateObjectsUsingBlock:^(AM8ORMEntity * record, NSUInteger index, BOOL *stop) {
                        @autoreleasepool {
                            [self remove:record];
                        }
                    }];
                }
                if (type == FIELDTYPE_OBJECT){
                    //                    if ([fieldName isEqualToString:@"inspectionSeverityRepairMethod"] || [fieldName isEqualToString:@"inspectionSeverities"]){
                    //                        DLog(@"");
                    //                    }
                    [self remove:[entity valueForKey:fieldName]];
                }
            }
            value = nil;
        }
    }
    
    /*
     if (sqlArray.count == 1){
     [self execute:sql];
     } else {
     [self executeUpdate:sql  withParameterDictionary:sqlArray[1]];
     }*/
    [self execute:sql];
    
    sql=nil;
    //	if (![entity afterDelete]) {
    ////		[self checkError];
    //		return NO;
    //	}
    
    
    [self deleteCachedEntity:entity];
    
    return YES;
}



-(void)fill:(AM8ORMEntity **)entity
  resultset:(FMResultSet *)rs
recursionLevel:(int)level
inverseField:(NSString *)inverseField
inverseValue:(AM8ORMEntity *)inverseValue
getFromCache:(BOOL)getFromCache
  applyLazy:(BOOL)applyLazy
{
    [self openDb];
    
    @autoreleasepool {
        NSDictionary *props = [*entity cachedProperties];
        
        int ilevel=0;
        
        NSString *fatherEntity = [*entity tableName];
        
        //Setting 'id' value from 'rs'.
        [*entity setValue:[self valueForField:rs
                                         Name:_suffixID
                                         Type:_typeInteger
                                    fieldType:FIELDTYPE_INTEGER
                                     fatherId:nil
                                 fatherEntity:fatherEntity
                               recursionLevel:ilevel]
                   forKey:_suffixID];
        
        NSArray *lazyProperties = [[*entity class] getLazyProperties];
        
        //if entity cached return
        if (_isEntityCachingPermitted && getFromCache && [*entity isCacheable]){
            AM8ORMEntity *cachedEntity = [self.entityCache getEntity:[*entity class] Id:(*entity).Id];
            if (cachedEntity){
                *entity = cachedEntity;
                [*entity refreshDictionary];
                return;
            }
        }
        
        //Checking lazyproperties. They are not populated, obviously
        [[props allKeys] enumerateObjectsUsingBlock:^(NSString *fieldName, NSUInteger index, BOOL *stop) {
            @autoreleasepool {
                NSString *type = props[fieldName][0];
                FieldType fieldType = [props[fieldName][1] intValue];
                if ([fieldName isEqualToString:_suffixID] || (applyLazy && (fieldType == FIELDTYPE_OBJECT || fieldType == FIELDTYPE_ARRAY || fieldType == FIELDTYPE_MUTABLEARRAY) && [lazyProperties containsObject:fieldName])) {
                    return;
                }
                
                if (inverseField && [fieldName isEqualToString:inverseField]){
                    if (inverseValue){
                        [*entity setValue:inverseValue
                                   forKey:inverseField];
                    }
                    return;
                }
                
                
                [*entity setValue:[self valueForField:rs
                                                 Name:fieldName
                                                 Type:type
                                            fieldType:fieldType
                                             fatherId:@((*entity).Id)
                                         fatherEntity:fatherEntity
                                       recursionLevel:(int)level]
                           forKey:fieldName];
                
                type = nil;
            }
        }];
        
        //Populating dynamic fields
        [*entity refreshDictionary];
        
        //Loading ONETOMANY relation
        NSDictionary *listsToLoadImmediately;
        if ((listsToLoadImmediately  = [*entity  getOneToManyToLoadImmediatly])){
            [[listsToLoadImmediately allKeys] enumerateObjectsUsingBlock:^(NSString *fieldName, NSUInteger index, BOOL *stop) {
                if (applyLazy && [lazyProperties containsObject:fieldName]) {
                    return;
                }
                @autoreleasepool {
                    NSArray *parts = [listsToLoadImmediately[fieldName] componentsSeparatedByString:_comma];
                    NSString *fieldType = [parts objectAtIndex:0];
                    NSString *fieldReferenceName = [NSString concatenateStrings:[parts objectAtIndex:1],_suffixID,nil];
                    
                    NSArray *childs = [self findListByFieldAndValueStacking:NSClassFromString(fieldType)
                                                                  fieldName:fieldReferenceName
                                                                      value:@((*entity).Id)
                                                                   fatherId:@((*entity).Id)
                                                         fieldReferenceName:fieldName
                                                               fatherEntity:fieldType
                                                               inverseField:[parts objectAtIndex:1]
                                                               inverseValue:*entity
                                                             recursionLevel:level
                                                               getFromCache:YES];
                    
                    [*entity setValue:childs forKey:fieldName];
                    
                    parts       = nil;
                    fieldType   = nil;
                    fieldReferenceName = nil;
                    childs = nil;
                }
            }];
            
        }
        
        // AB[]
        //Loading MANYTOMANY relation
        NSDictionary *listsM2MToLoadImmediately  = [*entity  getManyToManyToLoadImmediatly];  // "EntityAEntityB" (es la clase):"FieldName (el array)|EntityClassName (tipo dentro del array)"
        if (listsM2MToLoadImmediately){
            [[listsM2MToLoadImmediately allKeys] enumerateObjectsUsingBlock:^(NSString *fieldArrayName, NSUInteger index, BOOL *stop) {
                if (applyLazy && [lazyProperties containsObject:fieldArrayName]) {
                    return;
                }
                @autoreleasepool {
                    NSString *_parts = [listsM2MToLoadImmediately valueForKey:fieldArrayName];
                    NSArray *parts = [_parts componentsSeparatedByString:_barra];
                    NSString *fieldReferenceA = [parts objectAtIndex:0];
                    NSString *fieldReferenceB = [parts objectAtIndex:1];
                    NSString *fieldReferenceNameA = [NSString concatenateStrings:fieldReferenceA,_suffixID,nil];
                    NSString *entityNameM2M = [parts objectAtIndex:2];
                    
                    NSArray *childs = [self findListByFieldAndValueStacking:NSClassFromString(entityNameM2M)
                                                                  fieldName:fieldReferenceNameA
                                                                      value:@((*entity).Id)
                                                                   fatherId:@((*entity).Id)
                                                         fieldReferenceName:fieldArrayName
                                                               fatherEntity:entityNameM2M
                                                               inverseField:fieldReferenceA
                                                               inverseValue:*entity
                                                             recursionLevel:level
                                                               getFromCache:YES];
                    
                    NSMutableArray *array = [NSMutableArray array];
                    [childs enumerateObjectsUsingBlock:^(AM8ORMEntity * item, NSUInteger index, BOOL *stop) {
                        @autoreleasepool {
                            if ([item valueForKey:fieldReferenceB])
                                [array addObject:[item valueForKey:fieldReferenceB]];
                        }
                    }];
                    
                    [*entity setValue:array forKey:fieldArrayName];
                    
                    _parts    = nil;
                    parts      = nil;
                    fieldReferenceA = nil;
                    fieldReferenceB = nil;
                    fieldReferenceNameA = nil;
                    entityNameM2M = nil;
                    childs = nil;
                }
            }];
        }
        
        listsM2MToLoadImmediately = nil;
        listsToLoadImmediately = nil;
        lazyProperties = nil;
        
        if (_isEntityCachingPermitted && getFromCache && [*entity isCacheable]){
            if (*entity && (*entity).Id){
                //            [self.entityCache setEntity:[entity mutableCopy]];
                [self.entityCache setEntity:*entity];
            }
        }
        
        fatherEntity = nil;
        props = nil;
        
    }
    
    
    return;
}




-(id)findByFieldAndValue:(Class)cls    fieldName:(NSString *)fieldName     value:(id)value {
    NSString *sql = [NSString stringWithFormat:_selectFromWhere, [AM8ORMEntity getTableName:cls], fieldName, [AM8SqlGenerator addQuotes:value]];
    
    AM8ORMEntity *result = nil;
    NSArray *list = [self findAndFill:sql theClass:cls];
    
    if ([list count] == 1) {
        result = [list objectAtIndex:0];
    }
    
    return result;
}


-(id)findFirst:(NSString *)sql theClass:(Class)cls{
    AM8ORMEntity *result = nil;
    
    NSArray *list = [self findAndFill:sql theClass:cls];
    
    if ([list count]) {
        result = [list objectAtIndex:0];
    }
    
    return result;
}

/**
 * Get entity from database by 'id'. If entity is cached, is not retrieved directly from database.
 * The entities & lookup (foreignkey) references are cached.
 * It is equivalent to:     "SELECT * FROM [%@] WHERE id = %d"
 * @param   class       - (Class)       Entity to retrieve. It is equivalent to the tablename.
 * @param   theId       - (NSUInteger)  'Id' is the primary key for all tables.
 * @return  (id)        - Collection of entities retrieved from Database.
 **/
-(id)findById:(Class)cls
        theId:(NSUInteger)theId {
    AM8ORMEntity *cachedEntity = (_isEntityCachingPermitted ? [self.entityCache getEntity:cls Id:theId] : nil);
    if (cachedEntity){
        [cachedEntity refreshDictionary];
        return cachedEntity;
    }
    
    return [self findByFieldAndValue:cls fieldName:_suffixID value:[NSNumber numberWithUnsignedInteger: theId]];
}

/**
 *  Populate the 'list' with records from 'sql'.
 *
 *  @param sql          SQL sentence to execute.
 *  @param list         list to populate with records gotten from SQL sentence.
 *  @param cls          Entity to retrieve. It is equivalent to the tablename.
 *  @param getFromCache TRUE => records can be retrieved from cache.
 *  @param applyLazy    ¬¨¬®‚àö‚àèCan Lazy property applied?
 *  @param level        relation deep.
 */
-(void)recordSet:(NSString *)sql list:(NSMutableArray **)list cls:(Class)cls getFromCache:(BOOL)getFromCache applyLazy:(BOOL)applyLazy {
    
    if (_isSQLCachingPermitted && getFromCache && [[(AM8ORMEntity *)[cls alloc] init] isCacheable]) {
        
        NSMutableArray *data = [self.SQLCache getData:cls SQL:sql];
        
        if ([data count] > 0){
            [_sqlStack  removeAllObjects];
            *list = data;
            NSLog(@"[SQL Cached]: %@",sql);
            return;
        }
    }
    
    FMResultSet *rs = [self load:sql];
    
    @autoreleasepool {
        int level;
        while ([rs next]) {
            level=0;
            [_sqlStack  removeAllObjects];
            AM8ORMEntity *entity = [[cls alloc] init];
            [self fill:&entity resultset:rs recursionLevel:level inverseField:nil inverseValue:nil getFromCache:getFromCache applyLazy:applyLazy];
            [*list addObject :entity];
        }
    }
    
    [_sqlStack  removeAllObjects];
    [rs close];
    rs = nil;
    
    if (_isSQLCachingPermitted && getFromCache && [[(AM8ORMEntity *)[cls alloc] init] isCacheable]) {
        [self.SQLCache setData:cls SQL:sql data:*list];
    }
    
}



/**
 * Populate the 'list' with records from 'sql'.
 * @param  sql               - (NSString *)          SQL sentence to execute.
 * @param  list              - (NSMutableArray *)    list to populate with records gotten from SQL sentence.
 * @param  cls               - (Class)               Entity to retrieve. It is equivalent to the tablename.
 * @param  level             - (int)                 Reflexive lookup properties are retrieved dependeing of the recursive level.
 * @return (FieldType)       type of the property.
 **/
-(void)recordSetStack:(NSString *)sql
                 list:(NSMutableArray **)list
                  cls:(Class)cls
         inverseField:(NSString *)inverseField
         inverseValue:(AM8ORMEntity *)inverseValue
       recursionLevel:(int)level
         getFromCache:(BOOL)fromCache
{
    //Class myClass = NSClassFromString([AM8ORMEntity getTableName:cls]);
    
    if (_isSQLCachingPermitted && fromCache && [[(AM8ORMEntity *)[cls alloc] init] isCacheable]) {
        NSMutableArray * data = [self.SQLCache getData:cls SQL:sql];
        if (data){
            *list = data;
            NSLog(@"[SQL Cached]: %@",sql);
            return;
        }
    }
    
    //    [_writeQueueLock lock];
    FMResultSet *rs = [self load:sql];
    while ([rs next]) {
        @autoreleasepool {
            AM8ORMEntity *entity = [[cls alloc] init];
            [self fill:&entity resultset:rs recursionLevel:level inverseField:inverseField inverseValue:inverseValue getFromCache:NO applyLazy:YES ];
            [*list addObject :entity];
        }
    }
    
    [rs close];
    rs=nil;
    
    if (_isSQLCachingPermitted && [[(AM8ORMEntity *)[cls alloc] init] isCacheable]) {
        
        [self.SQLCache setData:cls SQL:sql data:*list];
        
    }
    
}




/**
 * Get all entities from database.
 * The entities & lookup (foreignkey) references are cached.
 * It is equivalent to:  "SELECT * FROM [%@]"
 * @param   cls         - (Class) Entity to retrieve. It is equivalent to the tablename.
 * @return  (NSArray *) - Collection of entities retrieved from Database.
 **/
-(NSArray *)findAll:(Class)cls
              range:(NSRange)range
{
    [self openDb];
    
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    @autoreleasepool {
        NSMutableString *sql= [NSMutableString string];
        [sql appendString:[cls getSQLSelect:nil orderList:nil range:range]];
        
        [self recordSet:sql list:&list cls:cls  getFromCache:YES  applyLazy:YES];
    }
    return list;
}


/**
 * Get all entities from database.
 * The entities & lookup (foreignkey) references are cached.
 * It is equivalent to:  "SELECT * FROM [%@]"
 *  @param cls           - (Class) Entity to retrieve. It is equivalent to the tablename.
 *  @param orderList     - (NSArray) array With Objects @"Field1",@"Field2";
 *  @param whereList     - (NSArray) array With Objects @"Field1=1",@"Field2='1'"
 *  @return  (NSArray *) - Collection of entities retrieved from Database.
 **/
-(NSArray *)findAll:(Class)cls
          whereList:(NSArray *)whereList
          orderList:(NSArray *)orderList
              range:(NSRange)range
{
    [self openDb];
    
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    @autoreleasepool {
        NSMutableString *sql= [NSMutableString string];
        
        [sql appendString:[cls getSQLSelect:whereList orderList:orderList range:range]];
        
        [self recordSet:sql list:&list cls:cls getFromCache:YES applyLazy:YES];
    }
    return list;
}




/**
 * Get entity from database by 'id'.
 * The entities & lookup (foreignkey) references are not cached.
 * It is equivalent to:     "SELECT * FROM [%@] WHERE id = %d"
 * @param   class       - (Class)       Entity to retrieve. It is equivalent to the tablename.
 * @param   theId       - (NSUInteger)  'Id' is the primary key for all tables.
 * @return  (id)        - Collection of entities retrieved from Database.
 **/
-(id)findByIdNotCached:(Class)class theId:(NSUInteger)theId applyLazy:(BOOL)applyLazy {
    
    NSString *sql = [NSString stringWithFormat: _selectFromWhereId, [AM8ORMEntity getTableName:class], @(theId)];
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    /* dont modify iscached */
    @autoreleasepool {
        [self recordSet:sql list:&list cls:class  getFromCache:NO applyLazy:applyLazy];
    }
    
    AM8ORMEntity *result = nil;
    
    if ([list count] == 1) {
        result = [list objectAtIndex:0];
    }
    
    if (_isSQLCachingPermitted && [(AM8ORMEntity *)[[class alloc] init] isCacheable]) {
        [self.SQLCache setData:class
                           SQL:sql
                          data:list];
    }
    
    return result;
}



/**
 * Get entities from database depending of SQL.
 * The entities & lookup (foreignkey) references are cached.
 * It is equivalent to:     "SELECT * FROM [%@] WHERE id = %d"
 * @param   class       - (Class)       Entity to retrieve. It is equivalent to the tablename.
 * @param   theId       - (NSUInteger)  'Id' is the primary key for all tables.
 * @return  (id)        - Collection of entities retrieved from Database.
 **/
-(NSArray *)findAndFill:(NSString *)sql
               theClass:(Class)cls {
    
    
    [self openDb];
    __block NSMutableArray *list = [NSMutableArray array];
    
    @autoreleasepool {
        [self.sqlFMQueue inDatabase:^(FMDatabase * _Nonnull db) {
            [self recordSet:sql list:&list cls:cls getFromCache:YES applyLazy:YES];
        }];
        
    }
    
    return list;
}

/**
 * Get entities from database depending of SQL.
 * The entities & lookup (foreignkey) references are cached.
 * It is equivalent to:     "SELECT * FROM [%@] WHERE id = %d"
 * @param   cls         - (Class)       Entity to retrieve. It is equivalent to the tablename.
 * @param   theId       - (NSUInteger)  'Id' is the primary key for all tables.
 * @param   fromCache   - (BOOL) Specify if the query is obtained from cache or not.
 * @return  (NSArray *)        - Collection of entities retrieved from Database.
 **/
-(NSArray *)findAndFill:(NSString *)sql
               theClass:(Class)cls
           getFromCache:(BOOL)fromCache {
    
    [self openDb];
    
    if (!_sqlStack) {
        _sqlStack = [[NSMutableDictionary alloc] init];
    }
    
    __block NSMutableArray *list = [NSMutableArray array];
    
    @autoreleasepool {
        [self.sqlFMQueue inDatabase:^(FMDatabase * _Nonnull db) {
            [self recordSet:sql list:&list cls:cls  getFromCache:fromCache applyLazy:YES];
        }];
    }
    
    return list;
}



-(NSMutableArray *)findAndFillDict:(NSString *)sql
                            fields:(NSArray *)fields
                          theClass:(Class)cls {
    
    if ([[(AM8ORMEntity *)[cls alloc] init]  isCacheable]) {
        NSMutableArray * data = [self.SQLCache getData:cls SQL:sql];
        if (data){
            NSLog(@"[SQL Cached]: %@",sql);
            return data;
        }
    }
    
    [self openDb];
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    @autoreleasepool {
        //Class myClass = NSClassFromString([AM8ORMEntity getTableName:cls]);
        __strong AM8ORMEntity *entity = [[cls alloc] init];
        NSString *fatherEntity = [cls tableName];
        NSString *type = nil;
        id fieldValue;
        
        NSDictionary *props = [entity cachedProperties];
        FMResultSet *rs = [self load:sql];
        NSArray *lazyProperties = [cls getLazyProperties];
        
        while ([rs next]) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            
            int level=0;
            int ilevel = 0;
            [_sqlStack  removeAllObjects];
            fieldValue = [self valueForField:rs Name:_suffixID Type:_typeInteger fieldType:FIELDTYPE_INTEGER  fatherId:nil   fatherEntity:fatherEntity recursionLevel:ilevel];
            [entity setValue:fieldValue forKey:_suffixID];
            FieldType fieldType;
            for (NSString *fieldName in [props allKeys]) {
                if ([fields indexOfObject:fieldName] == NSNotFound) {
                    continue;
                }
                type = props[fieldName][0];
                fieldType = [props[fieldName][1] intValue];
                
                if (fieldType == FIELDTYPE_OBJECT && [lazyProperties containsObject:fieldName]){
                    continue;
                }
                
                fieldValue = [self valueForField:rs Name:fieldName Type:type  fieldType:fieldType fatherId:@(entity.Id)   fatherEntity:fatherEntity recursionLevel:level];
                [dict setValue:fieldValue forKey:fieldName];
            }
            
            [list addObject :dict];
        }
        [rs close];
        
        if ([entity isCacheable])
            if (list.count > 0){
                [self.SQLCache setData:cls
                                   SQL:sql
                                  data:list];
            }
        
    }
    return list;
}

#pragma mark DbCommands
-(NSArray *)loadAsDictArray:(NSString *)sql {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    //NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    id value;
    
    FMResultSet *rs = [self load:sql];
    
    while ([rs next]) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        for (NSString *fieldName in [rs columnsName]) {
            value = [rs stringForColumn:fieldName];
            if (value) {
                [dict setObject:value forKey:fieldName];
            } else {
                [dict setObject:@"" forKey:fieldName];
            }
        }
        
        [list addObject :dict];
        
    }
    [rs close];
    
    //[pool drain];
    
    return list;
}

-(FMResultSet *)load:(NSString *)sql{
    [self openDb];
    __block FMResultSet *rs;
    
    NSLog(@"%@",sql);
    rs = [self.theDb executeQuery: sql];
    
    [self checkError];
    
    return rs;
}

-(void)execute:(NSString *)sql{
    [self openDb];
    NSLog(@"%@",sql);
    [self.theDb executeUpdate :sql];
    
    [self checkError];
}

-(NSInteger)lastRowId {
    [self openDb];
    
    NSInteger rowId;
    rowId = [self.theDb lastInsertRowId];
    [self checkError];
    
    return rowId;
}

-(NSInteger)count:(NSString *)tableName{
    [self openDb];
    
    NSInteger count;
    count = [self.theDb intForQuery:[NSString stringWithFormat:_selectCount ,tableName]];
    [self checkError];
    
    return count;
}

-(NSInteger)intValue:(NSString *)sql {
    [self openDb];
    
    NSInteger count;
    count = [self.theDb intForQuery:sql];
    [self checkError];
    
    return count;
}

-(NSNumber *)numericValue:(NSString *)sql {
    [self openDb];
    
    NSNumber *value;
    value = [NSNumber numberWithDouble:[self.theDb doubleForQuery:sql]];
    [self checkError];
    
    return value;
}

-(NSString *)stringValue:(NSString *)sql {
    [self openDb];
    
    NSString *value;
    value = [self.theDb stringForQuery:sql];
    [self checkError];
    
    return value;
}

-(NSDecimalNumber *)decimalValue:(NSString *)sql {
    NSNumber *value = [self numericValue:sql];
    
    return [NSDecimalNumber decimalNumberWithDecimal:[value decimalValue]];;
}


- (NSMutableSet *)getTableSchema:(NSString*)tableName {
    FMResultSet *rs = [self.theDb  executeQuery:[NSString  stringWithFormat:@"PRAGMA table_info('%@')",tableName]];
    NSMutableSet *fields = [NSMutableSet set];
    //adding column in table schema
    while ([rs next]) {
        [fields addObject:[rs stringForColumn:@"name"]];
    }
    
    //If this is not done FMDatabase instance stays out of pool
    [rs close];
    return fields;
}


#pragma mark Pragma functions
-(NSInteger)userDatabaseVersion {
    return [[self numericValue:@"PRAGMA user_version"] intValue];
}


-(id)findByCriteria:(Class)cls
    fieldsAndValues:(NSDictionary *)fieldsAndValues {
    NSArray *list = [self findListByCriteria:cls fieldsAndValues:fieldsAndValues];
    AM8ORMEntity  *result = nil;
    
    if ([list count] == 1) {
        result = [list objectAtIndex:0];
    }
    
    list = nil;
    return result;
}

-(NSArray *)findListByCriteria:(Class)cls
               fieldsAndValues:(NSDictionary *)fieldsAndValues {
    __block NSMutableString *sql = [NSMutableString stringWithFormat: _selectFromWhere11, [AM8ORMEntity getTableName:cls]];
    
    @autoreleasepool {
        [fieldsAndValues enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
            NSString *condition = [NSString stringWithFormat: _conditionSameValue, key, [AM8SqlGenerator addQuotes:object] ];
            [sql appendString:condition];
        }];
    }
    
    return [self findAndFill:sql theClass:cls];
}

-(NSArray *)findListByFieldAndValue:(Class)cls
                          fieldName:(NSString *)fieldName
                              value:(id)value {
    NSMutableString *sql= [NSMutableString string];
    [sql appendString:[NSString stringWithFormat:@"%@ %@ %@ %@", _selectFromWhere, [AM8ORMEntity getTableName:cls], fieldName, [AM8SqlGenerator addQuotes:value]]];
          
    return [self findAndFill:sql theClass:cls];
}
-(NSArray *)findListByCriteria:(Class)cls
               fieldsAndValues:(NSDictionary *)fieldsAndValues
                         range:(NSRange)range  {
    __block NSMutableString *sql = [NSMutableString stringWithFormat: _selectFromWhere11, [AM8ORMEntity getTableName:cls]];
    
    @autoreleasepool {
        [fieldsAndValues enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
            NSString *condition = [NSString stringWithFormat:_conditionSameValue, key, [AM8SqlGenerator addQuotes:object] ];
            [sql appendString:condition];
        }];
    }
    
    if (range.length > 0) {
        [sql appendString:[NSString stringWithFormat:@"%@ %@ %@", _range,@(range.location + range.length), @(range.length)]];
    }
    
    return [self findAndFill:sql theClass:cls];
}

-(NSArray *)findListByFieldAndValue:(Class)cls
                          fieldName:(NSString *)fieldName
                              value:(id)value
                              range:(NSRange)range {
    NSMutableString *sql= [NSMutableString string];
    [sql appendString:[NSString stringWithFormat:@"%@ %@ %@ %@",_selectFromWhere, [AM8ORMEntity getTableName:cls], fieldName, [AM8SqlGenerator addQuotes:value]]];
          
    if (range.length > 0) {
        [sql appendString:[NSString stringWithFormat:@"%@ %@ %@", _range,@(range.location + range.length), @(range.length)]];
    }
    return [self findAndFill:sql theClass:cls];
}

-(NSArray *)findListByFieldAndValueStacking:(Class)cls
                                  fieldName:(NSString *)fieldName
                                      value:(NSNumber *)value
                                   fatherId:(NSNumber *)fatherId
                         fieldReferenceName:(NSString *)fieldReferenceName
                               fatherEntity:(NSString *)fatherEntity
                               inverseField:(NSString *)inverseField
                               inverseValue:(AM8ORMEntity *)inverseValue
                             recursionLevel:(int)level
                               getFromCache:(BOOL)fromCache
{
    NSString *sql = [NSString stringWithFormat: _selectFromWhere, [AM8ORMEntity getTableName:cls], fieldName, [AM8SqlGenerator addQuotes:value]];
    return [self findAndFillStacking:sql
                            theClass:cls
                               value:[value stringValue]
                            fatherId:fatherId
                  fieldReferenceName:fieldReferenceName
                        fatherEntity:fatherEntity
                        inverseField:inverseField
                        inverseValue:inverseValue
                      recursionLevel:level
                        getFromCache:fromCache
            ];
}

-(id)findByIdStacking:(Class)cls
                theId:(NSUInteger)theId
             fatherId:(NSNumber *)fatherId
   fieldReferenceName:(NSString *)fieldReferenceName
         fatherEntity:(NSString *)fatherEntity
         inverseField:(NSString *)inverseField
         inverseValue:(AM8ORMEntity *)inverseValue
       recursionLevel:(int)level
{
    AM8ORMEntity *cachedEntity = _isEntityCachingPermitted ? [self.entityCache getEntity:cls Id:theId] : nil;
    if (cachedEntity){
        return cachedEntity;
    }
    
    NSString *sql = [NSString stringWithFormat: _selectFromWhereId, [AM8ORMEntity getTableName:cls], @(theId)];
    NSLog(@"[--findByIdStacking--] %@",sql);
    NSArray *ret = [self findAndFillStacking:sql
                                    theClass:cls
                                       value:[@(theId) stringValue ]
                                    fatherId:(NSNumber *)fatherId
                          fieldReferenceName:fieldReferenceName
                                fatherEntity:fatherEntity
                                inverseField:inverseField
                                inverseValue:inverseValue
                              recursionLevel:level
                                getFromCache:YES];
    sql=nil;
    return (id)([ret count] > 0 ? [ret objectAtIndex:0] : nil);
}

-(NSArray *)findAndFillStacking:(NSString *)sql
                       theClass:(Class)cls
                          value:(NSString *)value
                       fatherId:(NSNumber *)fatherId
             fieldReferenceName:(NSString *)fieldReferenceName
                   fatherEntity:(NSString *)fatherEntity
                   inverseField:(NSString *)inverseField
                   inverseValue:(AM8ORMEntity *)inverseValue
                 recursionLevel:(int)level
                   getFromCache:(BOOL)fromCache
{
    @synchronized(sql){
        NSString *key = [NSString  stringWithFormat:_keyStack ,fatherEntity,[fatherId stringValue],fieldReferenceName,sql ];
        NSNumber *nCounter;
        if ((nCounter = _sqlStack[key])){
            nCounter = @([nCounter integerValue]  + 1);
        } else {
            nCounter = @(1);
        }
        
        _sqlStack[key] = nCounter;
        
        if ([nCounter integerValue] > _maximCascadeRecursiveLevel || (_maxDeepLevel ? level > _maxDeepLevel : NO)){
            [_sqlStack removeObjectForKey:key];
            return nil;
        }
        
        [self openDb];
        NSMutableArray *list = [NSMutableArray array];
        
        @autoreleasepool {
            [self recordSetStack:sql
                            list:&list
                             cls:cls
                    inverseField:inverseField
                    inverseValue:inverseValue
                  recursionLevel:level
                    getFromCache:fromCache];
        }
        
        if ((nCounter = _sqlStack[key])) {
            if ([nCounter integerValue]) {
                _sqlStack[key] = @([nCounter integerValue]  - 1);
            } else {
                [_sqlStack removeObjectForKey:key];
            }
        }
        
        return list;
    }
}

-(BOOL)columnExists:(NSString*)columnName inTableWithName:(NSString*)tableName {
    [self openDb];
    return [self.theDb  columnExists:columnName inTableWithName:tableName];
}

-(NSMutableSet *)getDbColumns:(AM8ORMEntity *)entity {
    NSString *key = [NSString concatenateStrings:_db ,[entity tableName],nil];
    NSMutableSet* theProps = [[AM8DbPropertyCache currentDbCache] value:key];
    
    if (theProps==nil) {
        theProps = [self getTableSchema:[entity tableName]];
        [[AM8DbPropertyCache currentDbCache] save:key value:theProps];
    }
    return theProps;
}

- (void) addColumn:(NSString*) column inTableWithName:(NSString*) tableName withType:(NSString*) type {
    [self addColumn:column inTableWithName:tableName withType:type notNull:NO defaultValue:nil];
}

- (void) addColumn:(NSString*) column
   inTableWithName:(NSString*) tableName
          withType:(NSString*) type
           notNull:(BOOL) notNull
      defaultValue:(NSString*) defaultValue
{
    if(![self columnExists:column inTableWithName:tableName]){
        NSString* sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ %@ %@",
                         tableName, column, type, notNull ? @"NOT NULL" : @"NULL"];
        if (defaultValue) {
            sql = [sql stringByAppendingString:@" DEFAULT "];
            sql = [sql stringByAppendingString:defaultValue];
        }
        [self execute:sql];
    }
}

@end
