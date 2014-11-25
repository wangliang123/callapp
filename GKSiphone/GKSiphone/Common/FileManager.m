//
//  FileManager.m
//  MarketWork
//
//  Created by zftank on 14-7-9.
//  Copyright (c) 2014年 MarketWork. All rights reserved.
//

#import "FileManager.h"
#import <CommonCrypto/CommonDigest.h>

#define kAccountFilePath    @"AccountFilePath"
#define kFileFolderPath     @"fileFolderPath"

@implementation FileManager

+ (NSString *)MD5:(NSString *)sender {
    
    if (sender && [sender isKindOfClass:[NSString class]])
    {
        if (0 < sender.length)
        {
            const char *cStr = [sender UTF8String];
            unsigned char result[CC_MD5_DIGEST_LENGTH];
            CC_MD5(cStr,(CC_LONG)strlen(cStr),result);
            
            return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                    result[0],result[1],result[2],result[3],result[4],result[5],result[6],result[7],result[8],
                    result[9],result[10],result[11],result[12],result[13],result[14],result[15]];
        }
    }
    
    return @"";
}

+ (NSString *)getFilePath:(NSString*)strName {
    
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:strName];
}

+ (NSString *)getFilePathOfCache:(NSString *)strName {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:strName];
}

+ (NSString *)getFilePathOfLibrary:(NSString *)strName {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask,YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:strName];
}


+ (BOOL)setData:(id)object forKey:(NSString *)key operator:(Operation)location {
    
    if (object && key && [key isKindOfClass:[NSString class]])
    {
        NSString *folderPath = nil;
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        
        if (location == Document)
        {
            folderPath = [FileManager getFilePath:kFileFolderPath];
        }
        else if (location == UserDefaults)
        {
            folderPath = [FileManager getFilePathOfLibrary:kFileFolderPath];
        }
        else if (location == LoginUserDocument)
        {
            folderPath = [FileManager getFilePath:kAccountFilePath];
        }
        else if (location == LoginUserDefaults)
        {
            folderPath = [FileManager getFilePathOfLibrary:kAccountFilePath];
        }
        
        if ([fileManager fileExistsAtPath:folderPath] == NO)
        {
            [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:nil];
        }
        
        NSString *filePath = [folderPath stringByAppendingPathComponent:key];
        
        NSData *saveSource = [NSKeyedArchiver archivedDataWithRootObject:object];
        
        return [saveSource writeToFile:filePath atomically:YES];
    }
    
    return NO;
}

+ (id)obtainDataForKey:(NSString *)key operator:(Operation)location {
    
    if (key && [key isKindOfClass:[NSString class]])
    {
        NSString *folderPath = nil;
        
        if (location == Document)
        {
            folderPath = [FileManager getFilePath:kFileFolderPath];
        }
        else if (location == UserDefaults)
        {
            folderPath = [FileManager getFilePathOfLibrary:kFileFolderPath];
        }
        else if (location == LoginUserDocument)
        {
            folderPath = [FileManager getFilePath:kAccountFilePath];
        }
        else if (location == LoginUserDefaults)
        {
            folderPath = [FileManager getFilePathOfLibrary:kAccountFilePath];
        }
        
        NSString *filePath = [folderPath stringByAppendingPathComponent:key];

        NSData *dataSource = [NSData dataWithContentsOfFile:filePath];
        
        if (dataSource)
        {
            return [NSKeyedUnarchiver unarchiveObjectWithData:dataSource];
        }
    }
    
    return nil;
}

+ (BOOL)removeDataForKey:(NSString *)key operator:(Operation)location {
    
    if (key && [key isKindOfClass:[NSString class]])
    {
        NSString *folderPath = nil;
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        
        if (location == Document)
        {
            folderPath = [FileManager getFilePath:kFileFolderPath];
        }
        else if (location == UserDefaults)
        {
            folderPath = [FileManager getFilePathOfLibrary:kFileFolderPath];
        }
        else if (location == LoginUserDocument)
        {
            folderPath = [FileManager getFilePath:kAccountFilePath];
        }
        else if (location == LoginUserDefaults)
        {
            folderPath = [FileManager getFilePathOfLibrary:kAccountFilePath];
        }
        
        NSString *filePath = [folderPath stringByAppendingPathComponent:key];
        
        return [fileManager removeItemAtPath:filePath error:nil];
    }
    
    return NO;
}

+ (BOOL)removeCatalog:(Operation)location {
    
    NSString *folderPath = nil;
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    if (location == Document)
    {
        folderPath = [FileManager getFilePath:kFileFolderPath];
    }
    else if (location == UserDefaults)
    {
        folderPath = [FileManager getFilePathOfLibrary:kFileFolderPath];
    }
    else if (location == LoginUserDocument)
    {
        folderPath = [FileManager getFilePath:kAccountFilePath];
    }
    else if (location == LoginUserDefaults)
    {
        folderPath = [FileManager getFilePathOfLibrary:kAccountFilePath];
    }
    
    return [fileManager removeItemAtPath:folderPath error:nil];
}

@end
