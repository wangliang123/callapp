//
//  ServerManager.h
//  GKSiphone
//
//  Created by zftank on 14-9-23.
//  Copyright (c) 2014年 GK. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ServerCenter   [ServerManager instance]

@interface ServerInfomation : MarketEntity

@property (nonatomic,copy) NSString *signature;

@property (nonatomic,copy) NSString *domain;

@property (nonatomic,copy) NSString *serverIP;

@property (nonatomic,copy) NSString *serverPort;

- (BOOL)analyzeDataSource:(id)dataSource;

@end

@interface ServerManager : NSObject

@property (nonatomic,strong) ServerInfomation *infomation;

+ (ServerManager *)instance;

- (void)startSearchServer:(id)entrust;

@end

@protocol ServerCenterDelegate <NSObject>

- (void)succesForServer;

@end