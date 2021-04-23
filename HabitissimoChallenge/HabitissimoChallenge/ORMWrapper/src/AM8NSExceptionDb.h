//
//  NSExceptionDB.h
//  ORMWrapper
//
//  Created by Eduard Borras Ruiz on 1/12/2020.
//  Copyright (c) 2020 PodoCat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AM8NSExceptionDb : NSException

-(id) initWithException:(NSException *)exception;

@end
