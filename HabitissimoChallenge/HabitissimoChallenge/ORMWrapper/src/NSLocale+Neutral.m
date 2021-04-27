//
//  NSLocale+Neutral.m
//  ORMWrapper
//
//  Created by Eduard Borras Ruiz on 1/12/2020.
//

#import "NSLocale+Neutral.h"

@implementation NSLocale (Neutral)

+(NSLocale *) NEUTRAL_LOCALE
{
    static NSLocale *US_LOCALE = nil;
    
    if (!US_LOCALE) {
        US_LOCALE = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    }
    
    return US_LOCALE;
}

@end
