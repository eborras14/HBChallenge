//
//  EntityRuleValidation.h
//  ORMWrapper
//
//  Created by Eduard Borras Ruiz on 1/12/2020.
//

#import <Foundation/Foundation.h>

@interface AM8EntityRuleValidation : NSObject

    @property (nonatomic, strong)       NSString*   message;
    @property (nonatomic, strong)       NSString*   title;
    @property (nonatomic)           BOOL        isOk;

@end
