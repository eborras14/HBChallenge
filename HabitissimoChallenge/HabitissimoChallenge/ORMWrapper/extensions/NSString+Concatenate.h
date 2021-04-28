//
//  NSString+Concatenate.h
//  ORMWrapper
//
//  Created by Eduard Borras Ruiz on 1/12/2020.
//

#import <Foundation/Foundation.h>

@interface NSString (Concatenate)

+ (NSString *)concatenateStrings:(NSString *)firstString, ... NS_REQUIRES_NIL_TERMINATION;

+ (NSString *)concatenateByCommaForDictList:(NSArray *)list byKey:(NSString *)key;

@end
