//
//  Validators.h
//  ORMWrapper
//
//  Created by Eduard Borras Ruiz on 1/12/2020.
//  Copyright (c) 2020 PodoCat. All rights reserved.
//

#import "NSDate+DateFunctions.h"

//Generic validators

@interface Validators : NSObject {

}

+(BOOL)validateNotEmpty:(id *)ioValue propName:(NSString *)name error:(NSError **)outError;
+(BOOL)validateCompareDate:(NSComparisonResult)compare propName:(NSString *)name dateOne:(NSDate *)dateOne dateTwo:(NSDate *)dateTwo 	error:(NSError **)outError;
+(BOOL)validateRegex:(id *)ioValue regex:(NSString *)regex propName:(NSString *)name error:(NSError **)outError;


@end
