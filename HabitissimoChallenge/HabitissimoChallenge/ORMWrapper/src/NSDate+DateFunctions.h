//
//  NSDate+DateFunctions.h
//  ORMWrapper
//
//  Created by Eduard Borras Ruiz on 1/12/2020.
//  Copyright (c) 2020 PodoCat. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDate (DateFunctions) 

+(NSDate *)dateFromISOString:(NSString *)dateStr;
+(NSDate *)dateFromISOString:(NSString *)dateStr   dateFormat:pDateFormat;

-(NSString *)formatAsISODate;
-(NSString *)formatAsString;

-(NSDate *)addDays:(NSInteger)numDays;

+(NSInteger)daysBetweenDates: (NSDate *)fromDate ToDate:(NSDate *)toDate;
+(NSDate *)addMonths: (NSDate *)toDate Months:(NSInteger)months;
+(NSDate *)dateFromString:(NSString *)strDate;
+(NSDate *)dateWithString:(NSString *)strDate;

-(NSDate *)addMonths: (NSInteger)months;

@end
