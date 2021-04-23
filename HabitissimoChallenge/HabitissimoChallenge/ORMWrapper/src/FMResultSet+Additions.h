//
//  FMResultSet+Additions.h
//  ORMWrapper
//
//  Created by Eduard Borras Ruiz on 1/12/2020.
//  Copyright (c) 2020 PodoCat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMResultSet.h>
//#import "FMResultSet.h"

@interface FMResultSet (info) 

- (NSArray *) columnsName;

@end
