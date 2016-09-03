//
//  UploadViewController.m
//  VitaGameManager
//
//  Created by Hex Pang on 16/9/3.
//  Copyright © 2016年 HexPang. All rights reserved.
//

#import "UploadViewController.h"
#import "FTPManager.h"

@interface UploadViewController (){
    NSMutableArray *queue;
    NSDictionary *config;
}

@end

@implementation UploadViewController

FMServer* server;
FTPManager* man;
//NSString* filePath;
long lastSize = 0;
BOOL succeeded;
NSTimer* progTimer;
long offset = -1;
NSString *message;

- (void)ftpManagerUploadProgressDidChange:(NSDictionary *)processInfo{
    NSLog(@"%@",processInfo);
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSMutableDictionary *item = queue[row];
    if([tableColumn.identifier isEqualToString:@"id"]){
        return item[@"info"][@"ID"];
    }else if([tableColumn.identifier isEqualToString:@"file"]){
        return item[@"file"];
    }else if([tableColumn.identifier isEqualToString:@"msg"]){
        return item[@"message"];
    }else {
        return item[@"progress"];
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [queue count];
}

-(void)uploadFinished {
    succeeded = YES;
//    [queue[offset] setObject:@"Finished." forKey:@"message"];
    if(offset >= [queue count] - 1){
        [progTimer invalidate];
        progTimer = nil;
        server = nil;
    }else{
        [self doQueue];
    }
}

-(void)changeProgress {
    if (!man) {
        return;
    }
        NSNumber* progress = [man.progress objectForKey:kFMProcessInfoProgress];
        float p = progress.floatValue * 100; //0.0f ≤ p ≤ 1.0f
    
    if(man.progress != nil){
        NSLog(@"%@",man.progress);
        if(lastSize == 0){
            lastSize = [[man.progress objectForKey:@"fileSizeProcessed"] longValue];
        }else{
            long mbyte =[[man.progress objectForKey:@"fileSizeProcessed"] longValue];
            mbyte = mbyte - lastSize;
            lastSize = [[man.progress objectForKey:@"fileSizeProcessed"] longValue];
            if(mbyte > 0){
                NSString *haha = [NSByteCountFormatter stringFromByteCount:mbyte countStyle:NSByteCountFormatterUseKB];
                [queue[offset] setObject:[NSString stringWithFormat:@"%@/s",haha] forKey:@"message"];
            }
      
            
        }
        
        [queue[offset] setObject:[NSString stringWithFormat:@"%.2f %%",p] forKey:@"progress"];
        
    }
    [self.tableView reloadData];
    /*
     bytesProcessed = 32768;
     fileSize = 32583319;
     fileSizeProcessed = 27197440;
     progress = "0.8347044";
     */
    //use p here...
    //update some ui stuff, you know
}

- (void)uploadViewNotification:(NSNotification *)notification {
    for (NSDictionary *item in queue) {
        if([item isEqualToDictionary:notification.object]){
            return;
        }
    }
    NSMutableDictionary *game = [[NSMutableDictionary alloc] initWithDictionary:notification.object];
    [queue addObject:game];
    [self.tableView reloadData];
    [self doQueue];

}

-(void)doQueue {
    if(offset == -1){
        offset = 0;
        [self upload:queue[offset][@"file"]];
    }else{
        offset++;
    }
    [self upload:queue[offset][@"file"]];
    
}

-(void)startUploading {
    [queue[offset] setObject:@"Uploading" forKey:@"message"];
    NSString *url = [queue[offset][@"file"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //libPath = [libPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *fileURL = [NSURL URLWithString:url];
    
    succeeded = [man uploadFile:fileURL toServer:server];
    [queue[offset] setObject:succeeded ? @"Uploaded." : @"Can't Upload." forKey:@"message"];
    if(succeeded){
        [queue[offset] setObject:@"100%" forKey:@"progress"];
    }
    [self performSelectorOnMainThread:@selector(uploadFinished) withObject:nil waitUntilDone:NO];
}

-(void)upload:(NSString*)file {
    config = [[Util shareInstance] loadConfig];
    if(config != nil){
        if(server == nil){
            server = [FMServer anonymousServerWithDestination:[NSString stringWithFormat:@"%@/ux0:/",config[@"vita_ip"]]];
            server.port = [config[@"vita_port"] intValue];
        }
    }else{
        return;
    }
    progTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(changeProgress) userInfo:nil repeats:YES];
    
    [self performSelectorInBackground:@selector(startUploading) withObject:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadViewNotification:) name:@"UPLOAD_NOTIFICATION" object:nil];
    if(!queue){
        queue = [[NSMutableArray alloc] init];
    }
    man = [[FTPManager alloc] init];
    man.delegate = self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
