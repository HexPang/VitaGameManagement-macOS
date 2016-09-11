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
typedef void (^UploadProgress)(int code,float progress,NSObject *message);
+(instancetype) shareInstance ;
- (NSDictionary *) loadConfig;
- (NSURL *) getCacheFolder:(NSString *)name;
- (LxFTPRequest *) UploadWithFTP:(NSString *)localFile withName:(NSString *)name withProgress:(UploadProgress) uProgress;
- (LxFTPRequest *) ListWithFTP:(NSString *)path withProgress:(UploadProgress) uProgress;

- (BOOL) UploadFolderWithFTP:(NSString *)folder toPath:(NSString *)toPath withProgress:(UploadProgress)progress;
- (void) CreateFolderBeforeUpload:(NSString *)folder toPath:(NSString *)toPath withProgress:(UploadProgress)progress;
@end
