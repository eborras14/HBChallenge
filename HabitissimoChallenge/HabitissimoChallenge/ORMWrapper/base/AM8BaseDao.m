//
//  BaseDao.m
//  ORMWrapper
//
//  Created by Eduard Borras Ruiz on 1/12/2020.
//

#import "AM8BaseDao.h"

@implementation AM8BaseDao

- (id)init:(Class)pClass   {
    if (self = [super init]) {
        //self.db = (Db *)[AM8Db currentDb];
        self.class = pClass;
    }
	
	return self;
}

//  Abstract method
- (id)initWithConnection:(NSString *)connection {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}


+(id)sharedInstance {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}


-(BOOL)save:(AM8ORMEntity *)entity       connection:(NSString *)connection {
    return [[[AM8DbPool  sharedInstance] getConnection:connection] save:entity];
}
-(NSArray *)saveList:(NSArray *)list       connection:(NSString *)connection {
    return [[[AM8DbPool  sharedInstance] getConnection:connection] saveList:list];
}
-(NSArray *)deleteList:(NSArray *)list       connection:(NSString *)connection {
    return [[[AM8DbPool  sharedInstance] getConnection:connection] deleteList:list];
}
-(BOOL)remove:(AM8ORMEntity *)ds       connection:(NSString *)connection {
    return [[[AM8DbPool  sharedInstance] getConnection:connection] remove:ds];
}
-(id)findByFieldAndValue:(NSString *)fieldName value:(id)value       connection:(NSString *)connection {
    return [[[AM8DbPool  sharedInstance] getConnection:connection]  findByFieldAndValue:self.class fieldName:fieldName value:value];
}
-(id)findFirst:(NSString *)sql       connection:(NSString *)connection{
    return [[[AM8DbPool  sharedInstance] getConnection:connection] findFirst:sql theClass:self.class];
}
-(id)findById:(NSUInteger)theId       connection:(NSString *)connection {
    return [[[AM8DbPool  sharedInstance] getConnection:connection] findById:self.class theId:theId];
}
-(NSArray *)findAll:(NSString *)connection {
    return [[[AM8DbPool  sharedInstance] getConnection:connection]  findAll:self.class   range:NSMakeRange(0, 0)];
}
-(NSArray *)findAll:(NSRange)range
         connection:(NSString *)connection {
    return [[[AM8DbPool  sharedInstance] getConnection:connection]  findAll:self.class   range:range];
}

-(NSArray *)findAll:(NSArray *)whereList
          orderList:(NSArray *)orderList
         connection:(NSString *)connection {
    return [[[AM8DbPool  sharedInstance] getConnection:connection]  findAll:self.class
                                                                  whereList:whereList
                                                                  orderList:orderList
                                                                      range:NSMakeRange(0, 0)
            ];
    
}
-(NSArray *)findAll:(NSArray *)whereList
          orderList:(NSArray *)orderList
              range:(NSRange)range
         connection:(NSString *)connection {
    return [[[AM8DbPool  sharedInstance] getConnection:connection]  findAll:self.class
                                                                  whereList:whereList
                                                                  orderList:orderList
                                                                      range:range
            ];
    
}

-(NSArray *)findAndFill:(NSString *)sql       connection:(NSString *)connection{
    return [[[AM8DbPool  sharedInstance] getConnection:connection]  findAndFill:sql theClass:self.class];
}
-(NSArray *)findAndFill:(NSString *)sql
             connection:(NSString *)connection
           getFromCache:(BOOL)fromCache {
    return [[[AM8DbPool  sharedInstance] getConnection:connection]  findAndFill:sql theClass:self.class getFromCache:fromCache];
}
-(NSInteger)count:(NSString *)connection {
    return [[[AM8DbPool  sharedInstance] getConnection:connection] count:[AM8ORMEntity getTableName:self.class]];
}

-(NSInteger)intValue:(NSString *)sql connection:(NSString *)connection {
    return [[[AM8DbPool  sharedInstance] getConnection:connection] intValue:sql];
}

-(id)findByCriteria:(NSDictionary *)fieldsAndValues       connection:(NSString *)connection {
    return [[[AM8DbPool  sharedInstance] getConnection:connection]  findByCriteria:self.class fieldsAndValues:fieldsAndValues];
}
-(NSArray *)findListByCriteria:(NSDictionary *)fieldsAndValues        connection:(NSString *)connection {
    return [[[AM8DbPool  sharedInstance] getConnection:connection]  findListByCriteria:self.class fieldsAndValues:fieldsAndValues];
}
-(NSArray *)findListByFieldAndValue:(NSString *)fieldName value:(id)value       connection:(NSString *)connection {
    return [[[AM8DbPool  sharedInstance] getConnection:connection]  findListByFieldAndValue:self.class  fieldName:fieldName value:value];
}
-(NSArray *)findListByCriteria:(NSDictionary *)fieldsAndValues
                         range:(NSRange)range
                    connection:(NSString *)connection {
    return [[[AM8DbPool  sharedInstance] getConnection:connection]  findListByCriteria:self.class
                                                                       fieldsAndValues:fieldsAndValues
                                                                                 range:range
            ];
}
-(NSArray *)findListByFieldAndValue:(NSString *)fieldName
                              value:(id)value
                              range:(NSRange)range
                         connection:(NSString *)connection {
    return [[[AM8DbPool  sharedInstance] getConnection:connection]  findListByFieldAndValue:self.class
                                                                                  fieldName:fieldName
                                                                                      value:value
                                                                                      range:range
            ];
}
-(void)recordSet:(NSString *)sql    list:(NSMutableArray **)list     cls:(Class)cls   connection:(NSString *)connection      getFromCache:(BOOL)getFromCache{
    return [[[AM8DbPool  sharedInstance] getConnection:connection]  recordSet:sql      list:list       cls:cls   getFromCache:getFromCache    applyLazy:YES];
}




-(BOOL)save:(AM8ORMEntity *)entity {
    return [self save:entity  connection:[[AM8DbPool  sharedInstance] defaultPoolName]];
}
-(NSArray *) saveList: (NSArray *)list {
    return [self saveList:list  connection:[[AM8DbPool  sharedInstance] defaultPoolName]];
}
-(NSArray *) deleteList: (NSArray *)list {
    return [self deleteList:list  connection:[[AM8DbPool  sharedInstance] defaultPoolName]];
}
-(BOOL) remove:(AM8ORMEntity *)entity {
    return [self remove:entity  connection:[[AM8DbPool  sharedInstance] defaultPoolName]];
}
-(id) findByFieldAndValue:(NSString *)fieldName value:(id)value {
    return [self  findByFieldAndValue:fieldName value:value  connection:[[AM8DbPool  sharedInstance] defaultPoolName]];
}
-(id)findFirst: (NSString *)sql{
    return [self  findFirst:sql   connection:[[AM8DbPool  sharedInstance] defaultPoolName]];
}
-(id) findById:(NSUInteger)theId {
    return [self findById:theId  connection:[[AM8DbPool  sharedInstance] defaultPoolName]];
}
-(NSArray *) findAll {
    return [self  findAll:[[AM8DbPool  sharedInstance] defaultPoolName]];
}
-(NSArray *)findAll:(NSArray *)whereList
          orderList:(NSArray *)orderList
{
    return [self  findAll:whereList
                orderList:orderList
               connection:[[AM8DbPool  sharedInstance] defaultPoolName]];
    
}
-(NSArray *) findAllRange:(NSRange)range {
    return [self  findAll:range  connection:[[AM8DbPool  sharedInstance] defaultPoolName]];
}
-(NSArray *)findAll:(NSArray *)whereList
          orderList:(NSArray *)orderList
              range:(NSRange)range
{
    return [self  findAll:whereList
                orderList:orderList
                    range:range
               connection:[[AM8DbPool  sharedInstance] defaultPoolName]];
    
}


-(NSArray *) findAndFill: (NSString *)sql{
    return [self  findAndFill:sql   connection:[[AM8DbPool  sharedInstance] defaultPoolName]];
}
-(NSInteger) count {
    return [self count:[[AM8DbPool  sharedInstance] defaultPoolName]];
}
-(id) findByCriteria:(NSDictionary *)fieldsAndValues {
    return [self  findByCriteria:fieldsAndValues  connection:[[AM8DbPool  sharedInstance] defaultPoolName]];
}
-(NSArray *)findListByCriteria:(NSDictionary *)fieldsAndValues {
    return [self  findListByCriteria:fieldsAndValues    connection:[[AM8DbPool  sharedInstance] defaultPoolName]];
}
-(NSArray *)findListByFieldAndValue:(NSString *)fieldName value:(id)value {
    return [self  findListByFieldAndValue:fieldName value:value      connection:[[AM8DbPool  sharedInstance] defaultPoolName]];
}
-(NSArray *)findListByCriteria:(NSDictionary *)fieldsAndValues range:(NSRange)range{
    return [self  findListByCriteria:fieldsAndValues
                               range:range
                          connection:[[AM8DbPool  sharedInstance] defaultPoolName]];
}
-(NSArray *)findListByFieldAndValue:(NSString *)fieldName
                              value:(id)value
                              range:(NSRange)range
{
    return [self  findListByFieldAndValue:fieldName
                                    value:value
                                    range:range
                               connection:[[AM8DbPool  sharedInstance] defaultPoolName]];
}
-(void)recordSet:(NSString *)sql    list:(NSMutableArray **)list       cls:(Class)cls     getFromCache:(BOOL)getFromCache{
    return [self recordSet:sql list:list cls:self.class  connection:[[AM8DbPool  sharedInstance] defaultPoolName]   getFromCache:getFromCache];
}

-(BOOL)update:(AM8ORMEntity *)entity  {
    return [self update:entity connection:[[AM8DbPool  sharedInstance] defaultPoolName]];
}

-(BOOL)update:(AM8ORMEntity *)entity     connection:(NSString *)connection {
    return [[[AM8DbPool  sharedInstance] getConnection:connection] update:entity];
}



@end





