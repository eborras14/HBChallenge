//
//  _AM8SynchroORMEntity.m
//  ORMWrapper
//
//  Created by Eduard Borras Ruiz on 1/12/2020.
//

#import "_AM8SynchroORMEntity.h"
#import "AM8TableCounter.h"

@implementation _AM8SynchroORMEntity

static NSString * const _name    = @"name";

-(NSUInteger)nextRowId {
    AM8Db *db = [[AM8DbPool sharedInstance] getConnection];
    NSString *className = [self tableName];
    NSString *tableName = [className stringByReplacingOccurrencesOfString:_subguion_s withString:_emptyString];
    tableName = [tableName stringByReplacingOccurrencesOfString:_subguion withString:_emptyString];
    
	AM8TableCounter *tableCounter = [db findByFieldAndValue:[AM8TableCounter class] fieldName:_name value:tableName];
    
    if (tableCounter == nil) {
        tableCounter = [[AM8TableCounter alloc] init];
        tableCounter.name = tableName;
        tableCounter.lastRow = 0;
    }
    
    tableCounter.lastRow ++;
    [db save:tableCounter];
    
    return tableCounter.lastRow;
}

@end
