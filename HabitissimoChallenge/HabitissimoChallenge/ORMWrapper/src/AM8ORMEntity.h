//
//  ORMEntity.h
//  ORMWrapper
//
//  Created by Eduard Borras Ruiz on 1/12/2020.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import "NSString+Clean.h"
#import "AM8DbPropertyCache.h"
#import "AM8BaseEntity.h"
#import "AM8SqlGenerator.h"
#import "AM8metamacros.h"
#import "AM8DbPool.h"
#import "AM8Db.h"

@class AM8Db;
@class AM8DbPool;

static NSString * const _comma = @",";
static NSString * const _suffixID = @"Id";
static NSString * const _suffixIDLower = @"id";
static NSString * const _sql4Lazy = @"SELECT * FROM [%@] WHERE id = (SELECT %@Id FROM [%@] AS _a WHERE _a.id = %d)";
static NSString * const _sql4LazyId = @"SELECT %@Id FROM [%@] AS _a WHERE _a.id = %d";
static NSString * const _sql4LazyCache = @"SELECT * FROM [%@] WHERE Id = %d";
static NSString * const _oneToManyLazyFieldName = @"%@%@";
static NSString * const _barra         = @"|";
static NSString *_idEqualTo = @"Id = %d";

#define _ONETOONE(...) \
    -(NSDictionary *)getOneToOneToSaveImmediatly { \
        return @{__VA_ARGS__}; \
    } \

#define _ONETOMANY(...) \
    -(NSDictionary *)getOneToManyToLoadImmediatly { \
        return @{__VA_ARGS__}; \
    } \


//A  B[]  --->   @"EntityM2M"-AB:@"FieldReference"A|"FieldReference"B|@"arrayBdeclanedInA"
//B  A[]  --->   @"EntityM2M"-AB:@"FieldReference"B|"FieldReference"A|@"arrayAdeclanedInB"
#define _MANYTOMANY(...) \
-(NSDictionary *)getManyToManyToLoadImmediatly { \
    return @{__VA_ARGS__}; \
} \


#define _DELETECASCADE(...) \
-(NSDictionary *)getToDeleteImmediatly { \
    return @{__VA_ARGS__}; \
} \


//Only arrays can be saved by cascade
#define _SAVECASCADE(...) \
-(NSDictionary *)getChildsToSaveInCascade { \
    return @{__VA_ARGS__}; \
}




/**
 *  _LAZYPROPERTIES
 *  Only can be LAZY properties INHERITING from AM8ORMENTITY => Not arrays
 *
 *  @param ... Collection with name of Properties
 */
#define _LAZYPROPERTIES(...) \
    +(NSArray *)getLazyProperties {  \
        static NSMutableArray *mArray = nil; \
        static dispatch_once_t once;    \
        dispatch_once(&once, ^{ \
            mArray = [@[] mutableCopy]; \
            am8metamacro_foreach(_lazyproperty_,, __VA_ARGS__) \
        }); \
        \
        return mArray; \
    }   \
    \
    am8metamacro_foreach(_lazypropertyaccessmethod_,, __VA_ARGS__)


/*** implementation details follow ***/
#define _lazyproperty_(INDEX, VAR) \
    [mArray addObject:@#VAR];



#define _lazypropertyaccessmethod_(INDEX, VAR) \
-(id)VAR { \
if (_##VAR) return _##VAR; \
\
    @try {\
            \
        NSDictionary *listsToLoadImmediately  = [self  getOneToManyToLoadImmediatly]; \
        AM8Db *db = [[AM8DbPool sharedInstance] getConnection]; \
        \
        if ([[listsToLoadImmediately allKeys] containsObject:@#VAR]) {\
            DLogDB(@"[_lazypropertyaccessmethod_ 1TM] %@",@#VAR);\
            NSArray *parts = [listsToLoadImmediately[@#VAR] componentsSeparatedByString:_comma]; \
            NSString *fieldType = [parts objectAtIndex:0];\
            NSString *fieldReferenceName = [NSString concatenateStrings:[parts objectAtIndex:1],_suffixID,nil];\
            \
            NSArray *childs = [db findListByFieldAndValue:NSClassFromString(fieldType) fieldName:fieldReferenceName value:@(self.Id)];\
            /*int level = 0;
            NSArray *childs = [db findListByFieldAndValueStacking:NSClassFromString(fieldType) fieldName:fieldReferenceName
                                                            value:@(self.Id)
                                                         fatherId:@(self.Id)
                                               fieldReferenceName:@#VAR
                                                     fatherEntity:fieldType
                                                   recursionLevel:level
                                                     getFromCache:YES];*/ \
            \
            [self setValue:childs forKey:@#VAR];\
            return childs;\
        }\
        \
        NSDictionary *listsM2MToLoadImmediately  = [self  getManyToManyToLoadImmediatly];\
        if ([[listsM2MToLoadImmediately allKeys] containsObject:@#VAR]) {\
            DLogDB(@"[_lazypropertyaccessmethod_ M2M] %@",@#VAR);\
            NSString *_parts = listsM2MToLoadImmediately[@#VAR];\
            NSArray *parts = [_parts componentsSeparatedByString:_barra];\
            NSString *fieldReferenceA = [parts objectAtIndex:0];\
            NSString *fieldReferenceB = [parts objectAtIndex:1];\
            NSString *fieldReferenceNameA = [NSString concatenateStrings:fieldReferenceA,_suffixID,nil];\
            NSString *entityNameM2M = [parts objectAtIndex:2];\
            \
            NSArray *childs = [db findListByFieldAndValue:NSClassFromString(entityNameM2M) fieldName:fieldReferenceNameA value:@(self.Id)];\
            /*int level = 0;
            NSArray *childs = [db findListByFieldAndValueStacking:NSClassFromString(fieldType)
                                                        fieldName:fieldReferenceNameA
                                                            value:@(self.Id)
                                                         fatherId:@(self.Id)
                                               fieldReferenceName:fieldArrayName
                                                     fatherEntity:@#VAR
                                                   recursionLevel:level
                                                     getFromCache:YES];*/\
            \
            NSMutableArray *nArray = [NSMutableArray array];\
            for (AM8ORMEntity *item in childs){\
                [nArray addObject:[item valueForKey:fieldReferenceB]];\
            }\
            [self setValue:nArray forKey:@#VAR];\
            return nArray;\
        }\
        \
        \
        AM8ORMEntity *__lazyvalue;\
        \
        NSString *__lazytype = [(Class<AM8TypeAble>)[self class]  getCustomObjectType:@#VAR];\
        Class<AM8TypeAble> entityClass = NSClassFromString(__lazytype);\
        \
        NSInteger _lazyId = [db intValue:$(_sql4LazyId, @#VAR, [self tableName], self.Id)];\
        if (!_lazyId){\
            return nil;\
        }\
        \
        NSString *sql = $(_sql4LazyCache, __lazytype, _lazyId);\
        DLogDB(@"[_lazypropertyaccessmethod_] %@",sql);\
        \
        NSArray *ret = [db findAndFill:sql theClass:entityClass];\
        __lazyvalue = (ret.count > 0 ? ret[0] : nil);\
        if(__lazyvalue) {\
            [self setValue:__lazyvalue forKey:@#VAR];\
            [db.entityCache setEntity:self];\
            [db.entityCache setEntity:__lazyvalue];\
        }\
        [db.SQLCache setData:entityClass    SQL:sql     data:[NSMutableArray arrayWithObject:__lazyvalue]];\
        NSString *sqlCache = $(_sql4LazyCache, __lazytype, __lazyvalue.Id);\
        [db.SQLCache setData:entityClass    SQL:sqlCache     data:[NSMutableArray arrayWithObject:__lazyvalue]];\
        return __lazyvalue;\
    }\
    @catch (NSException *exception) {\
    }\
    @finally {\
    }\
    \
    return nil;\
}



typedef enum _RecordTypeAction {
    RecordTypeDelete = 1,
    RecordTypeInsert,
    RecordTypeUpdate
} RecordTypeAction;


@protocol AM8Cacheable <NSObject>
@required
-(BOOL)isCacheable;
@end


@protocol AM8DynamicField <NSObject>
@optional
- (void)refreshDictionary;
- (void)refreshDynamicJSONField;
- (NSMutableDictionary *)toDictionary;
- (NSMutableDictionary *)toDictionaryForSent;
@end

@interface AM8ORMEntity : AM8BaseEntity<AM8Cacheable, AM8DynamicField>{
    
}

@property (nonatomic) NSInteger Id;
@property (nonatomic, strong) NSMutableArray *errors;

-(BOOL)validateForInsertAndUpdate:(NSError **)error;
-(BOOL)validateForDelete:(NSError **)error;
-(NSString *)errorsAsString;
-(NSUInteger)nextRowId;

/**
 *  <#Description#>
 *
 *  @param identifier <#Id description#>
 *
 *  @return <#return value description#>
 */
-(id)init:(NSInteger) identifier;

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
-(BOOL)isValid;


/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
-(BOOL)_am8IsNew;

/**
 *  <#Description#>
 */
-(void)setDefaults;

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
-(BOOL)beforeSave;


/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
-(BOOL)beforeDelete;


/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
-(BOOL)afterSave;


/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
-(BOOL)afterDelete;

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
-(NSDictionary *) getPropertiesAndValues;

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
-(NSString *) tableName;


/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
+(NSString *) tableName;


/**
 *  <#Description#>
 *
 *  @param cls <#cls description#>
 *
 *  @return <#return value description#>
 */
+(NSString *) getTableName: (Class)cls;

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
+(NSString *) relationName;

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
-(NSDictionary *)cachedProperties;


/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
+(NSDictionary *)cachedProperties;

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
+(NSDictionary *)loadProperties;


/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
-(NSDictionary *)lookupProperties;

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
+(NSDictionary *)lookupProperties;

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
+(NSDictionary *)loadLookupProperties;


/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
-(NSDictionary *)lookupOneToManyProperties;

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
+(NSDictionary *)loadLookupOneToManyProperties;

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
+(NSString *)propertiesAsStringList;

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
-(NSDictionary *)getOneToOneToSaveImmediatly;

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
-(NSDictionary *)getToDeleteImmediatly;

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
-(NSDictionary *)getOneToManyToLoadImmediatly;

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
-(NSDictionary *)getChildsToSaveInCascade;

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
+(NSArray *)getLazyProperties;

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
-(NSDictionary *)getManyToManyToLoadImmediatly;

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
-(NSString *)getDeleteSql;

-(NSArray *)getDeleteSqlArray;

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
-(NSString *)getUpdateSql;

-(NSArray *)getUpdateSqlArray;

/**
 *  <#Description#>
 *
 *  @param whereList <#whereList description#>
 *  @param orderList <#orderList description#>
 *  @param range     <#range description#>
 *
 *  @return <#return value description#>
 */
+(NSString *)getSQLSelect:(NSArray *)whereList
                orderList:(NSArray *)orderList
                    range:(NSRange)range;


/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
+(id)getNullEntity;

@end

/**
 *  <#Description#>
 */
@interface AM8ORMEntityTime : AM8ORMEntity {
    NSDate* timeStamp;
}

/**
 *  <#Description#>
 */
@property (nonatomic, strong) NSDate *timeStamp;



@end
