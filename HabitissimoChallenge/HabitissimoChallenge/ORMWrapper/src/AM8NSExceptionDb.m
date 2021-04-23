//
//  NSExceptionDB.m
//  ORMWrapper
//
//  Created by Eduard Borras Ruiz on 1/12/2020.
//  Copyright (c) 2020 PodoCat. All rights reserved.
//

#import "AM8NSExceptionDb.h"

@implementation AM8NSExceptionDb

-(id) initWithException:(NSException *)exception {
    
    //self = [super initWithName: name reason:@"" userInfo:nil];
    if (self =[super initWithName:[exception name]
                           reason:[exception reason]
                         userInfo:[exception userInfo]]) {
        
    }
    
    return self;
}

@end
