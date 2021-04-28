//
//  BaseDao.h
//  HabitissimoChallenge
//
//  Created by Eduard Borras Ruiz on 23/4/21.
//

#import "AM8BaseDao.h"
#import "DBManager.h"

#define ACTION @"action"

@protocol BaseDaoPersistence <NSObject>
    @required
        -(id)getModified;
        -(id)getModified:(NSString *)connection;
        -(id)getToDelete:(NSString *)connection;
        -(id)getToDelete;
-(NSString *)getMaxLastModifiedDate:(NSString *)connection;
+(id)sharedInstance;
@end

@interface BaseDao : AM8BaseDao<BaseDaoPersistence>

@end
