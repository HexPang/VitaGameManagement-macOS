//
//  Util.m
//  VitaGameManager
//
//  Created by Hex Pang on 16/9/3.
//  Copyright © 2016年 HexPang. All rights reserved.
//

#import "Util.h"

static Util *_instance = nil;
@implementation Util


+(instancetype) shareInstance
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init] ;
    }) ;
    return _instance ;
}

- (NSDictionary *) loadConfig{
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"setting"];
}

- (NSURL *) getCacheFolder:(NSString *)name {
    NSString* bundleID = [[NSBundle mainBundle] bundleIdentifier];
    NSFileManager*fm = [NSFileManager defaultManager];
    NSURL*    dirPath = nil;
    
    // Find the application support directory in the home directory.
    NSArray* appSupportDir = [fm URLsForDirectory:NSApplicationSupportDirectory
                                        inDomains:NSUserDomainMask];
    if ([appSupportDir count] > 0){
        // Append the bundle ID to the URL for the
        // Application Support directory
        dirPath = [[appSupportDir objectAtIndex:0] URLByAppendingPathComponent:bundleID];
        dirPath = [dirPath URLByAppendingPathComponent:@"data"];
        
        // If the directory does not exist, this method creates it.
        // This method is only available in OS X v10.7 and iOS 5.0 or later.
        NSError*    theError = nil;
        if (![fm createDirectoryAtURL:dirPath withIntermediateDirectories:YES
                           attributes:nil error:&theError])
        {
            // Handle the error.
            
            return nil;
        }
    }
    return [dirPath URLByAppendingPathComponent:name];
}

- (LxFTPRequest *) UploadWithFTP:(NSString *)localFile withProgress:(UploadProgress) uProgress{
//    localFile = [localFile stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    LxFTPRequest *ftpRequest = [LxFTPRequest uploadRequest];
    NSDictionary *config = [[Util shareInstance] loadConfig];
    NSString *serverURL = [NSString stringWithFormat:@"ftp://%@:%@/ux0%%30/",config[@"vita_ip"],config[@"vita_port"]];
    
    ftpRequest = [LxFTPRequest uploadRequest];
    ftpRequest.serverURL = [NSURL URLWithString:serverURL];
    
    ftpRequest.username = @"anonymous";
    ftpRequest.password = @"";
    NSURL *fileUrl = [NSURL fileURLWithPath:localFile];
    
    ftpRequest.localFileURL = fileUrl;
    
    ftpRequest.progressAction = ^(NSInteger totalSize, NSInteger finishedSize, CGFloat finishedPercent) {
        uProgress(1,finishedPercent,@"");
        //NSLog(@"totalSize = %ld, finishedSize = %ld, finishedPercent = %f", totalSize, finishedSize, finishedPercent);
    };

    ftpRequest.successAction = ^(Class resultClass, id result) {
        uProgress(2,1.0f,localFile);
        NSArray * resultArray = (NSArray *)result;
        NSLog(@"resultArray = %@", resultArray);
        
    };
    ftpRequest.failAction = ^(CFStreamErrorDomain domain, NSInteger error, NSString *errorMessage) {
        uProgress(0,0,errorMessage);
        NSLog(@"domain = %ld, error = %ld", domain, error);
    };
    return ftpRequest;
}
@end
