//
//  CheckFormat.m
//  MarketWork
//
//  Created by zftank on 14-7-28.
//  Copyright (c) 2014年 MarketWork. All rights reserved.
//

#import "CheckFormat.h"

@implementation CheckFormat

+ (BOOL)isEmailAddress:(NSString *)email {
    
    NSString *emailRegex = @"^\\w+((\\-\\w+)|(\\.\\w+))*@[A-Za-z0-9]+((\\.|\\-)[A-Za-z0-9]+)*.[A-Za-z0-9]+$";
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:email];
}

+ (BOOL)isMobileNumber:(NSString *)mobileNum {
    
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString *MOBILE = @"^1(3[0-9]|4[57]|5[0-35-9]|8[0235-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString *CM = @"^1(34[0-8]|(3[5-9]|5[0127-9]|8[23478])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    NSString *CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189
     22         */
    NSString *CT = @"^1((33|53|8[019])[0-9]|349)\\d{7}$";
    
    NSString *NCT = @"^1(7[0678])\\d{8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",CT];
    NSPredicate *regextesntct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",NCT];
    
    BOOL mobile = [regextestmobile evaluateWithObject:mobileNum];
    BOOL cm = [regextestcm evaluateWithObject:mobileNum];
    BOOL ct = [regextestct evaluateWithObject:mobileNum];
    BOOL cu = [regextestcu evaluateWithObject:mobileNum];
    BOOL tct = [regextesntct evaluateWithObject:mobileNum];
    
    if (mobile || cm || ct || cu || tct)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (BOOL)characterString:(NSString *)string {
    
	const char *chTemp = [string cStringUsingEncoding:NSUnicodeStringEncoding];
    
	NSUInteger length = 2 * string.length;
	
	for (int i=0;i<length;i+=2)
	{
		unsigned char frontByte = chTemp[i];
		unsigned char backByte = chTemp[i+1];
        
		unsigned int characterInt = (((unsigned short)backByte)<<8) | ((unsigned short)frontByte);
		
		BOOL characterString = FALSE;
		
		if ((characterInt <= 0x9FA5 && characterInt >= 0x4E00) || (characterInt <= 0xFA2D && characterInt >= 0xF900))
        {
			characterString = TRUE;
        }
		
		if (characterInt >= 'a' && characterInt <= 'z')
        {
			characterString = TRUE;
        }
		
		if (characterInt >= 'A' && characterInt <= 'Z')
        {
			characterString = TRUE;
        }
		
		if (!characterString)
        {
			return FALSE;
        }
	}
    
	return TRUE;
}

@end
