//
//  FileInterface.h
//  FileInterface
//
//  Created by test on 12/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileOperation : NSObject

+ (void)creatFolderForPhotoCache;

+ (NSString *)makePhotoCachePath:(NSString *)strName;

@end
