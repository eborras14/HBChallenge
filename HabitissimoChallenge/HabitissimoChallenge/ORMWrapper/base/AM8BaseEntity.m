//
//  BaseEntity.m
//  ORMWrapper
//
//  Created by Eduard Borras Ruiz on 1/12/2020.
//  Copyright (c) 2020 PodoCat. All rights reserved.
//

#import "AM8BaseEntity.h"
#import "NSObject+AutoMagicCoding.h"
#import "NSString+Concatenate.h"

@interface AM8BaseEntity()
@end

@implementation NSObject (NativeJsonSerializing)

static NSString * const _subguion = @"_";
static NSString * const _arroba = @"@";
static NSString * const _comma = @",";
static NSString * const _emptyString = @"";
static NSString * const _doubleQuotes = @"\"";
static NSString * const _NULL = @"NULL";
static NSString * const _arrobaWithQuote = @"\"@";
static NSString * const _typeNSString = @"NSString";
static NSString * const _typeNSDate = @"NSDate";
static NSString * const _typeNSArray = @"NSArray";
static NSString * const _typeNSMutableArray = @"NSMutableArray";
static NSString * const _typeNSNumber = @"NSNumber";
static NSString * const _typeNSDecimal = @"NSDecimal";
static NSString * const _typeNSInteger = @"NSInteger";
static NSString * const _typeNSUInteger = @"NSUInteger";
static NSString * const _typeNSDecimalNumber = @"NSDecimalNumber";
static NSString * const _NS = @"NS";

/**
 *  <#Description#>
 *
 *  @param attributeString <#attributeString description#>
 *
 *  @return <#return value description#>
 */
- (NSString *) getPropertyType:(NSString *)attributeString {
	NSString *type = [NSString string];
	NSScanner *typeScanner = [NSScanner scannerWithString:attributeString];
	[typeScanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:_arroba] intoString:NULL];
	
	// we are not dealing with an object
	if([typeScanner isAtEnd]) {
		return _NULL;
	}
	[typeScanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:_arrobaWithQuote] intoString:NULL];
	// this gets the actual object type
	[typeScanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:_doubleQuotes] intoString:&type];
	return type;
}


/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
- (NSDictionary *)getValues {
    NSMutableDictionary *muteDictionary = [NSMutableDictionary dictionary];
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *ptype = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
        NSString *type = [self  getPropertyType:ptype];
        NSString *propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        //NSLog(@"property:%@   type: %@",propertyName, type);
        SEL propertySelector = NSSelectorFromString(propertyName);
        if ([self respondsToSelector:propertySelector]) {
            if ([type isEqualToString:_typeNSArray] || [type isEqualToString:_typeNSMutableArray]) {
                NSArray *customArrayObject = [self valueForKey:propertyName];
                
                if ([customArrayObject  count] > 0 && classDescendsFrom([[customArrayObject objectAtIndex:0] class],[ AM8BaseEntity class]))
                    //                if ([customArrayObject  count] > 0 && [[[customArrayObject objectAtIndex:0] class] isSubclassOfClass:[BaseEntity class]]   )
                {
                    NSMutableArray *array = [NSMutableArray array];
                    
                    for (AM8BaseEntity *item in customArrayObject) {
                        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                        [dict  setValue:[item getValues] forKey:[item className]];
                        [array addObject:dict];
                    }
                    [muteDictionary setValue:array forKey:propertyName];
                    
                } else {
                    [muteDictionary setValue:[self valueForKey:propertyName] forKey:propertyName];
                }
            } else {
                [muteDictionary setValue:[self valueForKey:propertyName] forKey:propertyName];
            }
            
            
        }
    }
    
    return muteDictionary;
}

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
+ (NSArray *)propertyNames {
	return [[self propertyNamesAndTypes] allKeys];
}

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
+ (NSDictionary *)propertyNamesAndTypes {
	NSMutableDictionary *propertyNames;
    if (classDescendsFrom([self superclass], [AM8BaseEntity class]))
		propertyNames = (NSMutableDictionary *)[[self superclass] propertyNamesAndTypes];
	else
		propertyNames = [NSMutableDictionary dictionary];
	
    
	//include superclass properties
	Class currentClass = [self class];
	while (currentClass != nil) {
		// Get the raw list of properties
		unsigned int outCount;
		objc_property_t *propList = class_copyPropertyList(currentClass, &outCount);
		
		// Collect the property names
		int i;
		NSString *propName;
		for (i = 0; i < outCount; i++)
		{
			objc_property_t * prop = propList + i;
			NSString *type = [NSString stringWithCString:property_getAttributes(*prop) encoding:NSUTF8StringEncoding];
			propName = [NSString stringWithCString:property_getName(*prop) encoding:NSUTF8StringEncoding];
			if (![propName isEqualToString:@"_mapkit_hasPanoramaID"]) {
				[propertyNames setObject:[self getPropertyType:type] forKey:propName];
			}
		}
		
		free(propList);
		currentClass = [currentClass superclass];
	}
	return propertyNames;
}

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
- (NSDictionary *)properties {
	return [self dictionaryWithValuesForKeys:[[self class] propertyNames]];
}

/**
 *  <#Description#>
 *
 *  @param overrideProperties <#overrideProperties description#>
 */
- (void)setProperties:(NSDictionary *)overrideProperties {
	for (NSString *property in [overrideProperties allKeys]) {
		[self setValue:overrideProperties[property] forKey:property];
	}
}

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
- (NSString *)className {
	return NSStringFromClass([self class]);
}
@end


@implementation AM8BaseEntity

static  NSMutableDictionary *sqlCopyStack = nil;
static  NSString *_sCopyStack = @"%@|%@";

static  NSString *_si = @"i";
static  NSString *_sI = @"I";
static  NSString *_ss = @"s";
static  NSString *_sS = @"S";
static  NSString *_sf = @"f";
static  NSString *_sd = @"d";
static  NSString *_sB = @"B";
static  NSString *_sl = @"l";
static  NSString *_sL = @"L";
static  NSString *_sq = @"q";
static  NSString *_sQ = @"Q";
static  NSString *_sc = @"c";
static  NSString *_sC = @"C";


+ (BOOL) AMCEnabled
{
    return YES;
}

-(NSArray *)getFieldsToExclude {
    return [NSArray array];
}

/**
 *  <#Description#>
 *
 *  @param aDecoder <#aDecoder description#>
 *
 *  @return <#return value description#>
 */
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        NSDictionary *propsAndTypes = [[self class] loadPropertiesAndTypes:NO];
        for (NSString *fieldName in [propsAndTypes  allKeys]) {
            NSString *fieldType = [propsAndTypes objectForKey:fieldName];
            FieldType type = [[self class] typeForField:fieldType];
            
            switch (type) {
                case FIELDTYPE_STRING:{
                    [self setValue:[aDecoder decodeObjectForKey:fieldName] forKey:fieldName];
                }
                    break;
                case FIELDTYPE_INTEGER:{
                    [self setValue:[NSNumber numberWithInt:[aDecoder decodeIntegerForKey:fieldName]] forKey:fieldName];
                }
                    break;
                case FIELDTYPE_LONG:{
                    [self setValue:[NSNumber numberWithInt:[aDecoder decodeIntForKey:fieldName]] forKey:fieldName];
                }
                    break;
                case FIELDTYPE_CHAR:{
                    [self setValue:[NSNumber numberWithInt:[aDecoder decodeIntForKey:fieldName]] forKey:fieldName];
                }
                    break;
                case FIELDTYPE_NUMBER:{
                    [self setValue:[aDecoder decodeObjectForKey:fieldName] forKey:fieldName];
                }
                    break;
                case FIELDTYPE_BOOLEAN:{
                    [self setValue:[NSNumber numberWithBool:[aDecoder decodeBoolForKey:fieldName]] forKey:fieldName];
                }
                    break;
                case FIELDTYPE_DATETIME:{
                    [self setValue:[aDecoder decodeObjectForKey:fieldName] forKey:fieldName];
                }
                    break;
                case FIELDTYPE_DECIMAL:{
                    [self setValue:[aDecoder decodeObjectForKey:fieldName] forKey:fieldName];
                }
                    break;
                case FIELDTYPE_DOUBLE:{
                    [self setValue:[NSNumber numberWithDouble:[aDecoder decodeDoubleForKey:fieldName]] forKey:fieldName];
                }
                    break;
                case FIELDTYPE_FLOAT:{
                    [self setValue:[NSNumber numberWithFloat:[aDecoder decodeFloatForKey:fieldName]] forKey:fieldName];
                }
                    break;
                case FIELDTYPE_OBJECT:{
                    [self setValue:[aDecoder decodeObjectForKey:fieldName] forKey:fieldName];
                }
                    break;
                case FIELDTYPE_MUTABLEARRAY:
                case FIELDTYPE_ARRAY:{
                    [self setValue:[aDecoder decodeObjectForKey:fieldName] forKey:fieldName];
                }
                    break;
                    
                default:
                    break;
            }
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    NSDictionary *propsAndTypes = [[self class] loadPropertiesAndTypes:NO];
    for (NSString *fieldName in [propsAndTypes  allKeys]) {
        NSString *fieldType = [propsAndTypes objectForKey:fieldName];
        FieldType type = [[self class] typeForField:fieldType];
        
        switch (type) {
            case FIELDTYPE_STRING:{
                [aCoder encodeObject:[self valueForKey:fieldName]            forKey:fieldName];
            }
                break;
            case FIELDTYPE_INTEGER:{
                [aCoder encodeInteger:[ (NSNumber *)[self valueForKey:fieldName]  intValue]           forKey:fieldName];
            }
                break;
            case FIELDTYPE_LONG:{
                [aCoder encodeInteger:[ (NSNumber *)[self valueForKey:fieldName]  longValue]           forKey:fieldName];
            }
                break;
            case FIELDTYPE_CHAR:{
                [aCoder encodeInteger:[ (NSNumber *)[self valueForKey:fieldName]  charValue]           forKey:fieldName];
            }
                break;
            case FIELDTYPE_NUMBER:{
                [aCoder encodeObject:[self valueForKey:fieldName]            forKey:fieldName];
            }
                break;
            case FIELDTYPE_BOOLEAN:{
                [aCoder encodeBool:[ (NSNumber *)[self valueForKey:fieldName]  boolValue]           forKey:fieldName];
            }
                break;
            case FIELDTYPE_DATETIME:{
                [aCoder encodeObject:[self valueForKey:fieldName]            forKey:fieldName];
            }
                break;
            case FIELDTYPE_DECIMAL:{
                [aCoder encodeObject:[self valueForKey:fieldName]            forKey:fieldName];
            }
                break;
            case FIELDTYPE_DOUBLE:{
                [aCoder encodeDouble:[ (NSNumber *)[self valueForKey:fieldName]  longValue]           forKey:fieldName];
            }
                break;
            case FIELDTYPE_FLOAT:{
                [aCoder encodeFloat:[ (NSNumber *)[self valueForKey:fieldName]  longValue]           forKey:fieldName];
            }
                break;
            case FIELDTYPE_OBJECT:{
                [aCoder encodeObject:[self valueForKey:fieldName]            forKey:fieldName];
            }
                break;
            case FIELDTYPE_MUTABLEARRAY:
            case FIELDTYPE_ARRAY:{
                [aCoder encodeObject:[self valueForKey:fieldName]            forKey:fieldName];
            }
                break;
        }
    }
}

-(void)serializeToDisk {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *reportToFile = [documentsDirectory stringByAppendingPathComponent:[[self className] stringByAppendingString:@".serialized"]];
    
    [NSKeyedArchiver archiveRootObject:self toFile:reportToFile];
}

-(id)deserializeFromDisk {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *reportFromFile = [documentsDirectory stringByAppendingPathComponent:[[self className] stringByAppendingString:@".serialized"]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:reportFromFile]) {
        return nil;
    }
    
    return [NSKeyedUnarchiver unarchiveObjectWithFile:reportFromFile];
}


- (id)initWithDictionaryRepresentation: (NSDictionary *) aDict
{
    self = [super initWithDictionaryRepresentation: aDict];
    if (self) {
    }
    
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    //ReviewViewer *copy = NSCopyObject(self, 0, zone);
    NSObject *mutableCopy = [[[self class] allocWithZone:zone] init];
    
    if (mutableCopy) {
        NSDictionary *propsAndTypes = [[self class] loadPropertiesAndTypes:NO];
        for (NSString *fieldName in [propsAndTypes  allKeys]) {
            if ([[self getFieldsToExclude] containsObject:fieldName]){
                continue;
            }
            NSString *fieldType = propsAndTypes[fieldName];
            FieldType type = [[self class] typeForField:fieldType];
            
            switch (type) {
                case FIELDTYPE_DOUBLE:
                case FIELDTYPE_FLOAT:
                case FIELDTYPE_INTEGER:
                case FIELDTYPE_BOOLEAN:
                case FIELDTYPE_LONG:{
                    NSNumber *n = [self valueForKey:fieldName];
                    [mutableCopy setValue:n
                                   forKey:fieldName];
                    break;
                }
                case FIELDTYPE_CHAR:{
                    NSString *n = [self valueForKey:fieldName];
                    [mutableCopy setValue:n
                                   forKey:fieldName];
                    break;
                }
                    //                case FIELDTYPE_STRING:{
                    //                    [self setValue:[self valueForKey:fieldName] forKey:fieldName];
                    //                }
                    //                    break;
                    //                case FIELDTYPE_INTEGER:{
                    //                    [self setValue:[NSNumber numberWithInt:[aDecoder decodeIntegerForKey:fieldName]] forKey:fieldName];
                    //                }
                    //                    break;
                    //                case FIELDTYPE_LONG:{
                    //                    [self setValue:[NSNumber numberWithInt:[aDecoder decodeInt64ForKey:fieldName]] forKey:fieldName];
                    //                }
                    //                    break;
                    //                case FIELDTYPE_CHAR:{
                    //                    [self setValue:[NSNumber numberWithInt:[aDecoder decodeIntForKey:fieldName]] forKey:fieldName];
                    //                }
                    //                    break;
                    //                case FIELDTYPE_NUMBER:{
                    //                    [self setValue:[aDecoder decodeObjectForKey:fieldName] forKey:fieldName];
                    //                }
                    //                    break;
                    //                case FIELDTYPE_BOOLEAN:{
                    //                    [self setValue:[NSNumber numberWithBool:[aDecoder decodeBoolForKey:fieldName]] forKey:fieldName];
                    //                }
                    //                    break;
                    //                case FIELDTYPE_DATETIME:{
                    //                    [self setValue:[aDecoder decodeObjectForKey:fieldName] forKey:fieldName];
                    //                }
                    //                    break;
                    //                case FIELDTYPE_DECIMAL:{
                    //                    [self setValue:[aDecoder decodeObjectForKey:fieldName] forKey:fieldName];
                    //                }
                    //                    break;
                    //                case FIELDTYPE_DOUBLE:{
                    //                    [self setValue:[NSNumber numberWithDouble:[aDecoder decodeDoubleForKey:fieldName]] forKey:fieldName];
                    //                }
                    //                    break;
                    //                case FIELDTYPE_FLOAT:{
                    //                    [self setValue:[NSNumber numberWithFloat:[aDecoder decodeFloatForKey:fieldName]] forKey:fieldName];
                    //                }
                    //                    break;
                    
                    
                case FIELDTYPE_ARRAY:{
                    //                    NSMutableArray *newArray = [NSMutableArray array];
                    //
                    //                    for(BaseEntity *item in (NSArray *)[self valueForKey:fieldName]){
                    //                        [newArray addObject:[item mutableCopy]];
                    //                    }
                    //
                    //                    [self setValue:[NSArray arrayWithArray:newArray] forKey:fieldName];
                    [mutableCopy setValue:[(NSArray *)[self valueForKey:fieldName] mutableCopy]
                                   forKey:fieldName];
                    break;
                }
                case FIELDTYPE_MUTABLEARRAY:{
                    //                    NSMutableArray *newArray = [NSMutableArray array];
                    //
                    //                    for(BaseEntity *item in (NSMutableArray *)[self valueForKey:fieldName]){
                    //                        [newArray addObject:[item mutableCopy]];
                    //                    }
                    //
                    //                    [self setValue:[NSMutableArray arrayWithArray:newArray] forKey:fieldName];
                    [mutableCopy setValue:[(NSMutableArray *)[self valueForKey:fieldName] mutableCopy]
                                   forKey:fieldName];
                    break;
                }
                case FIELDTYPE_OBJECT:
                {
                    if (!sqlCopyStack) {
                        sqlCopyStack = [NSMutableDictionary dictionary];
                    }
                    
                    NSString *key = [NSString  stringWithFormat:_sCopyStack,[self className],fieldName];
                    if (sqlCopyStack[key]){
                        sqlCopyStack[key] = @([(NSNumber *)sqlCopyStack[key] integerValue]  + 1);
                    } else {
                        sqlCopyStack[key] = @(1);
                    }
                    
                    if ([sqlCopyStack[key] integerValue] > 1){
                        [sqlCopyStack removeObjectForKey:key];
                        [mutableCopy setValue:[self valueForKey:fieldName]
                                       forKey:fieldName];
                        continue;
                    }
                    
                    [mutableCopy setValue:[[self valueForKey:fieldName]   mutableCopy]      forKey:fieldName];
                    break;
                }
                default:{
                    [mutableCopy setValue:[self valueForKey:fieldName]
                                   forKey:fieldName];
                }
                    break;
            }
        }
    }
    
    return mutableCopy;
}


- (id)copyWithZone:(NSZone *)zone {
    //ReviewViewer *copy = NSCopyObject(self, 0, zone);
    NSObject *copy = [[[self class] allocWithZone:zone] init];
    
    if (copy) {
        NSDictionary *propsAndTypes = [[self class] loadPropertiesAndTypes:NO];
        for (NSString *fieldName in [propsAndTypes  allKeys]) {
            if ([[self getFieldsToExclude] containsObject:fieldName]){
                continue;
            }
            NSString *fieldType = propsAndTypes[fieldName];
            FieldType type = [[self class] typeForField:fieldType];
            
            switch (type) {
                    //                case FIELDTYPE_STRING:{
                    //                    [self setValue:[self valueForKey:fieldName] forKey:fieldName];
                    //                }
                    //                    break;
                case FIELDTYPE_DOUBLE:
                case FIELDTYPE_FLOAT:
                case FIELDTYPE_INTEGER:
                case FIELDTYPE_BOOLEAN:
                case FIELDTYPE_LONG:{
                    NSNumber *n = [self valueForKey:fieldName];
                    [copy setValue:n
                            forKey:fieldName];
                    break;
                }
                case FIELDTYPE_CHAR:{
                    NSString *n = [self valueForKey:fieldName];
                    [copy setValue:n
                            forKey:fieldName];
                    break;
                }
                    //                case FIELDTYPE_CHAR:{
                    //                    [self setValue:[NSNumber numberWithInt:[aDecoder decodeIntForKey:fieldName]] forKey:fieldName];
                    //                }
                    //                    break;
                    //                case FIELDTYPE_NUMBER:{
                    //                    [self setValue:[aDecoder decodeObjectForKey:fieldName] forKey:fieldName];
                    //                }
                    //                    break;
                    //                case FIELDTYPE_BOOLEAN:{
                    //                    [self setValue:[NSNumber numberWithBool:[aDecoder decodeBoolForKey:fieldName]] forKey:fieldName];
                    //                }
                    //                    break;
                    //                case FIELDTYPE_DATETIME:{
                    //                    [self setValue:[aDecoder decodeObjectForKey:fieldName] forKey:fieldName];
                    //                }
                    //                    break;
                    //                case FIELDTYPE_DECIMAL:{
                    //                    [self setValue:[aDecoder decodeObjectForKey:fieldName] forKey:fieldName];
                    //                }
                    //                    break;
                    //                case FIELDTYPE_DOUBLE:{
                    //                    [self setValue:[NSNumber numberWithDouble:[aDecoder decodeDoubleForKey:fieldName]] forKey:fieldName];
                    //                }
                    //                    break;
                    //                case FIELDTYPE_FLOAT:{
                    //                    [self setValue:[NSNumber numberWithFloat:[aDecoder decodeFloatForKey:fieldName]] forKey:fieldName];
                    //                }
                    //                    break;
                    
                    
                case FIELDTYPE_ARRAY:{
                    //                    NSMutableArray *newArray = [NSMutableArray array];
                    //
                    //                    for(BaseEntity *item in (NSArray *)[self valueForKey:fieldName]){
                    //                        [newArray addObject:[item mutableCopy]];
                    //                    }
                    //
                    //                    [self setValue:[NSArray arrayWithArray:newArray] forKey:fieldName];
                    [copy setValue:[(NSArray *)[self valueForKey:fieldName] copy]
                            forKey:fieldName];
                    break;
                }
                case FIELDTYPE_MUTABLEARRAY:{
                    //                    NSMutableArray *newArray = [NSMutableArray array];
                    //
                    //                    for(BaseEntity *item in (NSMutableArray *)[self valueForKey:fieldName]){
                    //                        [newArray addObject:[item mutableCopy]];
                    //                    }
                    //
                    //                    [self setValue:[NSMutableArray arrayWithArray:newArray] forKey:fieldName];
                    //                    [copy setValue: [NSMutableArray  arrayWithArray:[self valueForKey:fieldName]]
                    //                                   forKey:fieldName];
                    [copy setValue:[(NSMutableArray *)[self valueForKey:fieldName] mutableCopy]
                            forKey:fieldName];
                    break;
                }
                case FIELDTYPE_OBJECT:
                {
                    if (!sqlCopyStack) {
                        sqlCopyStack = [NSMutableDictionary dictionary];
                    }
                    
                    NSString *key = [NSString  stringWithFormat:_sCopyStack,[self className],fieldName];
                    if (sqlCopyStack[key]){
                        sqlCopyStack[key] = @([(NSNumber *)sqlCopyStack[key] integerValue]  + 1);
                    } else {
                        sqlCopyStack[key] = @(1);
                    }
                    
                    if ([sqlCopyStack[key] integerValue] > 1){
                        [sqlCopyStack removeObjectForKey:key];
                        [copy setValue:[self valueForKey:fieldName]
                                forKey:fieldName];
                        continue;
                    }
                    
                    [copy setValue:[[self valueForKey:fieldName]   copy]
                            forKey:fieldName];
                    break;
                }
                default:{
                    [copy setValue:[self valueForKey:fieldName]
                            forKey:fieldName];
                }
                    break;
            }
        }
    }
    
    return copy;
}


- (id)_mutableCopy {
    id ret = [self mutableCopy];
    sqlCopyStack = nil;
    return ret;
}

- (id)_copy {
    id ret = [self copy];
    sqlCopyStack = nil;
    return ret;
}

//TODO: Descomentar si se implementa online
//
//+(id)deserializeFromJSON:(NSData *)data {
//    //    BaseEntity *entity = [string objectFromJSON:NSStringFromClass([self class]) class:[self class]];
//    NSError *error;
//    //    NSData* data = [string dataUsingEncoding:NSUTF8StringEncoding];
//    NSMutableDictionary *jsonParsed = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
//
//    DCParserConfiguration *configuration = [DCParserConfiguration configuration];
//    configuration.splitToken = _emptyString;
//
//    [[self class] configureDeserialize:configuration];
//
//    DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass:[self class]
//                                                             andConfiguration:configuration];
//
//
//    AM8BaseEntity *entity = [parser parseDictionary:jsonParsed];
//
//    return entity;



-(NSString *)getConcatenatedValues:(NSArray *)fields {
    NSString *ret = _emptyString;
    for(NSString *field in fields) {
        ret = [NSString concatenateStrings:ret, [self valueForKey:field], nil];
    }
    
    return ret;
}

-(NSData *)serialize{
    return [NSKeyedArchiver archivedDataWithRootObject:self];
}


+(FieldType)getType:(NSString *)fieldName {
    objc_property_t property = class_getProperty([self class], fieldName.UTF8String);
    
    if (property) {
        NSString *attrs = [NSString stringWithUTF8String:property_getAttributes(property)];
        
        NSArray *attrParts = [attrs componentsSeparatedByString:_comma];
        NSString *propType;
        if (attrParts != nil)
        {
            if ([attrParts count] > 0)
            {
                propType =  [[attrParts objectAtIndex:0] substringFromIndex:1];
            }
        }
        return [self typeForField:propType];;
    }
    
    return FIELDTYPE_OBJECT;
}

+(NSString *)getCustomObjectType:(NSString *)fieldName {
    objc_property_t property = class_getProperty([self class], fieldName.UTF8String);
    FieldType type;
    NSString *className = nil;
    
    if (property) {
        NSString *attrs = [NSString stringWithUTF8String:property_getAttributes(property)];
        
        NSArray *attrParts = [attrs componentsSeparatedByString:_comma];
        NSString *propType;
        if (attrParts != nil)
        {
            if ([attrParts count] > 0)
            {
                propType =  [[attrParts objectAtIndex:0] substringFromIndex:1];
            }
        }
        type = [AM8BaseEntity typeForField:propType];
        
        if (type == FIELDTYPE_OBJECT) {
            className = [propType substringWithRange:NSMakeRange(2, [propType length]-3)];
            if (classDescendsFrom(NSClassFromString(className), [AM8BaseEntity class]))
                return className;
        }
    }
    
    return @"AM8BaseEntity";
}


/**
 * Get properties from current entity (SELF). The TYPE of the properties must be inherited from 'ORMEntity'.
 * NSArrays are not included.
 * This code is based from http://code.google.com/p/sqlitepersistentobjects/
 *
 * @return  (NSDictionary *)        - Collection of properties of SELF (entity) with this features:
 *                                  - Key: String(name)         Object: String(type)
 **/
+(NSDictionary *)loadPropertiesAndTypes:(BOOL)excludeArrays  {
    // Recurse up the classes, but stop at NSObject. Each class only reports its own properties, not those inherited from its superclass
    NSMutableDictionary *theProps=nil;
    
    if (classDescendsFrom([self superclass], [AM8BaseEntity class]))
        //    if ([[self superclass] isSubclassOfClass:[AM8ORMEntity class]])
        theProps = (NSMutableDictionary *)[[self superclass] loadPropertiesAndTypes:excludeArrays];
    else
        theProps = [NSMutableDictionary dictionary];
    
    unsigned int outCount;
    
    objc_property_t *propList = class_copyPropertyList([self class], &outCount);
    
    int i;
    
    // Loop through properties and add declarations for the create
    for (i=0; i < outCount; i++)
    {
        objc_property_t * oneProp = propList + i;
        NSString *propName = [NSString stringWithUTF8String:property_getName(*oneProp)];
        NSString *attrs = [NSString stringWithUTF8String: property_getAttributes(*oneProp)];
        NSArray *attrParts = [attrs componentsSeparatedByString:_comma];
        
        //ignore the internal properties...
        if ([propName hasPrefix:_subguion]) {
            continue;
        }
        
        //skip certain runtime properties appeared in ios8
        if([@[@"description",@"debugDescription",@"superclass",@"hash"]containsObject:propName]){
            continue;
        }
        
        if (attrParts != nil)
        {
            if ([attrParts count] > 0)
            {
                NSString *propType =  [[attrParts objectAtIndex:0] substringFromIndex:1];
                //                NSString *fieldName = [[attrParts objectAtIndex:[attrParts count] - 1] substringFromIndex:1];
                //Ignore arrays.
                if ([propType hasPrefix:_arroba] ) // Object
                {
                    if (excludeArrays){
                        NSString *className = [propType substringWithRange:NSMakeRange(2, [propType length]-3)];
                        if ([className isEqualToString:_typeNSMutableArray] || [className isEqualToString:_typeNSArray]) {
                            //                        NSDictionary *listsToLoadImmediatly = [self getListsToLoadImmediatly];
                            //                        if (!listsToLoadImmediatly){
                            //                            continue;
                            //                        } else {
                            //                            if (![listsToLoadImmediatly valueForKey:fieldName]){
                            continue;
                            //                            }
                            //                        }
                        }
                    }
                }
                
                [theProps setObject:propType forKey:propName];
            }
        }
    }
    
    free( propList );
    
    return theProps;
}

/**
 * Get enumerated type from introspection of entity.
 * @param fieldName         - (NSString *) fieldName gotten from introspection.
 * @param numViewsPreShow   - (NSString *) fieldType gotten from introspection.
 * @return (FieldType)      type of the property.
 **/
+(FieldType)typeForField:(NSString *)fieldType {
    FieldType result = FIELDTYPE_INTEGER;
    
    if ([fieldType isEqualToString:_si] || // int
        [fieldType isEqualToString:_sI] || // unsigned int
        [fieldType isEqualToString:_sS] || // short
        [fieldType isEqualToString:_ss])  // unsigned short
    {
        result = FIELDTYPE_INTEGER;
    }
    if ([fieldType isEqualToString:_sf])  // float
    {
        result = FIELDTYPE_FLOAT;
    }
    if ([fieldType isEqualToString:_sd])  // double
    {
        result = FIELDTYPE_DOUBLE;
    }
    else if ([fieldType isEqualToString:_sB]) // bool or _Bool
    {
        result = FIELDTYPE_BOOLEAN;
    }
    else if ([fieldType isEqualToString:_sl] || // long
             [fieldType isEqualToString:_sL]) // usigned long
    {
        result = FIELDTYPE_LONG;
    }
    else if ([fieldType isEqualToString:_sq] || // long long
             [fieldType isEqualToString:_sQ] ) // unsigned long long
    {
        result = FIELDTYPE_NUMBER;
    }
    else if ([fieldType isEqualToString:_sc] || // char
             [fieldType isEqualToString:_sC] ) // unsigned char
        
    {
        result = FIELDTYPE_BOOLEAN;
    }
    else if ([fieldType hasPrefix:_arroba] ) // Object
    {
        NSString *className = [fieldType substringWithRange:NSMakeRange(2, [fieldType length]-3)];
        
        if ([className isEqualToString:_typeNSString]) {
            result = FIELDTYPE_STRING;
        }
        else if ([className isEqualToString:_typeNSDate]) {
            result = FIELDTYPE_DATETIME;
        }
        else if ([className isEqualToString:_typeNSInteger]) {
            result = FIELDTYPE_INTEGER;
        }
        else if ([className isEqualToString:_typeNSUInteger]) {
            result = FIELDTYPE_INTEGER;
        }
        else if ([className isEqualToString:_typeNSDecimalNumber]) {
            result = FIELDTYPE_DECIMAL;
        }
        else if ([className isEqualToString:_typeNSNumber]) {
            result = FIELDTYPE_NUMBER;
        }
        else if ([className isEqualToString:_typeNSArray]) {
            result = FIELDTYPE_ARRAY;
        }
        else if ([className isEqualToString:_typeNSMutableArray]) {
            result = FIELDTYPE_MUTABLEARRAY;
        }
        else
        {
            //Is a relationship one-to-one?
            if (![fieldType hasPrefix:_NS]) {
                result = FIELDTYPE_OBJECT;
            } else {
                NSString *msg = @"Err Can't get value for ftype %@";
                
                NSString *error = [NSString stringWithFormat:msg, fieldType];
                
                NSException *e = [NSException exceptionWithName:@"DBError"
                                                         reason:error
                                                       userInfo:nil];
                
                @throw e;
            }
        }
    }
    
    return result;
}

@end
