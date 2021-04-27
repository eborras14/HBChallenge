//
//  BaseDao.m
//  HabitissimoChallenge
//
//  Created by Eduard Borras Ruiz on 23/4/21.
//

#import "BaseDao.h"

@implementation BaseDao

-(id)getModified:(NSString *)connection {
	NSString *sql = [NSString stringWithFormat: @"SELECT * FROM [%@] WHERE %@ >= %@", [AM8ORMEntity getTableName:self.class], ACTION, [AM8SqlGenerator addQuotes:[NSNumber numberWithInt:RecordTypeDelete]]];
    return [self findAndFill:sql  connection:connection];
}

-(id)getModified {
    return [self getModified:[[AM8DbPool  sharedInstance] defaultPoolName]];
}

-(id)getToDelete:(NSString *)connection {
    NSString *sql = [NSString stringWithFormat: @"SELECT * FROM [%@] WHERE %@ = %@", [AM8ORMEntity getTableName:self.class], ACTION, [AM8SqlGenerator addQuotes:[NSNumber numberWithInt:RecordTypeDelete]]];
    return [self findAndFill:sql  connection:connection];
}

-(id)getToDelete {
    return [self getToDelete:[[AM8DbPool sharedInstance] defaultPoolName]];
}

-(NSString *)getMaxLastModifiedDate:(NSString *)connection {
    NSString *tableName = [AM8ORMEntity getTableName:self.class];
    
    NSString *max = [((AM8Db *)[[AM8DbPool  sharedInstance] getConnection:connection]).theDb stringForQuery:[NSString stringWithFormat:@"SELECT max(LastModifiedDate) FROM [%@] ",tableName]];
    [[[AM8DbPool  sharedInstance] getConnection:connection] checkError];
    
    return max;
}

@end
