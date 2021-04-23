//
//  QueryController.m
//  ORMWrapper
//
//  Created by Eduard Borras Ruiz on 1/12/2020.
//  Copyright (c) 2020 PodoCat. All rights reserved.
//

#import "QueryController.h"
#import "AM8DbPool.h"

@implementation QueryController

+ (id)sharedInstance {
    static QueryController *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[QueryController alloc] init];
    });
    return sharedInstance;
}

- (NSArray*) selectAsDictionary:(NSString*) sql connection:(NSString*) connection {
    AM8Db* db = [[AM8DbPool sharedInstance] getConnection:connection];
    return [db loadAsDictArray:sql];
}

- (void) execute:(NSString *)sql connection:(NSString*) connection {
    AM8Db* db = [[AM8DbPool sharedInstance] getConnection:connection];
    [db execute:sql];
}

- (void) executeWithError:(NSString *)sql connection:(NSString*) connection {
    @try {
        AM8Db* db = [[AM8DbPool sharedInstance] getConnection:connection];
        [db execute:sql];
    }
    @catch (AM8NSExceptionDb *exception) {
        @throw exception;
    }
}

+ (NSString*)formatParameter:(NSObject*)value{
    return [AM8SqlGenerator addQuotes:value];
}


@end
