//
//  MarketEntity.m
//  MarketWork
//
//  Created by zftank on 14-3-24.
//  Copyright (c) 2014年 MarketWork. All rights reserved.
//

#import "MarketEntity.h"

@implementation MarketEntity

- (void)checkMemberList {

    Class cls = [self class];
    
    unsigned int ivarsCnt = 0;
    
    Ivar *ivars = class_copyIvarList(cls, &ivarsCnt);
    
    for (const Ivar *p = ivars; p < ivars + ivarsCnt; ++p)
    {
        Ivar const ivar = *p;
        
        NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
        
        id value = [self valueForKey:key];
        
        if (value == nil)
        {
            [self setValue:@"" forKey:key];
        }
    }
}

#pragma mark -
#pragma mark - NSCoding delegate

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super init])
    {
        for (NSString *key in [self propertyKeys])
        {
            id value = [aDecoder decodeObjectForKey:key];
            
            if (value)
            {
                [self setValue:value forKey:key];
            }
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    for (NSString *key in [self propertyKeys])
    {
        id value = [self valueForKey:key];
        [aCoder encodeObject:value forKey:key];
    }
}

- (NSArray *)propertyKeys {
    
    NSMutableArray *array = [NSMutableArray array];
    Class class = [self class];
    
    while (class != [NSObject class])
    {
        unsigned int propertyCount;
        objc_property_t *properties = class_copyPropertyList(class, &propertyCount);
        
        for (int i = 0; i < propertyCount; i++)
        {
            //get property
            objc_property_t property = properties[i];
            const char *propertyName = property_getName(property);
            NSString *key = [NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding];
            
            //check if read-only
            BOOL readonly = NO;
            const char *attributes = property_getAttributes(property);
            NSString *encoding = [NSString stringWithCString:attributes encoding:NSUTF8StringEncoding];
            
            if ([[encoding componentsSeparatedByString:@","] containsObject:@"R"])
            {
                readonly = YES;
                
                //see if there is a backing ivar with a KVC-compliant name
                NSRange iVarRange = [encoding rangeOfString:@",V"];
                
                if (iVarRange.location != NSNotFound)
                {
                    NSString *iVarName = [encoding substringFromIndex:iVarRange.location + 2];
                    
                    if ([iVarName isEqualToString:key] || [iVarName isEqualToString:[@"_" stringByAppendingString:key]])
                    {
                        //setValue:forKey: will still work
                        readonly = NO;
                    }
                }
            }
            
            if (!readonly)
            {
                //exclude read-only properties
                [array addObject:key];
            }
        }
        
        free(properties);
        
        class = [class superclass];
    }
    
    return array;
}

@end
