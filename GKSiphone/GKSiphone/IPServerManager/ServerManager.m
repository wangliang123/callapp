//
//  ServerManager.m
//  GKSiphone
//
//  Created by zftank on 14-9-23.
//  Copyright (c) 2014年 GK. All rights reserved.
//

#import "ServerManager.h"
#import "IPAddress.h"

#define kMaxCount  256

@implementation ServerInfomation

- (BOOL)analyzeDataSource:(id)dataSource {

    if ([dataSource isKindOfClass:[NSDictionary class]])
    {
        self.signature = [dataSource customForKey:@"signature"];
        
        if (self.signature && 0 < self.signature.length)
        {
            self.domain = [dataSource customForKey:@"address"];
            
            NSArray *list = [self.domain componentsSeparatedByString:@":"];
        
            if (list && [list isKindOfClass:[NSArray class]])
            {
                if (1 < list.count)
                {
                    self.serverIP = list.firstObject;
                    
                    self.serverPort = list.lastObject;
                    
                    [FileManager setData:self forKey:kServerDomain operator:Document];
                    
                    return YES;
                }
            }
        }
    }
    
    return NO;
}

@end

@interface ServerManager ()

@property (nonatomic,weak) id delegate;

@property (nonatomic,assign) NSInteger count;

@end

@implementation ServerManager

- (id)init {

    self = [super init];
    
    if (self)
    {
        self.count = 0;
        
        self.infomation = [FileManager obtainDataForKey:kServerDomain operator:Document];
    }
    
    return self;
}

- (NSString *)deviceIPAdress {
    InitAddresses();
    GetIPAddresses();
    GetHWAddresses();
    return [NSString stringWithFormat:@"%s", ip_names[1]];
}

+ (ServerManager *)instance {
    
    //8015
    //648571
    
    //8008
    //567941
    
    //fengsheng.aoyi.power
    
    static ServerManager *serverCenter = nil;
    
    @synchronized(self)
    {
        if (serverCenter == nil)
        {
            serverCenter = [[ServerManager alloc] init];
        }
    }
    
    return serverCenter;
}

- (void)startSearchServer:(id)entrust {

    self.delegate = entrust;
    
    NSString *ipa = [self deviceIPAdress];
    
    NSArray *aray = [ipa componentsSeparatedByString:@"."];
    
    NSString *ip = @"";
    
    for (int i=0;i<3;i++)
    {
        NSString *str = [aray objectAtIndex:i];
        
        NSString *current = [str stringByAppendingString:@"."];
        
        ip = [ip stringByAppendingString:current];
    }
    
    for (int i=0;i<kMaxCount;i++)
    {
        HTTPDetails *infomation = [[HTTPDetails alloc] init];
        infomation.requestHost = [NSString stringWithFormat:@"http://%@%d/api/address",ip,i];
        [HTTPLink requestData:self withInfo:infomation];
    }
}

- (void)requestSucces:(HTTPDetails *)details {
    
    ++self.count;
    
    if ([details.responseData isKindOfClass:[NSDictionary class]])
    {
        [HTTPLink cancelAllRequest];
        
        ServerInfomation *info = [[ServerInfomation alloc] init];
        
        if ([info analyzeDataSource:details.responseData])
        {
            self.infomation = info;
            
            [FileManager setData:self.infomation forKey:kServerDomain operator:Document];
            
            [self.delegate succesForServer];
        }
    }
}

- (void)requestWrong:(HTTPDetails *)details {
    
    NSLog(@"requestWrong");
    
    ++self.count;
    
    if (self.count == kMaxCount)
    {
         NSLog(@"requestWrong %i",self.count);
    }
}

@end
