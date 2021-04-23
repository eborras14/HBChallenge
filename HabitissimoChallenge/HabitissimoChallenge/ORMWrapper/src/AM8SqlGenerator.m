//
//  AM8SqlGenerator.m
//  ORMWrapper
//
//  Created by Eduard Borras Ruiz on 1/12/2020.
//  Copyright (c) 2020 PodoCat. All rights reserved.
//

#import "AM8SqlGenerator.h"
#import "NSString+Clean.h"
#import "NSDate+DateFunctions.h"
#import "NSLocale+Neutral.h"
#import "NSArray+BlocksKit.h"

@implementation AM8SqlGenerator

static NSString * const _where         = @" WHERE ";
static NSString * const _and           = @" AND ";
static NSString * const _select        = @"SELECT ";
static NSString * const _deleteFrom    = @"DELETE FROM [%@]";
static NSString * const _asterisc      = @"*";
static NSString * const _from          = @" FROM ";
static NSString * const _tableSQL      = @"[%@]";

static NSString * const _insert        = @"INSERT OR REPLACE INTO [%@] (%@";
static NSString * const _timestamp     = @"timestamp";
static NSString * const _values        = @") VALUES (%@)";
static NSString * const _orderBy       = @" ORDER BY ";
static NSString * const _singleQuote   = @"'";
static NSString * const _doubleQuote   = @"''";
static NSString * const _stringInsideQuotes      = @"'%@'";
static NSString * const _NULL          = @"NULL";
static NSString * const _integerFormat = @"%@";
static NSString * const _stringFormat  = @"%@";

+(NSString *)optimizeLike:(NSString *)name value:(NSString *)value indexColumn:(NSString *)indexColumn;
{
	NSMutableString * sql = [NSMutableString string];
	BOOL generateSql = YES;
	
	//Return a optimized query that mimic a LIKE
	if (indexColumn) {
		[sql appendFormat:@"(%@ = '%@')", indexColumn, [[value substringToIndex:1] uppercaseString]];
		if ([value length]==1) {
			generateSql = NO;
		} else {
			[sql appendString:@" AND "];
		}
	}
	
	if (generateSql) {
		[sql appendFormat:@"(%@ > '%@' AND %@ < '%@~') OR %@ = '%@'",name,value,name,value,name,value];
	}
	return [NSString stringWithString:sql];
}

+(NSString *) getSQLFilterCriteria:(NSArray *)filterList {
	NSMutableString * sql = [NSMutableString string];
    
	[sql appendString :_where];
    [sql appendString:[filterList componentsJoinedByString:_and]];
	
    //	count = [filterList count];
    //
    //	for (i = 0; i < count; i++) {
    //		if (i + 1 == count) {
    //			[sql appendFormat:@"(%@)", filterList[i] ];
    //		}
    //		else {
    //			[sql appendFormat:@"(%@) AND ", filterList[i] ];
    //		}
    //	}
	
	return [NSString stringWithString:sql];
}

+(NSString *) getSQLSelect:(NSString *)tableName
                    fields:(NSArray *)fields
                   filters:(NSArray *)filterList
                    orders:(NSArray *)orderList
                     range:(NSRange)range
{
	NSMutableString * sql = [NSMutableString string];
    
	[sql appendString :_select];
    
	//Get the list of fields
	if (fields) {
		[sql appendString:[fields componentsJoinedByString:_comma]];
	}
	else
	{
		[sql appendString:_asterisc];
	}
	
	[sql appendString:_from];
	[sql appendString:[NSString stringWithFormat:_tableSQL,tableName]];
	
	//Add the filters
	if (filterList) {
		[sql appendString: [AM8SqlGenerator getSQLFilterCriteria:filterList]];
	}
	
    
    
	//Add the order
	if (orderList) {
		[sql appendString :_orderBy];
		[sql appendString:[orderList componentsJoinedByString:_comma]];
	}
    
    if (range.length > 0) {
        [sql appendString:[NSString stringWithFormat:@"%@ %@ %@", _range, [@(range.location + range.length) stringValue], [@(range.length) stringValue]]];        
    }
    
    
	return [NSString stringWithString:sql];
}

+(NSString *) getSQLDelete: (NSString *)tableName filters:(NSArray *)filterList {
	NSMutableString * sql = [NSMutableString string];
    
	[sql appendFormat: _deleteFrom, tableName];
    
	//Add the filters
	if (filterList) {
		[sql appendString: [AM8SqlGenerator getSQLFilterCriteria:filterList]];
	}
	
	return [NSString stringWithString:sql];
}

+(NSString *)addQuotes: (id)Value {
	NSString *strValue = nil;
	
	if ([Value isKindOfClass:[NSNull class]])
	{
		strValue = _NULL;
	}
	else if ([Value isKindOfClass:[NSString class]])
	{
        strValue = [Value stringByReplacingOccurrencesOfString:_singleQuote withString:_doubleQuote];
        strValue = [NSString stringWithFormat: _stringInsideQuotes, strValue];
	}
	else if ([Value isKindOfClass:[NSDecimalNumber class]])
    {
        strValue = [Value stringValue];
    }
	else if ([Value isKindOfClass:[NSNumber class]])
    {
        strValue = [Value stringValue];
    }
	else if ([Value isKindOfClass:[NSDate class]])
	{
		NSDate *date = Value;
        
		strValue = [NSString stringWithFormat:_stringInsideQuotes,[date formatAsISODate]];
	}
	else if ([Value isKindOfClass:[AM8ORMEntity class]])
	{
		strValue = [NSString stringWithFormat: _integerFormat, @(((AM8ORMEntity *)Value).Id)];
	}
	else
	{
		strValue = [NSString stringWithFormat: _stringFormat, Value];
	}
    
	return strValue;
}

+(NSString *) getSQLInsertUpdate: (NSString *)tableName fieldsAndValues:(NSDictionary *)fieldsAndValues {
	NSMutableString * sql = [NSMutableString string];
	
	[sql appendFormat: _insert, tableName, [[fieldsAndValues allKeys] componentsJoinedByString:_comma]];
	
    NSString *sTimestamp = [[fieldsAndValues allKeys] bk_match:^BOOL (NSString *field) {
        return ([[field lowercaseString] isEqualToString:_timestamp]);
    }];
    
    //Make sure to set the timestamp field if exist the field and is nil.
    if (sTimestamp){
        [fieldsAndValues setValue:[NSDate date] forKey:sTimestamp];
    }
    
    //Values will be the list of fieldNames with :
    /*NSMutableArray *values = [[fieldsAndValues allKeys] mutableCopy];
    [[fieldsAndValues allKeys] enumerateObjectsUsingBlock:^(NSString *fieldName, NSUInteger index, BOOL *stop) {
        [values replaceObjectAtIndex:index withObject:[NSString stringWithFormat:@":%@",fieldName,nil]];
    }];*/
    
    NSMutableArray *values = [[fieldsAndValues allValues] mutableCopy];
    [[fieldsAndValues allValues] enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop) {
        [values replaceObjectAtIndex:index withObject:[self addQuotes:object]];
    }];
    
    [sql appendFormat: _values, [values componentsJoinedByString:_comma]];
    
	return [NSString stringWithString:sql];
}

@end
