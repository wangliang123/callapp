//
//  HTTPDetails.h
//  JiuTianWaiApp
//
//  Created by zhangfeng on 13-6-21.
//  Copyright (c) 2013年 MasterPlate. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kGetMethod         @"GET"
#define kPostMethod        @"POST"

typedef enum {
    
    HTTPNotNetwork = 0,    //没有网络
    HTTPNetworkTimedOut,   //网络超时
    HTTPNetworkUnknown,    //其它状态
    
} HTTPErrorCode;

@interface PostInfomation : NSObject

@property (nonatomic,strong) id dataSource;
@property (nonatomic,copy) NSString *dataKey;

@end

@interface HTTPDetails : NSObject

@property (nonatomic,copy) NSString *requestHost;
@property (nonatomic,copy) NSString *requestInterface;
@property (nonatomic,copy) NSString *requestMethod;//默认POST(一般不需要设置，例如简历部分需要get请求)

@property (nonatomic,strong) id extensionInfo;//参数扩展
@property (nonatomic,strong) NSDictionary *addHeader;//追加header(一般不需要追加,默认已加载大部分header)

@property (nonatomic,strong) NSDictionary *requestBody;//一般格式
@property (nonatomic,strong) id customBody;//自定义格式

@property (nonatomic,strong) id responseHeader;//返回的头文件
@property (nonatomic,strong) id responseData;//返回的body体

@property (nonatomic,assign) NSInteger requestError;//请求失败时返回的错误码，默认0
@property (nonatomic,assign) BOOL brokenNetwork;//断网时是否自动提示无网信息，默认YES

@property (nonatomic,strong) UIImage *defaultPhoto;//默认背景图
@property (nonatomic,copy) NSString *cachePhoto;//图片的缓存路径
@property (nonatomic,assign) BOOL surfaceOfButton;//专门针对UIButton

@property (nonatomic,strong) NSArray *listItem;//POST数据(PostInfomation)

@end