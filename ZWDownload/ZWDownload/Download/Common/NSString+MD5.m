//
//  NSString+MD5.m
//  ZWVideoEditor
//
//  Created by Admin on 2020/4/14.
//  Copyright © 2020 meishubao. All rights reserved.
//

#import "NSString+MD5.h"
#import<CommonCrypto/CommonDigest.h>

@implementation NSString (MD5)

- (instancetype)md5 {
    const char *cStr = [self UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest );
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return  output;
}

@end
