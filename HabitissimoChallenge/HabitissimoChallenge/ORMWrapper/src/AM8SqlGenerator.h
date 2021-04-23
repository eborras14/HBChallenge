//
//  AM8SqlGenerator.h
//  ORMWrapper
//
//  Created by Eduard Borras Ruiz on 1/12/2020.
//  Copyright (c) 2020 PodoCat. All rights reserved.
//

#import <objc/runtime.h>
#import <objc/message.h>
#import "AM8ORMEntity.h"


@interface AM8SqlGenerator : NSObject {
    
}

/**
 *  This method optimize SQL LIKE operations.
 *
 *  @param name        Column
 *  @param value       Value for column
 *  @param indexColumn Index column
 *
 *  @return Condition Optimized
 */
+(NSString *)optimizeLike:(NSString *)name
                    value:(NSString *)value
              indexColumn:(NSString *)indexColumn;

/**
 *  Add quotes to any value. This is to avoid problems when SQL is executed.
 *
 *  @param Value Value to adapt.
 *
 *  @return Value with added quotes.
 */
+(NSString *)addQuotes:(id)Value;

/**
 *  Build SQL SELECT statement
 *
 *  @param tableName  The Name of the table. (ORM entity)
 *  @param fields     Array with field names.
 *  @param filterList Array with conditions.
 *  @param orderList  Array with Orders.
 *  @param range      Range to paginate.
 *
 *  @return SQL SELECT statement
 */
+(NSString *)getSQLSelect:(NSString *)tableName
                    fields:(NSArray *)fields
                   filters:(NSArray *)filterList
                    orders:(NSArray *)orderList
                     range:(NSRange)range ;

/**
 *  Build SQL DELETE statement
 *
 *  @param tableName  The Name of the table. (ORM entity)
 *  @param filterList Array with conditions (criteria to be applied).
 *
 *  @return SQL DELETE Statement.
 */
+(NSString *)getSQLDelete:(NSString *)tableName
                  filters:(NSArray *)filterList;

/**
 *  Build SQL INSERT OR UPDATE statement
 *
 *  @param tableName       <#tableName description#>
 *  @param fieldsAndValues <#fieldsAndValues description#>
 *
 *  @return <#return value description#>
 */
+(NSString *)getSQLInsertUpdate:(NSString *)tableName
                fieldsAndValues:(NSDictionary *)fieldsAndValues;

/**
 *  Get SQL criteria from Filter collection.
 *
 *  @param filterList Collection of filters.
 *
 *  @return SQL criteria.
 */
+(NSString *)getSQLFilterCriteria:(NSArray *)filterList;

@end
