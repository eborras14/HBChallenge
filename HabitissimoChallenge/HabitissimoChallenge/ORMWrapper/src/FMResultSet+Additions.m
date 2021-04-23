//
//  FMResultSet+Additions.m
//  ORMWrapper
//
//  Created by Eduard Borras Ruiz on 1/12/2020.
//  Copyright (c) 2020 PodoCat. All rights reserved.
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
