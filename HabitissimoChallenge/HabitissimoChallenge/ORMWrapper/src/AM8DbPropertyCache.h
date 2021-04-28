//
//  DbCache.h
//  ORMWrapper
//
//  Created by Eduard Borras Ruiz on 1/12/2020.
//

#import <Foundation/Foundation.h>

@interface AM8DbPropertyCache : NSObject

@property (strong,nonatomic) NSMutableDictionary *propertyCache;

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
+(id)currentDbCache;

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
+(id)sharedInstance;


/**
 *  <#Description#>
 *
 *  @param key <#key description#>
 *
 *  @return <#return value description#>
 */
-(id)value:(NSString *)key;

/**
 *  <#Description#>
 *
 *  @param key  <#key description#>
 *  @param dict <#dict description#>
 */
-(void)save:(NSString *)key value:(id)dict;

/**
 *  <#Description#>
 */
- (void) clear;

@end
