//
//  NSString+Clean.h
//  ORMWrapper
//
//  Created by Eduard Borras Ruiz on 1/12/2020.
//  Copyright (c) 2020 PodoCat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (clean) 

+ (NSString *) arrayToString: (NSArray *)array;
- (NSString *) trim;

@end
