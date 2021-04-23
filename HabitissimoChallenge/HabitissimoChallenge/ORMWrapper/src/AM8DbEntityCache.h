//
//  DbEntityCache.h
//  ORMWrapper
//
//  Created by Eduard Borras Ruiz on 1/12/2020.
//  Copyright (c) 2020 PodoCat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "AM8ORMEntity.h"

@class AM8ORMEntity;

@interface AM8DbEntityCache : NSObject

/**
 *  <#Description#>
 *
 *  @param pCacheLimit <#pCacheLimit description#>
 *
 *  @return <#return value description#>
 */
-(id)initWithLimit:(NSInteger)pCacheLimit;

/**
 *  <#Description#>
 *
 *  @param pClass <#pClass description#>
 *  @param pId    <#pId description#>
 *
 *  @return <#return value description#>
 */
-(AM8ORMEntity *)getEntity:(Class)pClass    Id:(NSInteger)pId;

/**
 *  <#Description#>
 *
 *  @param entity <#entity description#>
 */
-(void)setEntity:(AM8ORMEntity *)entity;

/**
 *  <#Description#>
 *
 *  @param pClass <#pClass description#>
 *  @param pId    <#pId description#>
 */
-(void)removeEntity:(Class)pClass    Id:(NSInteger)pId;

/**
 *  <#Description#>
 *
 *  @param entity <#entity description#>
 */
-(void)removeEntity:(AM8ORMEntity *)entity;

/**
 *  <#Description#>
 *
 *  @param classString <#classString description#>
 *  @param pId         <#pId description#>
 */
-(void)removeEntityByTableName:(NSString *)classString    Id:(NSInteger)pId;

/**
 *  <#Description#>
 */
-(void)clearCache;

/**
 *  <#Description#>
 *
 *  @param entity <#entity description#>
 */
-(void)clearCache:(NSString *)entity;


@end
