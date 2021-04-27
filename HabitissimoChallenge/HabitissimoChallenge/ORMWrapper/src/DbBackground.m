//
//  DbBackground.h
//  ORMWrapper
//
//  Created by Eduard Borras Ruiz on 1/12/2020.
//

#import "DbBackground.h"

@implementation DbBackground

@synthesize sql, db, delegate;

-(id)initWithSQL:(NSString *)theSql name:(NSString *)name 
{
    if ((self = [super init])) {
//		self.sql = theSql;
//		self.db = [[AM8DbPool sharedInstance] getConn:name];
    }

	return self;
}


-(void)main {
//	NSArray *results = [self.db loadAsDictArray:sql];
//
//	if( [delegate respondsToSelector:@selector(handleSqlResult:)])
//	{
//		[delegate performSelectorOnMainThread:@selector(handleSqlResult:) withObject:results waitUntilDone:YES];
//	}	
}

@end
