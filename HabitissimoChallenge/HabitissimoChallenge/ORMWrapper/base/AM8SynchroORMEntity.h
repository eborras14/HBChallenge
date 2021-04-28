//
//  AM8SynchroORMEntity.h
//  ORMWrapper
//
//  Created by Eduard Borras Ruiz on 1/12/2020.
//

#import "AM8ORMEntity.h"

static NSString * const k_FORMAT_DATE =  @"yyyy-MM-dd'T'HH:mm:ss'.'SSSZ";
static NSString * const k_FORMAT_SHORT_DATE =  @"yyyy-MM-dd";
static NSString * const k_LOCALE_DATE =  @"en_GB"; // to force 24h style

typedef enum _Mode {
    modeView = 1,
    modeEdit
} Mode;

@interface AM8SynchroORMEntity : AM8ORMEntityTime {

}

@property (nonatomic, strong) NSString *idServer;
@property (nonatomic) RecordTypeAction action;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *errorCode;
@property (nonatomic, strong) NSString *statusDesc;
@property (nonatomic, strong) NSString *lastModifiedDate;

- (id)getDynamicValue:(NSString *)fieldName
                 type:(NSString *)type
               detail:(NSUInteger)detail
                 mode:(Mode)mode;

@end
