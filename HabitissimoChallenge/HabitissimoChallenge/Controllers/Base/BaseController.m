//
//  BaseController.h
//  HabitissimoChallenge
//
//  Created by Eduard Borras Ruiz on 23/4/21.
//

#import "BaseController.h"

@implementation BaseController


-(id)getModified {
    return [self getModified:[[AM8DbPool  sharedInstance] defaultPoolName]];
}

-(id)getModified:(NSString *)connection {
    return [((BaseDao *)self.dao)  getModified:connection];
}

-(id)getToDelete {
    return [self getToDelete:[[AM8DbPool  sharedInstance] defaultPoolName]];
}

-(id)getToDelete:(NSString *)connection {
    return [((BaseDao *)self.dao)  getToDelete:connection];
}

-(NSString *)getMaxLastModifiedDate:(NSString *)connection {
    return [((BaseDao *)self.dao)  getMaxLastModifiedDate:connection];
}

@end
