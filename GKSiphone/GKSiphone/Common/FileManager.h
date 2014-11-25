//
//  FileManager.h
//  MarketWork
//
//  Created by zftank on 14-7-9.
//  Copyright (c) 2014年 MarketWork. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    
    Document = 0,       //与用户账号系统无关(服务器下发的UUID、APP版本号、苹果推送Token)
    
    UserDefaults,       //与用户账号系统无关
    
    
    LoginUserDocument,  //登录用户行为产生的数据(用户账号信息、用户退出登录的账号信息)
    
    LoginUserDefaults,  //登录用户行为产生的数据
    
} Operation;

@interface FileManager : NSObject

+ (NSString *)MD5:(NSString *)sender;

+ (NSString *)getFilePath:(NSString *)strName;//获取移动设备的Document路径

+ (NSString *)getFilePathOfCache:(NSString *)strName;//获取移动设备的Cache路径

+ (NSString *)getFilePathOfLibrary:(NSString *)strName;//获取移动设备的Preference路径


+ (BOOL)setData:(id)object forKey:(NSString *)key operator:(Operation)location;//保存数据

+ (id)obtainDataForKey:(NSString *)key operator:(Operation)location;//读取数据

+ (BOOL)removeDataForKey:(NSString *)key operator:(Operation)location;//删除数据

+ (BOOL)removeCatalog:(Operation)location;//删除某个目录

@end
