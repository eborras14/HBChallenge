//
//  DBManager.h
//  HabitissimoChallenge
//
//  Created by Eduard Borras Ruiz on 23/04/2021.
//

#import "AM8Db.h"
#import "_AM8SynchroORMEntity.h"

@interface DBManager : AM8Db


/**
 *  <#Description#>
 */
-(void)createTables;


/**
 *  <#Description#>
 */
+(void)fullRecoveryDB;


/**
 *  <#Description#>
 *
 *  @return <#return value description#>
 */
+(NSString *)getDbPath;


/**
 *  <#Description#>
 */
+(void)createDataBase;


/**
 *  <#Description#>
 */
+(void)configureDb;

@end
