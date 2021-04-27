//
//  FMResultSet+Additions.m
//  ORMWrapper
//
//  Created by Eduard Borras Ruiz on 1/12/2020.
//

#import "FMResultSet+Additions.h"

@implementation FMResultSet (info)

- (NSArray *) columnsName {
	if (!self.columnNameToIndexMap) {
        [self columnIndexForName:@"id"];
    }
    
	return [self.columnNameToIndexMap allKeys];
}

@end
