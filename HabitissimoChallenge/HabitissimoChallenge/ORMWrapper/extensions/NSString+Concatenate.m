//
//  NSString+Concatenate.m
//  ORMWrapper
//
//  Created by Eduard Borras Ruiz on 1/12/2020.
//  Copyright (c) 2020 PodoCat. All rights reserved.
//

#import "NSString+Concatenate.h"

@implementation NSString (Concatenate)

+ (NSString *)concatenateStrings:(NSString *)firstString, ...
{
	NSMutableString *outputString = [NSMutableString string];
	va_list arguments;
	va_start(arguments, firstString);
	for (NSString *anArgument = firstString; anArgument != nil; anArgument = va_arg(arguments, NSString*)) {
		if ([anArgument isKindOfClass:[NSString class]]) {
			[outputString appendString:anArgument];
		}
	}
	va_end(arguments);
	
	return [NSString stringWithString:outputString];
}

+ (NSString *)concatenateByCommaForDictList:(NSArray *)list byKey:(NSString *)key {
    
    NSInteger count = 0;
    NSString *concatenatedString = @"";
    
    for (NSDictionary *item in list) {
        
        if((count == (list.count- 1) && (![concatenatedString isEqualToString:@""] || !concatenatedString)) || (![concatenatedString isEqualToString:@""] || !concatenatedString)) {
            
            concatenatedString = [NSString stringWithFormat:@"%@,%@",concatenatedString,item[key]];
            
        }else {
            
            concatenatedString = [NSString stringWithFormat:@"%@",item[@"id"]];
        }
        
        count++;
    }
    
    return concatenatedString;
}

@end
