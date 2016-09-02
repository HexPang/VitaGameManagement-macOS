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
                NSDictionary *game = @{@"file":file,@"info":[self loadSFO:file]};
                [packages addObject:game];
            }
        }
        
    }
    
    return packages;
}

- (NSDictionary *) loadSFO:(NSString*) package{
    BOOL isZIP = [UZKArchive pathIsAZip:package];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
    if(isZIP){
        NSError *archiveError = nil;
        UZKArchive *archive = [[UZKArchive alloc] initWithPath:package error:&archiveError];
        
        NSError *error = nil;
        if(archive){
            NSArray *fileList = [archive listFilenames:&error];
//            NSLog(@"%@",fileList);
            for (NSString *file in fileList) {
                if([file isEqualToString:@"sce_sys/param.sfo"]){
                    NSData *sfoData = [archive extractDataFromFile:file progress:^(CGFloat percentDecompressed) {
                        //NSLog(@"%f",percentDecompressed);
                    } error:&error];
                    if(sfoData){
                        int header;
                        [sfoData getBytes:&header length:sizeof(header)];
                        if(CFSwapInt32HostToBig(header) == 0x505346){
                            int32_t KEY_OFFSET;
                            int32_t DATA_OFFSET;
                            int key_table_start = 0x08;
                            int data_table_start = 0x0C;
                            int tables_entries = 0x10;
                            int table_index = 0x14;
                            int32_t TABLE_COUNT;
                            
                            [sfoData getBytes:&KEY_OFFSET range:NSMakeRange(key_table_start, 4)];
                            [sfoData getBytes:&DATA_OFFSET range:NSMakeRange(data_table_start, 4)];
                            
                            [sfoData getBytes:&TABLE_COUNT range:NSMakeRange(tables_entries, 4)];
                            int offset = table_index;
                            
                            for(int i=0;i<TABLE_COUNT;i++){
                                int16_t key_offset;
                                int16_t data_format;
                                int32_t data_lenght;
                                int32_t data_maxlength;
                                int32_t data_offset;
                                
                                [sfoData getBytes:&key_offset range:NSMakeRange(offset,sizeof(key_offset))];
                                offset += 2;
                                
                                [sfoData getBytes:&data_format range:NSMakeRange(offset,sizeof(data_format))];
                                offset += 2;
                                
                                if(data_format == 516){
                                    //It's UTF-8
                                }
                                
                                [sfoData getBytes:&data_lenght range:NSMakeRange(offset,sizeof(data_lenght))];
                                offset += 4;
                                
                                [sfoData getBytes:&data_maxlength range:NSMakeRange(offset,sizeof(data_maxlength))];
                                offset += 4;
                                
                                [sfoData getBytes:&data_offset range:NSMakeRange(offset,sizeof(data_offset))];
                                offset += 4;
                                
                                Byte dataByte[data_lenght];
                                [sfoData getBytes:&dataByte range:NSMakeRange(DATA_OFFSET + data_offset, data_lenght)];
//                                offset+= data_maxlength;
                                NSString *data = [[NSString alloc] initWithData:[[NSData alloc] initWithBytes:dataByte length:data_lenght] encoding:NSUTF8StringEncoding];
                                
                                
                                NSMutableData *tmp = [[NSMutableData alloc]init];
                                Byte byte[1];
                                int pp = key_offset + KEY_OFFSET;
                                [sfoData getBytes:&byte range:NSMakeRange(pp, 1)];
                                pp++;
                                while(byte[0] != '\0'){
                                    
                                    [tmp appendBytes:byte length:1];
                                    [sfoData getBytes:&byte range:NSMakeRange(pp, 1)];
                                    pp++;
                                }
                                NSString *key = [[NSString alloc] initWithData:tmp encoding:NSUTF8StringEncoding];
                                NSLog(@"%@ => %@",key,data);
                                [dictionary setValue:data forKey:key];
                            }
                            NSData *icon = [archive extractDataFromFile:@"sce_sys/icon0.png" progress:nil error:&error];
                            [dictionary setValue:icon forKey:@"icon"];
                            return dictionary;
                        }else{
                            return nil;
                        }
                    }else{
                        return nil;
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
