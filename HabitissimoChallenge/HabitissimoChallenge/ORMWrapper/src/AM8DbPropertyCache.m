//
//  DbCache.m
//  ORMWrapper
//
//  Created by Eduard Borras Ruiz on 1/12/2020.
//  Copyright (c) 2020 PodoCat. All rights reserved.
//

#import "AM8DbPropertyCache.h"

@implementation AM8DbPropertyCache

@synthesize propertyCache;

//static DbCache *sharedInstance = nil;

- (id)init {
    if ((self = [super init])) {
        self.propertyCache = [NSMutableDictionary dictionary];
    }
	
	return self;
}


#pragma mark Utilities
- (void) clear {
	[self.propertyCache removeAllObjects];
}

-(id) value:(NSString *)key {
	return self.propertyCache[key];	
}

-(void) save:(NSString *)key value:(id)dict {
	[self.propertyCache setObject:dict forKey:key];
}

#pragma mark Global access
+(id)currentDbCache {
//    @synchronized(self)
//    {
//        if (sharedInstance == nil)
//			sharedInstance = [[DbCache alloc] init];
//    }
    return [self sharedInstance];
}
+ (AM8DbPropertyCache *)sharedInstance
{
    static AM8DbPropertyCache *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AM8DbPropertyCache alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

@end
