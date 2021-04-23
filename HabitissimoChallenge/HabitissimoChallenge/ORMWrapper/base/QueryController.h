//
//  QueryController.h
//  ORMWrapper
//
//  Created by Eduard Borras Ruiz on 1/12/2020.
//  Copyright (c) 2020 PodoCat. All rights reserved.
//

#import "AM8NSExceptionDb.h"

@interface QueryController : NSObject

+ (id)sharedInstance;


- (NSArray*) selectAsDictionary:(NSString*) sql connection:(NSString*) connection;

- (void) execute:(NSString *)sql connection:(NSString*) connection ;

- (void) executeWithError:(NSString *)sql connection:(NSString*) connection ;

+ (NSString*)formatParameter:(NSObject*)value;

@end
