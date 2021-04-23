//
//  DbEntityCache.m
//  ORMWrapper
//
//  Created by Eduard Borras Ruiz on 1/12/2020.
//  Copyright (c) 2020 PodoCat. All rights reserved.
//

#import "AM8DbSQLCache.h"
#import "NSDictionary+BlocksKit.h"


#define MAXCACHE  20000

@interface AM8DbSQLCache()
    //entityCache  save the pair:NSCache    key:nameOfEntity

    @property (strong,nonatomic) NSMutableDictionary *SQLCache;
    @property (nonatomic) NSInteger cacheLimit;

    -(void)getRealClassName:(NSString **)pClassString;
@end


@implementation AM8DbSQLCache

@synthesize SQLCache, cacheLimit;


-(id)init {
    if ((self = [super init])) {
        self.SQLCache = [NSMutableDictionary dictionary];
    }
	
	return self;
}

-(id)initWithLimit:(NSInteger)pCacheLimit {
    if ((self = [self init])) {
        self.cacheLimit = pCacheLimit;
    }
	
	return self;
}


#pragma mark Utilities
-(void)clearCache {
    [self.SQLCache bk_each:^(NSString *key, NSCache *cache) {
        [cache removeAllObjects];
        cache = nil;
    }];
    
	[self.SQLCache removeAllObjects];
}

-(void)clearCache:(NSString *)entity {
	@autoreleasepool {
        NSCache *entitySQLCache0 = self.SQLCache[entity];
        NSCache *entitySQLCache1 = self.SQLCache[[NSString stringWithFormat:@"%@%@%@",@"_",entity,@"_s"]];
        NSCache *entitySQLCache2 = self.SQLCache[[NSString stringWithFormat:@"%@%@",@"_",entity]];
        
        if(entitySQLCache0) [entitySQLCache0 removeAllObjects];
        if(entitySQLCache1) [entitySQLCache1 removeAllObjects];
        if(entitySQLCache2) [entitySQLCache2 removeAllObjects];
        
        entitySQLCache0 = nil;
        entitySQLCache1 = nil;
        entitySQLCache2 = nil;
    }
}


- (void)getRealClassName:(NSString **)pClassString {
}

-(NSMutableArray *)getData:(Class)pClass
         SQL:(NSString *)pSQL    {
    NSString * classString = [NSString stringWithFormat:@"%@",[NSString stringWithUTF8String :class_getName(pClass)]];
    [self getRealClassName:&classString];
    
    NSCache *entitySQLcache = self.SQLCache[classString];
    if (!entitySQLcache){
        return nil;
    }
    
	return [entitySQLcache objectForKey:pSQL];
}


-(void)setData:(Class)pClass
           SQL:(NSString *)pSQL
          data:(NSMutableArray *)pData {
    NSString * classString = [NSString stringWithFormat:@"%@",[NSString stringWithUTF8String :class_getName(pClass)]];
    [self getRealClassName:&classString];
    
    NSCache *entitySQLcache = [self.SQLCache objectForKey:classString];
    if (!entitySQLcache){
        entitySQLcache = [[NSCache alloc] init];
        entitySQLcache.countLimit = self.cacheLimit;
        [self.SQLCache setObject:entitySQLcache forKey:classString];
    }
    [entitySQLcache setObject:pData forKey:pSQL];
}

@end
