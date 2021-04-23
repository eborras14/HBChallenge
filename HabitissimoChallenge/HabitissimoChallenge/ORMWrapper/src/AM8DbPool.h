//
//  AM8DbPool.h
//  ORMWrapper
//
//  Created by Eduard Borras Ruiz on 1/12/2020.
//  Copyright (c) 2020 PodoCat. All rights reserved.
//

#import "AM8Db.h"
#import "CWLSynthesizeSingleton.h"

@class AM8Db;

@interface AM8DbPool : NSObject {
		
}

@property (strong) NSMutableDictionary *pool;
@property (strong) NSMutableDictionary *paths;
@property (strong) NSString *defaultPoolName;

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
+(AM8DbPool *)sharedInstance ;

/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
-(AM8Db *) getConnection;

/**
 *  <#Description#>
 *
 *  @param name <#name description#>
 *
 *  @return <#return value description#>
 */
-(AM8Db *) getConnection:(NSString *)name;


/**
 *  <#Description#>
 *
 *  @param name <#name description#>
 *
 *  @return <#return value description#>
 */
-(BOOL)existConnection:(NSString *)name;


/**
 *  <#Description#>
 *
 *  @param name                       <#name description#>
 *  @param path                       <#path description#>
 *  @param maxDeepLevel               <#maxDeepLevel description#>
 *  @param maximCascadeRecursiveLevel <#maximCascadeRecursiveLevel description#>
 *
 *  @return <#return value description#>
 */
- (AM8Db *)addConnection:(NSString *)name
                    path:(NSString *)path
            maxDeepLevel:(NSUInteger)maxDeepLevel
maximCascadeRecursiveLevel:(NSUInteger)maximCascadeRecursiveLevel;

/**
 *  <#Description#>
 *
 *  @param name <#name description#>
 *  @param path <#path description#>
 *
 *  @return <#return value description#>
 */
- (AM8Db *) addConnection:(NSString *)name
                     path:(NSString *)path  ;

/**
 *  <#Description#>
 *
 *  @param name                       <#name description#>
 *  @param pClass                     <#pClass description#>
 *  @param path                       <#path description#>
 *  @param maxDeepLevel               <#maxDeepLevel description#>
 *  @param maximCascadeRecursiveLevel <#maximCascadeRecursiveLevel description#>
 *
 *  @return <#return value description#>
 */
- (AM8Db *)addConnection:(NSString *)name
                   class:(Class)pClass
                    path:(NSString *)path
            maxDeepLevel:(NSUInteger)maxDeepLevel
maximCascadeRecursiveLevel:(NSUInteger)maximCascadeRecursiveLevel;

/**
 *  <#Description#>
 *
 *  @param name <#name description#>
 *  @param path <#path description#>
 *  @param pDb  <#pDb description#>
 */
- (void) setConnection:(NSString *)name
                  path:(NSString *)path
                    db:(AM8Db *)pDb;


/**
 *  <#Description#>
 *
 *  @param oldName <#oldName description#>
 *  @param newName <#newName description#>
 *
 *  @return <#return value description#>
 */
-(AM8Db *) cloneConnection:(NSString *)oldName
             newName:(NSString *)newName;

/**
 *  <#Description#>
 *
 *  @param newName <#newName description#>
 *
 *  @return <#return value description#>
 */
-(AM8Db *) cloneConnection:(NSString *)newName;

/**
 *  <#Description#>
 *
 *  @param key <#key description#>
 */
- (void) closeDatabase:(NSString *)key;

/**
 *  <#Description#>
 */
- (void) closeDatabases;

/**
 *  <#Description#>
 */
- (void) clear;

@end
