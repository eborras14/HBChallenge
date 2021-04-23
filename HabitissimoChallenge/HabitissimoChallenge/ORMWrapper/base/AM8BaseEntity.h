//
//  BaseEntity.h
//  ORMWrapper
//
//  Created by Eduard Borras Ruiz on 1/12/2020.
//  Copyright (c) 2020 PodoCat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AM8BaseRuntimeSupport.h"

#define _EXCLUDEFORCOPYWITHZONE(...) \
-(NSArray *)getFieldsToExclude { \
return @[__VA_ARGS__]; \
} \


typedef enum {
	FIELDTYPE_STRING=0, FIELDTYPE_INTEGER=1,FIELDTYPE_NUMBER=2, FIELDTYPE_DECIMAL=3,
	FIELDTYPE_BOOLEAN=4, FIELDTYPE_DATETIME=5, FIELDTYPE_OBJECT=6, FIELDTYPE_DOUBLE=7, FIELDTYPE_FLOAT=8, FIELDTYPE_LONG=9, FIELDTYPE_CHAR=10, FIELDTYPE_ARRAY=11, FIELDTYPE_MUTABLEARRAY=12,
    FIELDTYPE_DYNAMIC_INTEGER=13, FIELDTYPE_DYNAMIC_NUMBER=14, FIELDTYPE_DYNAMIC_DECIMAL=15, FIELDTYPE_DYNAMIC_BOOLEAN=16, FIELDTYPE_DYNAMIC_DOUBLE=17, FIELDTYPE_DYNAMIC_FLOAT=18, FIELDTYPE_DYNAMIC_LONG=19, FIELDTYPE_DYNAMIC_DATETIME=20, FIELDTYPE_DYNAMIC_DATE=21
} FieldType;

@protocol AM8TypeAble <NSObject>
@required
+(NSDictionary *)getArrayTypeBindingForJSONDeserialize;
+(NSDictionary *)getDatePatternForJSONDeserialize;
+(NSDictionary *)loadPropertiesAndTypes:(BOOL)excludeArrays;
+(FieldType)typeForField:(NSString *)fieldType;
+(FieldType)getType:(NSString *)fieldName;
+(NSString *)getCustomObjectType:(NSString *)fieldName;

@end

@interface AM8BaseEntity : NSObject< NSMutableCopying, AM8TypeAble, NSCoding, NSCopying>

-(id)_mutableCopy;
-(id)_copy;
-(NSArray *)getFieldsToExclude;

/* To deserialize JSON. To bind arrays against types */
/**
 *  Get the values of fields concatenated and separated by empty String.
 *
 *  @param fields Fields of entity
 *
 *  @return String with concatenated values
 */
-(NSString *)getConcatenatedValues:(NSArray *)fields;

@end

