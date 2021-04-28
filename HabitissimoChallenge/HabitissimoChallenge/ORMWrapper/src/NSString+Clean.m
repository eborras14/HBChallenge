//
//  NSString+Clean.m
//  ORMWrapper
//
//  Created by Eduard Borras Ruiz on 1/12/2020.
//

#import "NSString+Clean.h"


@implementation NSString (clean) 

+ (NSString *) arrayToString: (NSArray *)array {
	NSMutableString * list = [NSMutableString string];
	
	int count = [array count];
	int i;
	
	for (i = 0; i < count; i++) { 
		if (i + 1 == count) {
			[list appendFormat:@"%@", [array objectAtIndex:i] ];
		}
		else {
			[list appendFormat:@"%@, ", [array objectAtIndex:i] ];
		}
	} 
	
	return list;
}

- (NSString *) trim {
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

@end
