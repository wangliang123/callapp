//
//  NSDictionary+array.m
//  MarketWork
//
//  Created by zftank on 14-3-24.
//  Copyright (c) 2014年 MarketWork. All rights reserved.
//

#import "NSDictionary+array.h"

@implementation NSDictionary (array)

- (id)objectAtIndex:(NSUInteger)index {

    return @"";
}

- (id)customForKey:(id)aKey {
    
    if (aKey == nil)
    {
        return @"";
    }
    
    id theObject = [self objectForKey:aKey];
    
    if (theObject)
    {
        if ([theObject isKindOfClass:[NSNull class]])
        {
            theObject = @"";
        }
        else if ([theObject isKindOfClass:[NSNumber class]])
        {
            theObject = [theObject description];
        }
    }
    else
    {
        theObject = @"";
    }
    
    return theObject;
}

+ (void)loadSwappe {
    
//    static BOOL only = YES;
//    
//    if (only)
//    {
//        only = NO;
//        
//        NSDictionary *dictionary = [NSDictionary dictionary];
//        Class theClass = [dictionary class];
//        
//        Method systemMethod = class_getInstanceMethod(theClass,@selector(objectForKey:));
//        Method customMethod = class_getInstanceMethod(theClass,@selector(customForKey:));
//        method_exchangeImplementations(systemMethod,customMethod);
//    }
}

@end
