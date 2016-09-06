//
//  Util.h
//  VitaGameManager
//
//  Created by Hex Pang on 16/9/3.
//  Copyright © 2016年 HexPang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LxFTPRequest.h"

@interface Util : NSObject
typedef void (^UploadProgress)(int code,float progress,NSString *message);
+(instancetype) shareInstance ;
- (NSDictionary *) loadConfig;
- (NSURL *) getCacheFolder:(NSString *)name;
- (LxFTPRequest *) UploadWithFTP:(NSString *)localFile withProgress:(UploadProgress) uProgress;
@end
