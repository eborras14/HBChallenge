//
//  AM8DbPool.h
//  ORMWrapper
//
//  Created by Eduard Borras Ruiz on 1/12/2020.
//  Copyright (c) 2020 PodoCat. All rights reserved.
//

#import "AM8DbPool.h"
#import "AM8NSExceptionDb.h"

@implementation AM8DbPool

@synthesize pool,paths,defaultPoolName;

- (id)init {
    if ((self = [super init])) {
        pool = [[NSMutableDictionary alloc] init];
		paths = [[NSMutableDictionary alloc] init];
        self.defaultPoolName = @"default";
    }
	
	return self;
}

- (void)dealloc
{ 
	NSLog(@"Releasing pool");
	for (AM8Db *db in self.pool) {
		[db closeDataBase];
	}
}

#pragma mark Global access
+ (AM8DbPool *)sharedInstance  /*:(Class)dbpoolclass*/ {
    static AM8DbPool *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[AM8DbPool alloc] init];
    });
    
    return sharedInstance;
}


#pragma mark Pooling methods
- (AM8Db *)getConnection {
	return [self getConnection:self.defaultPoolName];
}

- (BOOL) existConnection:(NSString *)name {
	AM8Db *db = self.pool[name];

//#ifdef __DEBUG__
//    NSLog(@"**** debugging SHOW POOL CONTENT *****");
//    [self.pool show];
//#endif
    
	if (!db) {
		return NO;
	} else {
		return YES;
	}
}

- (AM8Db *)getConnection:(NSString *)name {
	if (![self existConnection:name]) {
		NSException *e = [NSException						  
						  exceptionWithName:_dbError						  
						  reason:[NSString stringWithFormat:@"The database %@ is not set in the pool of connections",name]
						  userInfo:nil];
        AM8NSExceptionDb *f = [[AM8NSExceptionDb alloc] initWithException:e];
        @throw f;
	}

	return self.pool[name];
}

- (AM8Db *)addConnection:(NSString *)name   path:(NSString *)path {
	AM8Db *db = self.pool[name];
    
	if (!db) {
		db = [[AM8Db alloc] initWithName:path];
		
		if ([self.defaultPoolName isEqualToString:@"default"]){
            self.defaultPoolName = name;
        }
        
        NSLog(@"Adding %@ to pool",name);
		@synchronized(self) {
			[self.pool  setObject:db   forKey:name];
			[self.paths setObject:path forKey:name];
		}
	} else {
        NSLog(@"%@ already exist on pool",name);
	}
    
	return db;
}

- (AM8Db *)addConnection:(NSString *)name
                    path:(NSString *)path
                maxDeepLevel:(NSUInteger)maxDeepLevel
maximCascadeRecursiveLevel:(NSUInteger)maximCascadeRecursiveLevel
{
	AM8Db *db = self.pool[name];
    
	if (!db) {
		db = [[AM8Db alloc] initWithName:path maxDeepLevel:maxDeepLevel  maximCascadeRecursiveLevel:maximCascadeRecursiveLevel];
		
		if ([self.defaultPoolName isEqualToString:@"default"]){
            self.defaultPoolName = name;
        }
        
        NSLog(@"Adding %@ to pool",name);
		@synchronized(self) {
			[self.pool  setObject:db   forKey:name];
			[self.paths setObject:path forKey:name];
		}
	} else {
        NSLog(@"%@ already exist on pool",name);
	}
    
	return db;
}

- (AM8Db *)addConnection:(NSString *)name
                   class:(Class)pClass
                    path:(NSString *)path
            maxDeepLevel:(NSUInteger)maxDeepLevel
maximCascadeRecursiveLevel:(NSUInteger)maximCascadeRecursiveLevel
{
	AM8Db *db = [self.pool objectForKey:name];
    
	if (!db) {
		db = [[pClass alloc] initWithName:path
                             maxDeepLevel:maxDeepLevel
               maximCascadeRecursiveLevel:maximCascadeRecursiveLevel];
        
		if ([self.defaultPoolName isEqualToString:@"default"]){
            self.defaultPoolName = name;
        }
        
        NSLog(@"Adding %@ to pool",name);
		@synchronized(self) {
			[self.pool  setObject:db   forKey:name];
			[self.paths setObject:path forKey:name];
		}
	} else {
        NSLog(@"%@ already exist on pool",name);
	}
    
	return db;
}

- (void)setConnection:(NSString *)name   path:(NSString *)path   db:(AM8Db *)pDb {
	AM8Db *db = self.pool[name];
    
	if (!db) {
        NSLog(@"Setting %@ to pool",name);
		@synchronized(self) {
			[self.pool  setObject:pDb   forKey:name];
			[self.paths setObject:path forKey:name];
		}
	} else {
        NSLog(@"%@ already exist on pool",name);
	}
    
}



- (AM8Db *)cloneConnection:(NSString *)oldName newName:(NSString *)newName {
	NSString *path = self.paths[oldName];

	if (!path) {
		NSException *e = [NSException						  
						  exceptionWithName:_dbError						  
						  reason:@"The database is not set globally"
						  userInfo:nil];
        AM8NSExceptionDb *f = [[AM8NSExceptionDb alloc] initWithException:e];
        @throw f;
	}
	
	return [self addConnection:newName path:path];
}

- (AM8Db *)cloneConnection:(NSString *)newName {
	NSString *path = self.paths[self.defaultPoolName];
    
	if (!path) {
		NSException *e = [NSException
						  exceptionWithName:_dbError
						  reason:@"The database is not set globally"
						  userInfo:nil];
        AM8NSExceptionDb *f = [[AM8NSExceptionDb alloc] initWithException:e];
        @throw f;
	}
	
	return [self addConnection:newName path:path];
}

- (void) closeDatabases
{
    for (id key in self.pool) {
        [self closeDatabase:key];
    }
}

- (void)closeDatabase:(NSString *)key
{
    [[self getConnection:key] clearCache];
    [[self getConnection:key] closeDataBase];
    [self.pool removeObjectForKey:key];
    [self.paths removeObjectForKey:key];
}

- (void) clear {
	@synchronized(self) {
        [self closeDatabases];
        
		[self.pool removeAllObjects];
		[self.paths removeAllObjects];
	}	
}

@end
