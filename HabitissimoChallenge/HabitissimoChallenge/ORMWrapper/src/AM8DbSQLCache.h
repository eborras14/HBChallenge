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

@interface AM8DbSQLCache : NSObject


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
 */
-(void)clearCache;

/**
 *  <#Description#>
 *
 *  @param entity <#entity description#>
 */
-(void)clearCache:(NSString *)entity;

/**
 *  <#Description#>
 *
 *  @param pClassString <#pClassString description#>
 */
-(void)getRealClassName:(NSString **)pClassString;

/**
 *  <#Description#>
 *
 *  @param pClass <#pClass description#>
 *  @param pSQL   <#pSQL description#>
 *
 *  @return <#return value description#>
 */
-(NSMutableArray *)getData:(Class)pClass
         SQL:(NSString *)pSQL;

/**
 *  <#Description#>
 *
 *  @param pClass <#pClass description#>
 *  @param pSQL   <#pSQL description#>
 *  @param pData  <#pData description#>
 */
-(void)setData:(Class)pClass
           SQL:(NSString *)pSQL
          data:(NSMutableArray *)pData;

@end
