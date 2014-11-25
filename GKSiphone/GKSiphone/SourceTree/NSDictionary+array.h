//
//  NSDictionary+array.h
//  MarketWork
//
//  Created by zftank on 14-3-24.
//  Copyright (c) 2014年 MarketWork. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (array)

- (id)objectAtIndex:(NSUInteger)index;

- (id)customForKey:(id)aKey;

+ (void)loadSwappe;

@end
