//
//  AM8ORMEntity.m
//  ORMWrapper
//
//  Created by Eduard Borras Ruiz on 1/12/2020.
//  Copyright (c) 2020 PodoCat. All rights reserved.
//

#import "AM8ORMEntity.h"
//#import "NSDictionary+Show.h"
#import "AM8NSExceptionDb.h"
#import "NSString+Concatenate.h"



@implementation AM8ORMEntity

static  NSMutableDictionary *sqlCopyStackORM = nil;
static  NSString *_sCopyStackORM = @"%@|%@|%d";

static NSString *_typeNSString = @"NSString";
static NSString *_typeNSDate = @"NSDate";
static NSString *_typeNSArray = @"NSArray";
static NSString *_typeNSMutableArray = @"NSMutableArray";
static NSString *_typeNSNumber = @"NSNumber";
static NSString *_typeNSDecimal = @"NSDecimal";
static NSString *_typeNSDictionary = @"NSDictionary";
static NSString *_typeNSMutableDictionary = @"NSMutableDictionary";

static NSString *_arroba = @"@";
static NSString *_backSlash = @"\"";


@synthesize Id, errors = _errors;

-(id)init {
	if ((self = [super init])) {
		[self setDefaults];
		self.errors = [[NSMutableArray alloc] init];
	}
	
	return self;
}

-(id)init:(NSInteger) identifier {
    
    self = [super init];
    if (self){
        self.Id = identifier;
    }
    
    return self;
}

-(NSUInteger)nextRowId {
    //it should be Autoincrement in Database Definition
    return self.Id;
}

#pragma mark Validation
- (BOOL)validateForInsertAndUpdate:(NSError **)error {
	return YES;
}

- (BOOL)validateForDelete:(NSError **)error {
	return YES;
}

-(BOOL)isCacheable {
    return YES;
}

-(BOOL) isValid {
	__block BOOL isOk = YES;
	NSDictionary *fieldsAndValues = [self getPropertiesAndValues];
	__block NSError *error=nil;
    
	[self.errors removeAllObjects];
	
    [[fieldsAndValues allKeys] enumerateObjectsUsingBlock: ^(NSString *lkey, NSUInteger idx, BOOL *stop) {
        @autoreleasepool {
            id value = fieldsAndValues[lkey];
            
            if (![self validateValue :&value forKey:lkey error :&error]) {
                if (error==nil) {
                    NSException *e = [NSException
                                      exceptionWithName:_dbError
                                      reason:[NSString stringWithFormat: @"NSError is nil for %@", lkey]
                                      userInfo:nil];
                    AM8NSExceptionDb *f = [[AM8NSExceptionDb alloc] initWithException:e];
                    @throw f;
                }
                
                [self.errors addObject:error];
                
                isOk = isOk && NO;
            }
        }
    }];
    
	//Only invoke validation for row if properties are Ok
	if (isOk && ![self validateForInsertAndUpdate:&error]) {
		[self.errors addObject:error];
		isOk = isOk && NO;
	}
	
	return isOk;
}

- (NSString *)errorsAsString {
	NSMutableString *errors = [NSMutableString string];
    
	for (NSError *error in self.errors) {
		[errors appendString:[error localizedDescription]];
		[errors appendString:@"\n\n"];
	}
    
	return errors;
}

-(BOOL) _am8IsNew{
	if (self.Id) {
		return NO;
	}
	else {
		return YES;
	}
}

-(BOOL) beforeSave {
	//Override in childrens...
	return YES;
}

-(BOOL) beforeDelete {
	//Override in childrens...
	return YES;
}

-(BOOL) afterSave {
	//Override in childrens...
	return YES;
}

-(BOOL) afterDelete {
	//Override in childrens...
	return YES;
}


-(void) setDefaults{
	//Override in childrens...
}




/*  Method to get the Lazies properties for an Entity.
 @Return
 Dictionary with key --> Type
 value-> FieldName
 */
-(NSDictionary *)getOneToManyToLoadImmediatly {
    return nil;
}

-(NSArray *)getOneToOneToSaveImmediaotly {
    return nil;
}

-(NSDictionary *)getToDeleteImmediatly {
    
    return nil;
}

-(NSDictionary *)getOneToOneToSaveImmediatly {
    return nil;
}


-(NSDictionary *)getChildsToSaveInCascade {
    return nil;
}

-(NSDictionary *)getManyToManyToLoadImmediatly {
    return nil;
}

+(NSArray *)getLazyProperties {
    return [NSArray array];
}


#pragma mark introspection properties

/**
 * Get properties & values from current entity (SELF).
 * NSArrays are not included. This is used to create UPDATE SQL sentences.
 * This code is based from http://code.google.com/p/sqlitepersistentobjects/
 *
 * @return  (NSDictionary *)        - Collection of properties of SELF (entity) with this features:
 *                                  - Key: String(name)         Object: String(type)
 **/
-(NSDictionary *)getPropertiesAndValues {
	NSMutableDictionary * info = [NSMutableDictionary dictionary];
	NSDictionary *props = [self cachedProperties];
	
	NSString *fieldName;
    //[props show];
    
	for (fieldName in [props allKeys]) {
        @autoreleasepool {
            id fieldValue = [self valueForKey :fieldName];
            NSString *type = props[fieldName][0];
            type = [[type  stringByReplacingOccurrencesOfString:_arroba withString:_emptyString]  stringByReplacingOccurrencesOfString:_backSlash withString:_emptyString];
            
            if ([type isEqualToString:_typeNSArray] || [type isEqualToString:_typeNSMutableArray] || [type isEqualToString:_typeNSDictionary] || [type isEqualToString:_typeNSMutableDictionary]) {
                continue;
            } else if (![type isEqualToString:_typeNSString] && ![type isEqualToString:_typeNSNumber] && ![type isEqualToString:_typeNSDecimal] && ![type isEqualToString:_typeNSDate]){
                if (classDescendsFrom(NSClassFromString(type), [AM8ORMEntity class])) {
                    //If field is reference (foreign key) to other table we concat 'Id'
                    fieldName = [NSString concatenateStrings:fieldName,_suffixID, nil];
                    AM8ORMEntity *hold = fieldValue;
                    fieldValue = (hold.Id ? @(hold.Id) : [NSNull null]);
                }
            } else if (fieldValue == nil) {
                fieldValue = [NSNull null];
            }
            
            if ([NSStringFromClass([self class]) isEqualToString:@"Visit"] && [fieldName isEqualToString:@"user"]) {
                continue;
            }
            
            if ([NSStringFromClass([self class]) isEqualToString:@"Employee"] && [fieldName isEqualToString:@"eventColor"]) {
                continue;
            }
            
            [info setObject:fieldValue forKey:fieldName];
        }
    }
    
    
    fieldName = nil;
    
	return info;
}


+(NSString *)propertiesAsStringList {
	return [[[self cachedProperties] allKeys] componentsJoinedByString:_comma];
}

-(NSDictionary *)cachedProperties {
	return [[self class] cachedProperties];
}

-(NSDictionary *)lookupProperties {
	return [[self class] lookupProperties];
}

/**
 * Get properties from current entity (SELF). The TYPE of the properties must be inherited from 'AM8ORMEntity'.
 * NSArrays are not included.
 * This code is based from http://code.google.com/p/sqlitepersistentobjects/
 *
 * @return  (NSDictionary *)        - Collection of properties of SELF (entity) with this features:
 *                                  - Key: String(name)         Object: String(type)
 **/
+(NSDictionary *)loadProperties {
	// Recurse up the classes, but stop at NSObject. Each class only reports its own properties, not those inherited from its superclass
	NSMutableDictionary *theProps=nil;
	
    if (classDescendsFrom([self superclass], [AM8ORMEntity class]))
        //    if ([[self superclass] isSubclassOfClass:[AM8ORMEntity class]])
		theProps = (NSMutableDictionary *)[[self superclass] loadProperties];
	else
		theProps = [NSMutableDictionary dictionary];
	
	unsigned int outCount;
	
	objc_property_t *propList = class_copyPropertyList([self class], &outCount);
	
	int i;
	
	// Loop through properties and add declarations for the create
	for (i=0; i < outCount; i++)
	{
        @autoreleasepool {
            objc_property_t * oneProp = propList + i;
            NSString *propName = [NSString stringWithUTF8String:property_getName(*oneProp)];
            NSString *attrs = [NSString stringWithUTF8String: property_getAttributes(*oneProp)];
            NSArray *attrParts = [attrs componentsSeparatedByString:@","];
            
            //ignore the internal properties...
            if ([propName hasPrefix:@"_"]) {
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
                    //				NSString *fieldName = [[attrParts objectAtIndex:[attrParts count] - 1] substringFromIndex:1];
                    //Ignore arrays.
                    if ([propType hasPrefix:@"@"] ) // Object
                    {
                        NSString *className = [propType substringWithRange:NSMakeRange(2, [propType length]-3)];
                        if ([className isEqualToString:_typeNSArray] || [className isEqualToString:_typeNSMutableArray] || [className isEqualToString:_typeNSDictionary] || [className isEqualToString:_typeNSMutableDictionary]) {
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
                    
                    [theProps setObject:@[propType, @([AM8ORMEntity typeForField:propType])] forKey:propName];
                }
            }
        }
	}
	
	free( propList );
	
	return theProps;
}


/**
 * Get properties from current entity (SELF). The TYPE of the propertie must be inherited from 'AM8ORMEntity'.
 * NSArrays are not included.
 * This code is based from http://code.google.com/p/sqlitepersistentobjects/
 *
 * @return  (NSDictionary *)        - Collection of properties of SELF (entity) with this features:
 *                                          * type inherited from 'AM8ORMEntity'
 *                                  - Key: String(name)         Object: String(type)
 **/
+(NSDictionary *)loadLookupProperties {
	// Recurse up the classes, but stop at NSObject. Each class only reports its own properties, not those inherited from its superclass
	NSMutableDictionary *theProps=nil;
	
    if (classDescendsFrom([self superclass], [AM8ORMEntity class]))
        //    if ([[self superclass] isSubclassOfClass:[AM8ORMEntity class]])
		theProps = (NSMutableDictionary *)[[self superclass] loadLookupProperties];
	else
		theProps = [NSMutableDictionary dictionary];
	
	unsigned int outCount;
	
	objc_property_t *propList = class_copyPropertyList([self class], &outCount);
	
	int i;
	
	// Loop through properties and add declarations for the create
	for (i=0; i < outCount; i++)
	{
        @autoreleasepool {
            objc_property_t * oneProp = propList + i;
            NSString *propName = [NSString stringWithUTF8String:property_getName(*oneProp)];
            NSString *attrs = [NSString stringWithUTF8String: property_getAttributes(*oneProp)];
            NSArray *attrParts = [attrs componentsSeparatedByString:@","];
            
            //ignore the internal properties...
            if ([propName hasPrefix:@"_"]) {
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
                    //				NSString *fieldName = [[attrParts objectAtIndex:[attrParts count] - 1] substringFromIndex:1];
                    //Ignore arrays.
                    if ([propType hasPrefix:@"@"] ) // Object
                    {
                        NSString *className = [propType substringWithRange:NSMakeRange(2, [propType length]-3)];
                        if ([className isEqualToString:_typeNSMutableArray] || [className isEqualToString:_typeNSArray] || [className isEqualToString:_typeNSDictionary] || [className isEqualToString:_typeNSMutableDictionary]) {
                            //                        NSDictionary *listsToLoadImmediatly = [self getListsToLoadImmediatly];
                            //                        if (!listsToLoadImmediatly){
                            //                            continue;
                            //                        } else {
                            //                            if (![listsToLoadImmediatly valueForKey:fieldName]){
                            continue;
                            //                            }
                            //                        }
                        }
                        
                        Class theClass = NSClassFromString(className);
                        
                        if (classDescendsFrom(theClass, [AM8ORMEntity class])) {
                            [theProps setObject:@[propType, @([AM8ORMEntity typeForField:propType])] forKey:propName];
                        }
                    }
                }
            }
        }
	}
	
	free( propList );
	return theProps;
}

/**
 * Get properties from current entity (SELF). The TYPE of the properties must be inherited from 'AM8ORMEntity'.
 * NSArrays are not included.
 * This code is based from http://code.google.com/p/sqlitepersistentobjects/
 * If the property is the part ONE in relation ONETOMANY,then this property is added.
 * Example:     Customer 1 -----> N Contact. In 'Contact' we have field 'Parent' (type 'Customer').
 *              The field 'Parent' will be added if 'Contact' is in 'getOneToManyToLoadImmediatly' of type 'Customer'.
 *
 * @return  (NSDictionary *)        - Collection of properties of SELF (entity) with this features:
 *                                          * type inherited from 'AM8ORMEntity'
 *                                          * the property is the key for OneToMany.
 *                                          * AM8ORMEntity (property) 1 ------ SELF (n)
 *                                  - Key: String(name)         Object: String(type)
 **/
+(NSDictionary *)loadLookupOneToManyProperties {
	// Recurse up the classes, but stop at NSObject. Each class only reports its own properties, not those inherited from its superclass
	NSMutableDictionary *theProps=nil;
	
    if (classDescendsFrom([self superclass], [AM8ORMEntity class]))
        //    if ([[self superclass] isSubclassOfClass:[AM8ORMEntity class]])
		theProps = (NSMutableDictionary *)[[self superclass] loadLookupOneToManyProperties];
	else
		theProps = [NSMutableDictionary dictionary];
	
	unsigned int outCount;
	
    NSString *classname = [[[self tableName] stringByReplacingOccurrencesOfString:@"_s" withString:@""] stringByReplacingOccurrencesOfString:@"_" withString:@""];
    
	objc_property_t *propList = class_copyPropertyList([self class], &outCount);
	
	int i;
	
	// Loop through properties and add declarations for the create
	for (i=0; i < outCount; i++)
	{
        @autoreleasepool {
            objc_property_t * oneProp = propList + i;
            NSString *propName = [NSString stringWithUTF8String:property_getName(*oneProp)];
            NSString *attrs = [NSString stringWithUTF8String: property_getAttributes(*oneProp)];
            NSArray *attrParts = [attrs componentsSeparatedByString:@","];
            
            //ignore the internal properties...
            if ([propName hasPrefix:@"_"]) {
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
                    //				NSString *fieldName = [[attrParts objectAtIndex:[attrParts count] - 1] substringFromIndex:1];
                    //Ignore arrays.
                    if ([propType hasPrefix:@"@"] ) // Object
                    {
                        NSString *className = [propType substringWithRange:NSMakeRange(2, [propType length]-3)];
                        if ([className isEqualToString:_typeNSMutableArray] || [className isEqualToString:_typeNSArray] || [className isEqualToString:_typeNSDictionary] || [className isEqualToString:_typeNSMutableDictionary]) {
                            //                        NSDictionary *listsToLoadImmediatly = [self getListsToLoadImmediatly];
                            //                        if (!listsToLoadImmediatly){
                            //                            continue;
                            //                        } else {
                            //                            if (![listsToLoadImmediatly valueForKey:fieldName]){
                            continue;
                            //                            }
                            //                        }
                        }
                        
                        Class theClass = NSClassFromString(className);
                        
                        if (classDescendsFrom(theClass, [AM8ORMEntity class])) {
                            AM8ORMEntity *item = [[theClass alloc] init];
                            NSDictionary *oneToManyRelations = [item getOneToManyToLoadImmediatly];
                            if (oneToManyRelations){
                                for(NSString* type in [oneToManyRelations allValues]){
                                    NSArray *parts = [type componentsSeparatedByString:@","];
                                    NSString *attributeType = [parts objectAtIndex:0];
                                    if ([[self tableName] isEqualToString:attributeType] || [classname isEqualToString:attributeType]){
                                        [theProps setObject:@[propType, @([AM8ORMEntity typeForField:propType])] forKey:propName];
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
	}
	
	free( propList );
	
	return theProps;
}

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
-(NSDictionary *)lookupOneToManyProperties {
	NSString *key = [NSString concatenateStrings:[self tableName],@"lookupOneToMany",nil];
	NSDictionary* theProps = [[AM8DbPropertyCache currentDbCache] value:key];
	
	if (theProps==nil) {
		theProps = [[self class] loadLookupOneToManyProperties];
		[[AM8DbPropertyCache currentDbCache] save:key value:theProps];
	}
    key = nil;
	return theProps;
}

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
+(NSDictionary *)lookupProperties{
	NSString *key = [NSString concatenateStrings:[self tableName],@"lookup",nil];
	NSDictionary* theProps = [[AM8DbPropertyCache currentDbCache] value:key];
	
	if (theProps==nil) {
		theProps = [self loadLookupProperties];
		[[AM8DbPropertyCache currentDbCache] save:key value:theProps];
	}
    key = nil;
	return theProps;
}

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
+(NSDictionary *)cachedProperties{
	NSString *key = [self tableName];
	NSDictionary* theProps = [[AM8DbPropertyCache currentDbCache] value:key];
	
	if (theProps==nil) {
		theProps = [self loadProperties];
		[[AM8DbPropertyCache currentDbCache] save:key value:theProps];
	}
    key = nil;
	return theProps;
}



#pragma mark SqlGeneration

+(NSString *)getTableName: (Class)cls {
	return [NSString stringWithUTF8String:class_getName(cls)];
}

+(NSString *)tableName {
	return [self getTableName:self];
}

-(NSString *)tableName {
	return [[self class] tableName];
}

+(NSString *)relationName {
	return  [[self tableName] stringByAppendingString:_suffixID];
}

/**
 * Get DELETE SQL sentence from SELF entity.
 *
 * @return  (NSString *)  SQL sentence 'DELETE from'
 **/
-(NSString *)getDeleteSql {
	if ([self _am8IsNew]) {
		NSException *e = [NSException
						  exceptionWithName:_dbError
						  reason:@"Try to delete a non-existant record"
						  userInfo:nil];
        AM8NSExceptionDb *f = [[AM8NSExceptionDb alloc] initWithException:e];
        @throw f;
	}
    
	NSString *filter = [NSString stringWithFormat:_idEqualTo, self.Id];
	NSMutableArray *filterList = [NSMutableArray array];
	
	[filterList addObject:filter];
	
	return [AM8SqlGenerator getSQLDelete:[self tableName] filters:filterList];
}

/**
 *  Get DELETE SQL array sentence from SELF entity
 *
 *  @return (NSArray *)  SQL sentence 'DELETE from'
 */
-(NSArray *)getDeleteSqlArray {
    if ([self _am8IsNew]) {
        NSException *e = [NSException
                          exceptionWithName:_dbError
                          reason:@"Try to delete a non-existant record"
                          userInfo:nil];
        AM8NSExceptionDb *f = [[AM8NSExceptionDb alloc] initWithException:e];
        @throw f;
    }
    
    NSString *filter = [NSString stringWithFormat:_idEqualTo, self.Id];
    NSMutableArray *filterList = [NSMutableArray array];
    
    [filterList addObject:filter];
    
    return @[[AM8SqlGenerator getSQLDelete:[self tableName] filters:filterList]];
}

/**
 * Get UPDATE SQL sentence from SELF entity.
 *
 * @return  (NSString *)  SQL sentence 'INSERT OR REPLACE INTO [tablename] ()'
 **/
-(NSString *)getUpdateSql {
	NSDictionary *fieldsAndValues = [self getPropertiesAndValues];
	
	if (!self.Id /*|| self.Id==0*/) {
		[fieldsAndValues setValue:[NSNull null] forKey:_suffixID];
	}
	return [AM8SqlGenerator getSQLInsertUpdate:[self tableName] fieldsAndValues:fieldsAndValues];
}

/**
 * Get UPDATE SQL array sentence from SELF entity.
 *
 * @return  (NSArray *)  SQL sentence 'INSERT OR REPLACE INTO [tablename] ()'
 **/
-(NSArray *)getUpdateSqlArray {
    NSDictionary *fieldsAndValues = [self getPropertiesAndValues];
    
    if (!self.Id /*|| self.Id==0*/) {
        [fieldsAndValues setValue:[NSNull null] forKey:_suffixID];
    }
    return @[[AM8SqlGenerator getSQLInsertUpdate:[self tableName] fieldsAndValues:fieldsAndValues],
             fieldsAndValues];
}

/**
 * Get SELECT SQL sentence from SELF entity.
 *
 * NSArray *orderList = [NSArray arrayWithObjects :@"Field1",@"Field2",nil];
 * NSArray *whereList = [NSArray arrayWithObjects :@"Field1=1",@"Field2='1'",nil];
 * @return  (NSString *)  SQL sentence 'SELECT * FROM [tablename] ORDER BY'
 **/
+(NSString *)getSQLSelect:(NSArray *)whereList
                orderList:(NSArray *)orderList
                    range:(NSRange)range
{
	return [AM8SqlGenerator getSQLSelect:[self tableName]
                                  fields:nil
                                 filters:whereList
                                  orders:orderList
                                   range:range
            ];
}




- (id)mutableCopyWithZone:(NSZone *)zone {
    //ReviewViewer *copy = NSCopyObject(self, 0, zone);
    NSObject *mutableCopy = [[[self class] allocWithZone:zone] init];
    
    if (mutableCopy) {
        NSDictionary *propsAndTypes = [[self class] loadPropertiesAndTypes:NO];
        for (NSString *fieldName in [propsAndTypes  allKeys]) {
            @autoreleasepool {
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
//                    case FIELDTYPE_OBJECT:
//                    {
//                        if (!sqlCopyStackORM) {
//                            sqlCopyStackORM = [NSMutableDictionary dictionary];
//                        }
//                        
//                        NSString *key = [NSString  stringWithFormat:_sCopyStackORM,[self tableName],fieldName,self.Id];
//                        if (sqlCopyStackORM[key]){
//                            sqlCopyStackORM[key] = @([(NSNumber *)sqlCopyStackORM[key] integerValue]  + 1);
//                        } else {
//                            sqlCopyStackORM[key] = @(1);
//                        }
//                        
//                        if ([sqlCopyStackORM[key] integerValue] > 1){
//                            [sqlCopyStackORM removeObjectForKey:key];
//                            [mutableCopy setValue:[self valueForKey:fieldName]
//                                           forKey:fieldName];
//                            continue;
//                        }
//                        
//                        [mutableCopy setValue:[[self valueForKey:fieldName]   mutableCopy]      forKey:fieldName];
//                        break;
//                    }
                    default:{
                        [mutableCopy setValue:[self valueForKey:fieldName]
                                       forKey:fieldName];
                    }
                        break;
                }
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
            @autoreleasepool {
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
//                    case FIELDTYPE_OBJECT:
//                    {
//                        if (!sqlCopyStackORM) {
//                            sqlCopyStackORM = [NSMutableDictionary dictionary];
//                        }
//                        
//                        NSString *key = [NSString  stringWithFormat:_sCopyStackORM,[self tableName],fieldName,self.Id];
//                        if (sqlCopyStackORM[key]){
//                            sqlCopyStackORM[key] = @([(NSNumber *)sqlCopyStackORM[key] integerValue]  + 1);
//                        } else {
//                            sqlCopyStackORM[key] = @(1);
//                        }
//                        
//                        if ([sqlCopyStackORM[key] integerValue] > 1){
//                            [sqlCopyStackORM removeObjectForKey:key];
//                            [copy setValue:[self valueForKey:fieldName]
//                                    forKey:fieldName];
//                            continue;
//                        }
//                        
//                        [copy setValue:[[self valueForKey:fieldName]   copy]
//                                forKey:fieldName];
//                        break;
//                    }
                    default:{
                        [copy setValue:[self valueForKey:fieldName]
                                forKey:fieldName];
                    }
                        break;
                }
            }
        }
    }
    
    return copy;
}


- (id)_mutableCopy {
    id ret = [self mutableCopy];
    sqlCopyStackORM = nil;
    return ret;
}

- (id)_copy {
    id ret = [self copy];
    sqlCopyStackORM = nil;
    return ret;
}

+(id)getNullEntity {
    return [[[self class] alloc] init];
}

-(void)refreshDictionary{
    
}
-(void)refreshDynamicJSONField{
    
}

-(NSMutableDictionary *)toDictionary{
    return nil;
}

-(NSMutableDictionary *)toDictionaryForSent{
    return nil;
}

@end



@implementation AM8ORMEntityTime
@synthesize timeStamp;
@end
