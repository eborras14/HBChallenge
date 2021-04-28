//
//  BaseService.m
//  ORMWrapper
//
//  Created by Eduard Borras Ruiz on 1/12/2020.
//

#import "AM8BaseController.h"

@implementation AM8BaseController

//- (id)init:(Class)pClass {
//    [self doesNotRecognizeSelector:_cmd];
//    return nil;
////    if (self = [super init]) {
////        NSString *daoName = [NSStringFromClass(pClass)  stringByAppendingString:@"Dao"];
////        self.dao = [[NSClassFromString(daoName) alloc] init:pClass];
////    }
////
////	return self;
//}


/**
 *  <#Description#>
 *
 *  @param pDao <#pDao description#>
 *
 *  @return <#return value description#>
 */
- (id)init:(AM8BaseDao *)pDao {
    if (self = [super init]) {
        self.dao = pDao;
    }
    
	return self;
}

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
+(id)sharedInstance {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

//-(id)initWithConnection:(NSString *)connection {
//    [self doesNotRecognizeSelector:_cmd];
//    return nil;
//}


/**
 *  <#Description#>
 *
 *  @param ds <#ds description#>
 *
 *  @return <#return value description#>
 */
-(BOOL)save:(AM8ORMEntity *)ds {
    return [self.dao save:ds];
}


/**
 *  <#Description#>
 *
 *  @param list <#list description#>
 *
 *  @return <#return value description#>
 */
-(NSArray *)saveList: (NSArray *)list {
    return [self.dao saveList:list];
}


/**
 *  <#Description#>
 *
 *  @param list <#list description#>
 *
 *  @return <#return value description#>
 */
-(NSArray *)deleteList: (NSArray *)list {
    return [self.dao deleteList:list];
}


/**
 *  <#Description#>
 *
 *  @param ds <#ds description#>
 *
 *  @return <#return value description#>
 */
-(BOOL)remove:(AM8ORMEntity *)ds {
    return [self.dao remove:ds];
}


/**
 *  <#Description#>
 *
 *  @param fieldName <#fieldName description#>
 *  @param value     <#value description#>
 *
 *  @return <#return value description#>
 */
-(id)findByFieldAndValue:(NSString *)fieldName value:(id)value {
    return [self.dao  findByFieldAndValue:fieldName value:value];
}


/**
 *  <#Description#>
 *
 *  @param sql <#sql description#>
 *
 *  @return <#return value description#>
 */
-(id)findFirst: (NSString *)sql{
    return [self.dao  findFirst:sql];
}

/**
 *  <#Description#>
 *
 *  @param theId <#theId description#>
 *
 *  @return <#return value description#>
 */
-(id) findById:(NSUInteger)theId {
    return [self.dao findById:theId];
}


/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
-(NSArray *)findAll {
    return [self.dao  findAll];
}


/**
 *  <#Description#>
 *
 *  @param whereList <#whereList description#>
 *  @param orderList <#orderList description#>
 *
 *  @return <#return value description#>
 */
-(NSArray *)findAll:(NSArray *)whereList
          orderList:(NSArray *)orderList
{
    return [self.dao  findAll:whereList
                    orderList:orderList
            ];
    
}


/**
 *  <#Description#>
 *
 *  @param range <#range description#>
 *
 *  @return <#return value description#>
 */
-(NSArray *) findAllRange:(NSRange)range {
    return [self.dao  findAllRange:range];
}


/**
 *  <#Description#>
 *
 *  @param whereList <#whereList description#>
 *  @param orderList <#orderList description#>
 *  @param range     <#range description#>
 *
 *  @return <#return value description#>
 */
-(NSArray *)findAll:(NSArray *)whereList
          orderList:(NSArray *)orderList
              range:(NSRange)range
{
    return [self.dao  findAll:whereList
                    orderList:orderList
                        range:range
            ];
}


/**
 *  <#Description#>
 *
 *  @param fieldsAndValues <#fieldsAndValues description#>
 *  @param range           <#range description#>
 *
 *  @return <#return value description#>
 */
-(NSArray *)findListByCriteria:(NSDictionary *)fieldsAndValues
                         range:(NSRange)range{
    return [self.dao  findListByCriteria:fieldsAndValues
                                   range:range
            ];
}

/**
 *  <#Description#>
 *
 *  @param fieldName <#fieldName description#>
 *  @param value     <#value description#>
 *  @param range     <#range description#>
 *
 *  @return <#return value description#>
 */
-(NSArray *)findListByFieldAndValue:(NSString *)fieldName
                              value:(id)value
                              range:(NSRange)range
{
    return [self.dao  findListByFieldAndValue:fieldName
                                        value:value
                                        range:range
            ];
}


/**
 *  <#Description#>
 *
 *  @param sql <#sql description#>
 *
 *  @return <#return value description#>
 */
-(NSArray *)findAndFill: (NSString *)sql{
    return [self.dao  findAndFill:sql];
}


/**
 *  <#Description#>
 *
 *  @param sql        <#sql description#>
 *  @param connection <#connection description#>
 *  @param fromCache  <#fromCache description#>
 *
 *  @return <#return value description#>
 */
-(NSArray *)findAndFill:(NSString *)sql
             connection:(NSString *)connection
           getFromCache:(BOOL)fromCache {
    return [self.dao  findAndFill:sql   connection:connection getFromCache:fromCache];
}


/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
-(NSInteger)count {
    return [self.dao count];
}


/**
 *  <#Description#>
 *
 *  @param fieldsAndValues <#fieldsAndValues description#>
 *
 *  @return <#return value description#>
 */
-(id)findByCriteria:(NSDictionary *)fieldsAndValues {
    return [self.dao  findByCriteria:fieldsAndValues];
}


/**
 *  <#Description#>
 *
 *  @param fieldsAndValues <#fieldsAndValues description#>
 *
 *  @return <#return value description#>
 */
-(NSArray *)findListByCriteria:(NSDictionary *)fieldsAndValues {
    return [self.dao  findListByCriteria:fieldsAndValues];
}

/**
 *  <#Description#>
 *
 *  @param fieldName <#fieldName description#>
 *  @param value     <#value description#>
 *
 *  @return <#return value description#>
 */
-(NSArray *)findListByFieldAndValue:(NSString *)fieldName value:(id)value {
    return [self.dao  findListByFieldAndValue:fieldName value:value];
}


/**
 *  <#Description#>
 *
 *  @param ds         <#ds description#>
 *  @param connection <#connection description#>
 *
 *  @return <#return value description#>
 */
-(BOOL)save:(AM8ORMEntity *)ds       connection:(NSString *)connection {
    return [self.dao save:ds connection:connection];
}


/**
 *  <#Description#>
 *
 *  @param list       <#list description#>
 *  @param connection <#connection description#>
 *
 *  @return <#return value description#>
 */
-(NSArray *)saveList:(NSArray *)list       connection:(NSString *)connection {
    return [self.dao saveList:list  connection:connection];
}


/**
 *  <#Description#>
 *
 *  @param list       <#list description#>
 *  @param connection <#connection description#>
 *
 *  @return <#return value description#>
 */
-(NSArray *)deleteList:(NSArray *)list       connection:(NSString *)connection {
    return [self.dao deleteList:list  connection:connection];
}


/**
 *  <#Description#>
 *
 *  @param ds         <#ds description#>
 *  @param connection <#connection description#>
 *
 *  @return <#return value description#>
 */
-(BOOL)remove:(AM8ORMEntity *)ds       connection:(NSString *)connection {
    return [self.dao remove:ds  connection:connection];
}


/**
 *  <#Description#>
 *
 *  @param fieldName  <#fieldName description#>
 *  @param value      <#value description#>
 *  @param connection <#connection description#>
 *
 *  @return <#return value description#>
 */
-(id)findByFieldAndValue:(NSString *)fieldName value:(id)value       connection:(NSString *)connection {
    return [self.dao  findByFieldAndValue:fieldName value:value  connection:connection];
}

/**
 *  <#Description#>
 *
 *  @param sql        <#sql description#>
 *  @param connection <#connection description#>
 *
 *  @return <#return value description#>
 */
-(id)findFirst:(NSString *)sql       connection:(NSString *)connection{
    return [self.dao findFirst:sql   connection:connection];
}


/**
 *  <#Description#>
 *
 *  @param theId      <#theId description#>
 *  @param connection <#connection description#>
 *
 *  @return <#return value description#>
 */
-(id)findById:(NSUInteger)theId       connection:(NSString *)connection {
    return [self.dao findById:theId  connection:connection];
}


/**
 *  <#Description#>
 *
 *  @param connection <#connection description#>
 *
 *  @return <#return value description#>
 */
-(NSArray *)findAll:(NSString *)connection {
    return [self.dao  findAll:connection];
}

/**
 *  <#Description#>
 *
 *  @param whereList  <#whereList description#>
 *  @param orderList  <#orderList description#>
 *  @param connection <#connection description#>
 *
 *  @return <#return value description#>
 */
-(NSArray *)findAll:(NSArray *)whereList
          orderList:(NSArray *)orderList
         connection:(NSString *)connection
{
    return [self.dao  findAll:whereList
                    orderList:orderList
                   connection:connection];
    
}

/**
 *  <#Description#>
 *
 *  @param whereList  <#whereList description#>
 *  @param orderList  <#orderList description#>
 *  @param range      <#range description#>
 *  @param connection <#connection description#>
 *
 *  @return <#return value description#>
 */
-(NSArray *)findAll:(NSArray *)whereList
          orderList:(NSArray *)orderList
              range:(NSRange)range
         connection:(NSString *)connection {
    return [self.dao  findAll:whereList
                    orderList:orderList
                        range:range
                   connection:connection
            ];
    
}


/**
 *  <#Description#>
 *
 *  @param range      <#range description#>
 *  @param connection <#connection description#>
 *
 *  @return <#return value description#>
 */
-(NSArray *)findAll:(NSRange)range
         connection:(NSString *)connection {
    return [self.dao  findAll:range
                   connection:connection];
}


/**
 *  <#Description#>
 *
 *  @param sql        <#sql description#>
 *  @param connection <#connection description#>
 *
 *  @return <#return value description#>
 */
-(NSArray *)findAndFill:(NSString *)sql       connection:(NSString *)connection{
    return [self.dao  findAndFill:sql   connection:connection];
}


/**
 *  <#Description#>
 *
 *  @param connection <#connection description#>
 *
 *  @return <#return value description#>
 */
-(NSInteger)count:(NSString *)connection {
    return [self.dao count:connection];
}


/**
 *  <#Description#>
 *
 *  @param fieldsAndValues <#fieldsAndValues description#>
 *  @param connection      <#connection description#>
 *
 *  @return <#return value description#>
 */
-(id)findByCriteria:(NSDictionary *)fieldsAndValues       connection:(NSString *)connection {
    return [self.dao  findByCriteria:fieldsAndValues  connection:connection];
}


/**
 *  <#Description#>
 *
 *  @param fieldsAndValues <#fieldsAndValues description#>
 *  @param connection      <#connection description#>
 *
 *  @return <#return value description#>
 */
-(NSArray *)findListByCriteria:(NSDictionary *)fieldsAndValues        connection:(NSString *)connection {
    return [self.dao  findListByCriteria:fieldsAndValues  connection:connection];
}

/**
 *  <#Description#>
 *
 *  @param fieldName  <#fieldName description#>
 *  @param value      <#value description#>
 *  @param connection <#connection description#>
 *
 *  @return <#return value description#>
 */
-(NSArray *)findListByFieldAndValue:(NSString *)fieldName value:(id)value       connection:(NSString *)connection {
    return [self.dao  findListByFieldAndValue:fieldName value:value  connection:connection];
}

/**
 *  <#Description#>
 *
 *  @param fieldsAndValues <#fieldsAndValues description#>
 *  @param range           <#range description#>
 *  @param connection      <#connection description#>
 *
 *  @return <#return value description#>
 */
-(NSArray *)findListByCriteria:(NSDictionary *)fieldsAndValues
                         range:(NSRange)range
                    connection:(NSString *)connection {
    return [self.dao  findListByCriteria:fieldsAndValues
                                   range:range
                              connection:connection
            ];
}

/**
 *  <#Description#>
 *
 *  @param fieldName  <#fieldName description#>
 *  @param value      <#value description#>
 *  @param range      <#range description#>
 *  @param connection <#connection description#>
 *
 *  @return <#return value description#>
 */
-(NSArray *)findListByFieldAndValue:(NSString *)fieldName
                              value:(id)value
                              range:(NSRange)range
                         connection:(NSString *)connection {
    return [self.dao  findListByFieldAndValue:fieldName
                                        value:value
                                        range:range
                                   connection:connection
            ];
}

/**
 *  <#Description#>
 *
 *  @param ds <#ds description#>
 *
 *  @return <#return value description#>
 */
-(BOOL)update:(AM8ORMEntity *)ds  {
    return [self.dao update:ds];
}

/**
 *  <#Description#>
 *
 *  @param ds <#ds description#>
 *  @param connection <#connection description#>
 *
 *  @return <#return value description#>
 */
-(BOOL)update:(AM8ORMEntity *)ds
   connection:(NSString *)connection {
    return [self.dao update:ds
                 connection:connection];
}


@end
