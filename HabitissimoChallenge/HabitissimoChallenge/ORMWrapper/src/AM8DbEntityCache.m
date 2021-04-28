//
//  DbEntityCache.m
//  ORMWrapper
//
//  Created by Eduard Borras Ruiz on 1/12/2020.
//

#import "AM8DbEntityCache.h"
#import "NSDictionary+BlocksKit.h"



#define MAXCACHE  1000

@interface AM8DbEntityCache()
    //entityCache  save the pair:NSCache    key:nameOfEntity

    @property (strong,nonatomic) NSMutableDictionary *entityCache;
    @property (nonatomic) NSInteger cacheLimit;

    -(void)getRealClassName:(NSString **)pClassString;
@end


@implementation AM8DbEntityCache

@synthesize entityCache, cacheLimit;


-(id)init {
    if ((self = [super init])) {
        self.entityCache = [NSMutableDictionary dictionary];
        self.cacheLimit = 0;
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
    [self.entityCache bk_each:^(NSString *key, NSCache *cache) {
        [cache removeAllObjects];
        cache = nil;
    }];
     
	[self.entityCache removeAllObjects];
}

-(void)clearCache:(NSString *)entity {
    NSLog(@"CLEAR EntityCache [%@]", entity);
	@autoreleasepool {
        NSCache *entityPool0 = self.entityCache[entity];
        NSCache *entityPool1 = self.entityCache[[NSString stringWithFormat:@"%@%@%@",@"_",entity,@"_s"]];
        NSCache *entityPool2 = self.entityCache[[NSString stringWithFormat:@"%@%@",@"_",entity]];
        
        if(entityPool0) [entityPool0 removeAllObjects];
        if(entityPool1) [entityPool1 removeAllObjects];
        if(entityPool2) [entityPool2 removeAllObjects];
        
        entityPool0 = nil;
        entityPool1 = nil;
        entityPool2 = nil;
    }
}

-(void)removeEntityByTableName:(NSString *)classString    Id:(NSInteger)pId {
    [self getRealClassName:&classString];
    
    NSCache *entityPool  = self.entityCache[classString];
    if (!entityPool){
        return;
    }
    
    if([entityPool objectForKey:@(pId)]) {
        [entityPool removeObjectForKey:@(pId)];
    }
    
	return ;
}

- (void)getRealClassName:(NSString **)pClassString {
}

-(AM8ORMEntity *)getEntity:(Class)pClass    Id:(NSInteger)pId {
    NSString * classString = [NSString stringWithUTF8String :class_getName(pClass)];
    [self getRealClassName:&classString];
    
    NSCache *entityPool  = self.entityCache[classString];
    if (!entityPool){
        return nil;
    }
    
	return [entityPool objectForKey:[NSNumber numberWithInteger:pId]];
}

-(void)removeEntity:(Class)pClass    Id:(NSInteger)pId {
    NSString * classString = [NSString stringWithUTF8String :class_getName(pClass)];
    [self getRealClassName:&classString];
    
    NSCache *entityPool = self.entityCache[classString];
    if (!entityPool){
        return;
    }
    
    if([entityPool objectForKey:@(pId)]) {
        [entityPool removeObjectForKey:@(pId)];
    }
    
	return ;
}

-(void)removeEntity:(AM8ORMEntity *)entity {
    NSString * classString = [NSString stringWithFormat:@"%@",[NSString stringWithUTF8String :class_getName([entity class])]];
    [self getRealClassName:&classString];
    
    NSCache *entityPool = self.entityCache[classString];
    if (!entityPool){
        return;
    }
    
    if([entityPool objectForKey:@(entity.Id)]) {
        [entityPool removeObjectForKey:@(entity.Id)];
    }
    
	return ;
}

-(void)setEntity:(AM8ORMEntity *)entity {
    NSString * classString = [entity tableName];
    [self getRealClassName:&classString];
    
    NSCache *entityPool = [self.entityCache objectForKey:classString];
    if (!entityPool){
        entityPool = [[NSCache alloc] init];
        entityPool.countLimit = self.cacheLimit;
        [self.entityCache setObject:entityPool forKey:classString];
    }
    [entityPool setObject:entity forKey:@(entity.Id)];
}


@end
