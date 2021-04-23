
//
//  AM8BaseDao.h
//  ORMWrapper
//
//  Created by Eduard Borras Ruiz on 1/12/2020.
//  Copyright (c) 2020 PodoCat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AM8Db.h"
#import "AM8DbPool.h"

#define _AM8DaoInit(className)    \
- (id)init { return  [super init:[className class]]; } \
+ (id)sharedInstance { \
        static className##Dao *sharedInstance = nil; \
        static dispatch_once_t once;    \
        dispatch_once(&once, ^{ \
            sharedInstance = [[className##Dao alloc] init:[className class]]; \
        }); \
        return sharedInstance; \
}





@protocol AM8BaseDaoPersistence <NSObject>
    @required

-(BOOL)save:(AM8ORMEntity *)entity;


-(NSArray *)saveList:(NSArray *)list;


-(NSArray *)deleteList:(NSArray *)list;


-(BOOL)remove:(AM8ORMEntity *)entity;


-(id)findByFieldAndValue:(NSString *)fieldName
                   value:(id)value;


-(id)findFirst: (NSString *)sql;


-(id)findById:(NSUInteger)theId;


-(NSArray *)findAll;


-(NSArray *)findAll:(NSArray *)whereList
          orderList:(NSArray *)orderList;


-(NSArray *)findAndFill:(NSString *)sql;


-(NSInteger)count;


-(NSInteger)intValue:(NSString *)sql connection:(NSString *)connection;

-(id)findByCriteria:(NSDictionary *)fieldsAndValues;


-(NSArray *)findListByCriteria:(NSDictionary *)fieldsAndValues;


-(NSArray *)findListByFieldAndValue:(NSString *)fieldName
                              value:(id)value;

-(NSArray *)findAllRange:(NSRange)range;



-(NSArray *)findAll:(NSArray *)whereList
          orderList:(NSArray *)orderList
              range:(NSRange)range;

-(NSArray *)findListByCriteria:(NSDictionary *)fieldsAndValues
                         range:(NSRange)range;
;


-(NSArray *)findListByFieldAndValue:(NSString *)fieldName
                              value:(id)value
                              range:(NSRange)range;
;

-(BOOL)save:(AM8ORMEntity *)entity
 connection:(NSString *)connection;

-(NSArray *)saveList:(NSArray *)list
          connection:(NSString *)connection;

-(NSArray *)deleteList:(NSArray *)list
            connection:(NSString *)connection;

-(BOOL)remove:(AM8ORMEntity *)entity
   connection:(NSString *)connection;

-(id)findByFieldAndValue:(NSString *)fieldName
                   value:(id)value
              connection:(NSString *)connection;

-(id)findFirst:(NSString *)sql
    connection:(NSString *)connection;

-(id)findById:(NSUInteger)theId
   connection:(NSString *)connection;

-(NSArray *)findAll:(NSString *)connection;


-(BOOL)update:(AM8ORMEntity *)entity;


-(BOOL)update:(AM8ORMEntity *)entity
   connection:(NSString *)connection;

-(NSArray *)findAll:(NSRange)range
         connection:(NSString *)connection;


-(NSArray *)findAll:(NSArray *)whereList
          orderList:(NSArray *)orderList
         connection:(NSString *)connection;


-(NSArray *)findAll:(NSArray *)whereList
          orderList:(NSArray *)orderList
              range:(NSRange)range
         connection:(NSString *)connection;


-(NSArray *)findAndFill:(NSString *)sql
             connection:(NSString *)connection;

-(NSArray *)findAndFill:(NSString *)sql
             connection:(NSString *)connection
           getFromCache:(BOOL)fromCache;


-(NSInteger)count:(NSString *)connection;


-(id)findByCriteria:(NSDictionary *)fieldsAndValues
         connection:(NSString *)connection;


-(NSArray *)findListByCriteria:(NSDictionary *)fieldsAndValues
                    connection:(NSString *)connection;

-(NSArray *)findListByFieldAndValue:(NSString *)fieldName
                              value:(id)value
                         connection:(NSString *)connection;


-(NSArray *)findListByCriteria:(NSDictionary *)fieldsAndValues
                         range:(NSRange)range
                    connection:(NSString *)connection;

-(NSArray *)findListByFieldAndValue:(NSString *)fieldName
                              value:(id)value
                              range:(NSRange)range
                         connection:(NSString *)connection;


+(id)sharedInstance;


@optional

-(void)recordSet:(NSString *)sql
            list:(NSMutableArray **)list
             cls:(Class)cls
      connection:(NSString *)connection
    getFromCache:(BOOL)getFromCache;


-(void)recordSet:(NSString *)sql
            list:(NSMutableArray **)list
             cls:(Class)cls
    getFromCache:(BOOL)getFromCache;
@end

@interface AM8BaseDao : NSObject<AM8BaseDaoPersistence> {
}

@property (nonatomic) Class class;


- (id)init:(Class)pClass;

@end
