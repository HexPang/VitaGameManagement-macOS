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



- (LxFTPRequest *) ListWithFTP:(NSString *)path withProgress:(UploadProgress) uProgress{
    LxFTPRequest *ftpRequest = [LxFTPRequest resourceListRequest];
    NSDictionary *config = [[Util shareInstance] loadConfig];
    NSURL *sURL = [NSURL URLWithString:[NSString stringWithFormat:@"ftp://%@:%@/",config[@"vita_ip"],config[@"vita_port"]]];
    sURL = [sURL URLByAppendingPathComponent:@"ux0"];
    sURL = [sURL URLByAppendingPathComponent:path];
    NSLog(@"Listing to %@",sURL);
    ftpRequest.serverURL = sURL;
    
    ftpRequest.username = @"anonymous";
    ftpRequest.password = @"";
   
    ftpRequest.progressAction = ^(NSInteger totalSize, NSInteger finishedSize, CGFloat finishedPercent) {
        uProgress(1,finishedPercent,@"");
    };
    
    ftpRequest.successAction = ^(Class resultClass, id result) {
        uProgress(2,1.0f,result);
        
    };
    ftpRequest.failAction = ^(CFStreamErrorDomain domain, NSInteger error, NSString *errorMessage) {
        uProgress(0,0,errorMessage);
        NSLog(@"domain = %ld, error = %ld", domain, error);
    };
    return ftpRequest;
}

- (LxFTPRequest *) UploadWithFTP:(NSString *)localFile withName:(NSString *)name withProgress:(UploadProgress) uProgress{
    LxFTPRequest *ftpRequest = [LxFTPRequest uploadRequest];
    NSDictionary *config = [[Util shareInstance] loadConfig];
    NSURL *sURL = [NSURL URLWithString:[NSString stringWithFormat:@"ftp://%@:%@/",config[@"vita_ip"],config[@"vita_port"]]];
    sURL = [sURL URLByAppendingPathComponent:@"ux0"];
    sURL = [sURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.VPK",name]];
    NSLog(@"Uploading to %@",sURL);
    ftpRequest.serverURL = sURL;
    
    ftpRequest.username = @"anonymous";
    ftpRequest.password = @"";
    NSURL *fileUrl = [NSURL fileURLWithPath:localFile];
    
    ftpRequest.localFileURL = fileUrl;
    
    ftpRequest.progressAction = ^(NSInteger totalSize, NSInteger finishedSize, CGFloat finishedPercent) {
        uProgress(1,finishedPercent,@"");
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
