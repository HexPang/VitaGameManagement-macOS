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

- (NSArray *) FetchFilesInFolder:(NSString *)folder{
    NSMutableArray *fileList = [[NSMutableArray alloc]init];
    NSFileManager *fm = [[NSFileManager alloc]init];
    NSError *err;
    folder = [folder stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:folder];
    if(url != nil){
        NSArray *files = [fm contentsOfDirectoryAtURL:url includingPropertiesForKeys:nil options:0 error:&err];
        for (NSURL *fileUrl in files) {
            NSString *file = [fileUrl path];
            BOOL isDir = NO;
            if([fm fileExistsAtPath:file isDirectory:&isDir] && isDir){
                //目录处理，继续便利!
                NSArray *packs = (NSArray *)[self FetchFilesInFolder:file];
                [fileList addObjectsFromArray:packs];
            }else{
                NSString *fileName = [file lastPathComponent];
                NSArray *filter = @[@".DS_Store"];
                BOOL isInFilter = NO;
                for(NSString *f in filter){
                    if([fileName isEqualToString:f]){
                        isInFilter = YES;
                        break;
                    }
                }
                if(!isInFilter)
                    [fileList addObject:file];
            }
        }
    }
    return fileList;
}

- (void) CreateFolderBeforeUpload:(NSString *)folder toPath:(NSString *)toPath withProgress:(UploadProgress)progress{
    NSArray *files = [self FetchFilesInFolder:folder];
    //    NSString *GAME_ID = [toPath lastPathComponent];
    NSString *lastFolder = nil;
    NSDictionary *config = [[Util shareInstance] loadConfig];
    __block int index = 0;
    int total = 0;
    for(NSString *file in files){
        NSString *fileDir = [file substringFromIndex:[folder length] + 1];
        fileDir = [fileDir stringByDeletingLastPathComponent];
        if(![lastFolder isEqualToString:fileDir]){
            lastFolder = fileDir;
            total++;
        }
    }
    lastFolder = nil;
    for(NSString *file in files){
        //Create folder
        NSString *fileDir = [file substringFromIndex:[folder length] + 1];
        fileDir = [fileDir stringByDeletingLastPathComponent];
        NSLog(@"%@",fileDir);
        
        if(![lastFolder isEqualToString:fileDir]){
            lastFolder = fileDir;
            //Create
            NSURL *sURL = [NSURL URLWithString:[NSString stringWithFormat:@"ftp://%@:%@/",config[@"vita_ip"],config[@"vita_port"]]];
            sURL = [sURL URLByAppendingPathComponent:@"ux0"];
            sURL = [sURL URLByAppendingPathComponent:toPath];
            sURL = [sURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@/",fileDir]];
            LxFTPRequest * request = [LxFTPRequest createResourceRequest];
            request.serverURL = sURL;    // directory path should be end up with '/'
            request.username = @"anonymous";
            request.password = @"";
            NSLog(@"%@",sURL);
            request.successAction = ^(Class resultClass, id result) {
                NSLog(@"resultClass = %@, result = %@", resultClass, result);
                index++;
                NSLog(@"%d/%d",index,total);
                if(index >= total){
                    [self UploadFolderWithFTP:folder toPath:toPath withProgress:progress];
                }
            };
            request.failAction = ^(CFStreamErrorDomain domain, NSInteger error, NSString *errorMessage) {
                if(error == 550){
                    //already exists.
                }
                index++;
                NSLog(@"%d/%d",index,total);
                if(index >= total){
                    [self UploadFolderWithFTP:folder toPath:toPath withProgress:progress];
                }
            };
            [request start];
          
        }
    }
    
}

- (BOOL) UploadFolderWithFTP:(NSString *)folder toPath:(NSString *)toPath withProgress:(UploadProgress)progress{
    NSArray *files = [self FetchFilesInFolder:folder];
//    NSString *GAME_ID = [toPath lastPathComponent];
    
    if([files count] > 0){
        NSString *firstFile = files[0];
        NSString *folderName = [firstFile substringFromIndex:[folder length] + 1];
        NSLog(@"First File : %@",firstFile);
        NSURL *toURL = [[NSURL URLWithString:toPath] URLByAppendingPathComponent:folderName];
        progress(0,0,[NSString stringWithFormat:@"(%lu left)%@",(unsigned long)[files count],[firstFile lastPathComponent]]);
        LxFTPRequest *ftpRequest = [self UploadWithFTP:firstFile withName:[toURL path] withProgress:progress];
        
        //ftpRequest.localFileURL = [NSURL URLWithString:firstFile];
        ftpRequest.progressAction = ^(NSInteger totalSize, NSInteger finishedSize, CGFloat finishedPercent) {
            //progress(1,finishedPercent,firstFile);
        };
        
        ftpRequest.successAction = ^(Class resultClass, id result) {
            progress(2,1.0f,firstFile);
            NSArray * resultArray = (NSArray *)result;
            NSLog(@"resultArray = %@", resultArray);
            //Remove first file and continue upload next file
            [[NSFileManager defaultManager] removeItemAtPath:firstFile error:NULL];
            if([files count] > 1){
                [self UploadFolderWithFTP:folder toPath:toPath withProgress:progress];
            }else{
                progress(-2,0,nil);
            }
        };
        ftpRequest.failAction = ^(CFStreamErrorDomain domain, NSInteger error, NSString *errorMessage) {
            progress(0,0,errorMessage);
            NSLog(@"domain = %ld, error = %ld", domain, error);
        };
        BOOL succ = [ftpRequest start];
        return succ;
    }else{
        progress(-1,0,nil);
    }
    return NO;
}

- (LxFTPRequest *) UploadWithFTP:(NSString *)localFile withName:(NSString *)name withProgress:(UploadProgress) uProgress{
    LxFTPRequest *ftpRequest = [LxFTPRequest uploadRequest];
    NSDictionary *config = [[Util shareInstance] loadConfig];
    NSURL *sURL = [NSURL URLWithString:[NSString stringWithFormat:@"ftp://%@:%@/",config[@"vita_ip"],config[@"vita_port"]]];
    sURL = [sURL URLByAppendingPathComponent:@"ux0"];
    if([[[localFile pathExtension] lowercaseString] isEqualToString:@"vpk"]){
        sURL = [sURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.VPK",name]];
    }else{
        sURL = [sURL URLByAppendingPathComponent:name];
    }
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
