//
//  DbBackground.h
//  ORMWrapper
//
//  Created by Eduard Borras Ruiz on 1/12/2020.
//

#import "AM8DbPool.h"

@interface DbBackground : NSOperation {

}

@property (nonatomic, strong) NSString *sql;
@property (nonatomic, strong) AM8Db *db;
@property (nonatomic, strong) id delegate;

-(id)initWithSQL:(NSString *)theSql name:(NSString *)name;

@end
