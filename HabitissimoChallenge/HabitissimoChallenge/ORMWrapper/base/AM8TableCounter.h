//
//  TableCounters.h
//  ORMWrapper
//
//  Created by Eduard Borras Ruiz on 1/12/2020.
//
//  Stores de Counters for the tables. We cannot use 

#import "AM8ORMEntity.h"

@interface AM8TableCounter : AM8ORMEntityTime

@property (nonatomic, strong)   NSString *name;
@property (nonatomic)           NSUInteger lastRow;


@end
