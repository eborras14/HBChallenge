//
//  NSData+AES256.h
//  ORMWrapper
//
//  Created by Eduard Borras Ruiz on 1/12/2020.
//

#import <Foundation/Foundation.h>

@interface  NSData (AES256)

- (NSData *)AES256EncryptWithKey:(NSString *)key iv:(NSData *)iv;

- (NSData *)AES256DecryptWithKey:(NSString *)key iv:(NSData *)iv;

@end
