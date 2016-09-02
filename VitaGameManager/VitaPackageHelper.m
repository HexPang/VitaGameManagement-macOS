//
//  VitaPackageHelper.m
//  VitaPackageHelper
//
//  Created by Hex Pang on 16/9/2.
//  Copyright © 2016年 HexPang. All rights reserved.
//

#import "VitaPackageHelper.h"
#include <stdio.h>

@implementation VitaPackageHelper
- (NSArray *) loadPackage:(NSString*)libPath{
    NSMutableArray *packages = [[NSMutableArray alloc]init];
    NSFileManager *fm = [[NSFileManager alloc]init];
    NSError *err;
    libPath = [libPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:libPath];
    if(url != nil){
        NSArray *files = [fm contentsOfDirectoryAtURL:url includingPropertiesForKeys:nil options:0 error:&err];
        
        for (NSURL *fileUrl in files) {
            NSString *file = [fileUrl path];
            NSString *ext = [[file pathExtension] lowercaseString];
            BOOL isDir = NO;
            if([fm fileExistsAtPath:file isDirectory:&isDir] && isDir){
                //目录处理，继续便利!
                NSArray *packs = (NSArray *)[self loadPackage:file];
                [packages addObjectsFromArray:packs];
            }
            if([ext isEqualToString:@"vpk"]){
                [packages addObject:file];
            }
        }
        
    }
    
    return packages;
}

- (NSDictionary *) loadSFO:(NSString*) package{
    BOOL isZIP = [UZKArchive pathIsAZip:package];
    NSDictionary *dictionary = [[NSDictionary alloc]init];
    if(isZIP){
        NSError *archiveError = nil;
        
        UZKArchive *archive = [[UZKArchive alloc] initWithPath:package error:&archiveError];
        
        NSError *error = nil;
        if(archive){
            NSArray *fileList = [archive listFilenames:&error];
            NSLog(@"%@",fileList);
            for (NSString *file in fileList) {
                if([file isEqualToString:@"sce_sys/param.sfo"]){
                    NSData *sfoData = [archive extractDataFromFile:file progress:^(CGFloat percentDecompressed) {
                        //NSLog(@"%f",percentDecompressed);
                    } error:&error];
                    if(sfoData){
                        int header;
                        [sfoData getBytes:&header length:sizeof(header)];
                        NSLog(@"%X",CFSwapInt32HostToBig(header));
                        if(CFSwapInt32HostToBig(header) == 0x505346){
                            int32_t KEY_OFFSET;
                            int32_t DATA_OFFSET;
                            int KEY_TABLE_START = 0x08;
                            int KEY_DATA_START = 0x0C;
                            [sfoData getBytes:&KEY_OFFSET range:NSMakeRange(KEY_TABLE_START, 4)];
                            [sfoData getBytes:&DATA_OFFSET range:NSMakeRange(KEY_DATA_START, 4)];
                            
                            
                        }
                    }
                }
            }
        }
        
    }else{
        return nil;
    }
    
    return dictionary;
}
@end
