
//
//  FileInterface.m
//  FileInterface
//
//  Created by test on 12/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FileOperation.h"
#import <CommonCrypto/CommonDigest.h>

#define kPhotoFolderCache   @"photoCaches"

@interface FileOperation ()

+ (NSString *)MD5:(NSString *)sender;

+ (NSString *)getFilePathOfCache:(NSString *)strName;

@end

@implementation FileOperation

+ (NSString *)MD5:(NSString *)sender {
    
    if (sender && [sender isKindOfClass:[NSString class]])
    {
        if (0 < sender.length)
        {
            const char *cStr = [sender UTF8String];
            unsigned char result[CC_MD5_DIGEST_LENGTH];
            CC_MD5(cStr,(CC_LONG)strlen(cStr),result);
            
            return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",result[0],result[1],result[2],result[3],result[4],result[5],result[6],
                    result[7],result[8],result[9],result[10],result[11],result[12],result[13],result[14],result[15]];
        }
    }
    
    return @"";
}

//建立图片缓存区域
+ (void)creatFolderForPhotoCache {
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    NSString *strPhoto = [FileOperation getFilePathOfCache:kPhotoFolderCache];
    
    if ([fileManager fileExistsAtPath:strPhoto] == NO)
    {
        [fileManager createDirectoryAtPath:strPhoto withIntermediateDirectories:NO attributes:nil error:nil];
    }
}

//生成图片缓存路径
+ (NSString *)makePhotoCachePath:(NSString *)strName {
    
    NSString *strMD5 = [FileOperation MD5:strName];
    
    if (strMD5 && 0 < strMD5.length)
    {
        NSString *folderPath = [FileOperation getFilePathOfCache:kPhotoFolderCache];
        
        return [folderPath stringByAppendingPathComponent:strMD5];
    }
    
    return nil;
}

//获取移动设备的Cache路径
+ (NSString *)getFilePathOfCache:(NSString *)strName {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:strName];
}

@end
