//
//  BaseService.h
//  ORMWrapper
//
//  Created by Eduard Borras Ruiz on 1/12/2020.
//

#import <Foundation/Foundation.h>
#import "AM8BaseDao.h"
#import "AM8EntityRuleValidation.h"


#define _AM8ControllerInit(className)    \
- (id)init { \
    if (self = [super init]) { \
        self.dao = [className##Dao sharedInstance]; \
    } \
\
    return self; \
} \
\
+ (id)sharedInstance { \
    static className##Controller *sharedInstance = nil; \
    static dispatch_once_t once;    \
    dispatch_once(&once, ^{ \
        sharedInstance = [[className##Controller alloc] init:[className##Dao sharedInstance]]; \
    }); \
    return sharedInstance; \
}



@interface AM8BaseController : NSObject<AM8BaseDaoPersistence>

@property (nonatomic, strong)   AM8BaseDao *dao;

/**
 *  Constructor for any Controller. This Controller must contain the business rules in DAO operations.
 *  The developer can save time using the macro "_AM8ControllerInit(EntityName)" to init the Controller
 *
 *  @param pClass Class of entity to manage.
 *
 *  @return the Controller created.
 */
-(id)init:(AM8BaseDao *)pDao;

@end
