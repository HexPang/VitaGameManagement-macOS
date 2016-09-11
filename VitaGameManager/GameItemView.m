//
//  GameItemView.m
//  VitaGameManager
//
//  Created by Hex Pang on 16/9/3.
//  Copyright © 2016年 HexPang. All rights reserved.
//

#import "GameItemView.h"
@implementation GameItemView{
    NSDictionary *game;
    NSTimer *timer;
    NSString *targetFile;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    GameItemView *itemView = self;
    [itemView.iconView.layer setMasksToBounds:YES];
    [itemView.iconView.layer setCornerRadius:45];
    
    [itemView.layer setMasksToBounds:YES];
    [itemView.layer setCornerRadius:10];
    
}

- (void) initCMAMenu{
    NSMenu *cma_menu = [self.uploadButton.menu itemAtIndex:4].submenu;
    NSDictionary *config = [[Util shareInstance] loadConfig];
    if(config[@"cma_path"] == nil || [config[@"cma_path"] length] == 0){
        
    }else{
        NSURL *CMA_URL = [NSURL fileURLWithPath:config[@"cma_path"]];
        NSMenu *saveDataMenu = [cma_menu itemAtIndex:0].submenu;
        NSArray *SAVE_USERS = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[CMA_URL URLByAppendingPathComponent:@"PSAVEDATA"] includingPropertiesForKeys:nil options:0 error:nil];
        [saveDataMenu removeAllItems];
//        //Remove all sub-menus
        for(NSURL *PATH in SAVE_USERS){
            NSString *NAME_ID = [PATH lastPathComponent];
//            NSMenu *userMenu = [[NSMenu alloc] initWithTitle:NAME_ID];
            //[saveDataMenu setSubmenu:userMenu forItem:nil];
            NSMenuItem *userMenu = [saveDataMenu addItemWithTitle:NAME_ID action:nil keyEquivalent:NAME_ID];
    
            NSURL *GAME_URL = [NSURL fileURLWithPath:[PATH path]];
            NSArray *GAMES = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:GAME_URL includingPropertiesForKeys:nil options:0 error:nil];
            NSMenu *GAME_MENU = [[NSMenu alloc] initWithTitle:@"GAMES"];
            [userMenu setSubmenu:GAME_MENU];
            [GAME_MENU setAutoenablesItems:NO];
            for(NSURL *GAME in GAMES){
                NSString *GAME_ID = [GAME lastPathComponent];
                
                NSMenuItem *item =[GAME_MENU addItemWithTitle:GAME_ID action:@selector(ChooseSaveData:) keyEquivalent:GAME_ID];
//                [item setEnabled:NO];
                NSURL *sfoURL = [[GAME_URL URLByAppendingPathComponent:GAME_ID] URLByAppendingPathComponent:@"param.sfo"];
                NSData *sfoData = [NSData dataWithContentsOfURL:sfoURL];
                                 
                VitaPackageHelper *helper = [[VitaPackageHelper alloc] init];
            
                NSDictionary *sfo = [helper parserSFO:sfoData];
                if(sfo.count > 0){
                    if(sfo[@"TITLE"] != nil){
                        item.title = sfo[@"TITLE"];
                        [item setToolTip:GAME_ID];
                    }
                }
                [item setTarget:self];
            }
            
        }
    }
}

- (void)setGame:(NSDictionary *)info{
    game = info;
}


- (void)sendNotification:(NSString *)action{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GAME_ITEM_NOTIFICATION" object:@{@"game":game,@"action":action} userInfo:nil];
}

- (IBAction)ChooseSaveData:(id)sender{
     NSDictionary *config = [[Util shareInstance] loadConfig];
    NSMenuItem *item = sender;
    NSString *sourceName = game[@"info"][@"ID"];
    NSURL *toPath = [NSURL fileURLWithPath:config[@"cma_path"]];
    toPath = [toPath URLByAppendingPathComponent:@"PSAVEDATA"];
    NSString *GAME_ID = item.toolTip;
    toPath =[[toPath URLByAppendingPathComponent:item.parentItem.title] URLByAppendingPathComponent:GAME_ID];
    toPath = [toPath URLByAppendingPathComponent:@"GAME.BIN"];
    NSURL *sourceURL = [NSURL fileURLWithPath:game[@"file"]];
    NSLog(@"Copying %@ to %@",[sourceURL path],[toPath path]);
    NSFileManager *fm = [NSFileManager defaultManager];
    [self.uploadButton setEnabled:NO];
     timer =  [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerUpdate:) userInfo:nil repeats:YES];
    [timer fire];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        targetFile = [toPath path];
        [fm removeItemAtURL:toPath error:NULL];
        [fm copyItemAtURL:[sourceURL filePathURL] toURL:[toPath filePathURL] error:&error];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.uploadButton setEnabled:YES];
            [timer invalidate];
            targetFile = nil;
            [self.uploadButton setTitle:@"Upload"];
            if(error != nil){
                NSRunAlertPanel(NSLocalizedString(@"COPY_ERROR", nil), [error localizedDescription], NSLocalizedString(@"OK", nil), nil,nil);
                NSLog(@"%@",[error localizedDescription]);
            }else{
                NSRunAlertPanel(NSLocalizedString(@"DONE", nil), NSLocalizedString(@"CMA_COPIED_TIP", nil), @"Ok", nil,nil);
            }
        });
    });
}

- (IBAction)timerUpdate:(id)sender {
    long total = [self getFileSize:game[@"file"]];
    long copied = [self getFileSize:targetFile];
    //NSLog(@"%ld/%ld",copied,total);
    double pst = (double)copied / (double)total;
    
    [self.uploadButton setTitle:[NSString stringWithFormat:@"%.2f%%",pst * 100]];
}

- (long) getFileSize:(NSString *)path{
    NSDictionary * fileAttributes = [[NSFileManager defaultManager]attributesOfItemAtPath:path error:NULL];
    return [fileAttributes[NSFileSize] longValue];
}

- (IBAction)UploadGame:(id)sender{
    NSButton* btn = sender;
    
    [btn.menu popUpMenuPositioningItem:[btn.menu itemAtIndex:0] atLocation:[NSEvent mouseLocation] inView:nil];
}

- (IBAction)UploadFullPackage:(id)sender{
    //[self sendNotification:@"upload"];
    LxFTPRequest *ftpRequest = [[Util shareInstance] UploadWithFTP:game[@"file"] withName:game[@"info"][@"ID"] withProgress:^(int code, float progress, NSObject *message) {
        NSString *text = @"";
        if(code == 1){
            //Uploading...
//            text = [NSString stringWithFormat:NSLocalizedString(@"UPLOADING_PROGRESS", nil),message,progress];
            text = NSLocalizedString(@"UPLOADING", nil);
        }else if(code == 2){
            //Success
            text = NSLocalizedString(@"UPLOADED", nil);
            [self.uploadButton setEnabled:YES];
        }else if (code == 0){
            //Error
            text = [NSString stringWithFormat:@"%@",message];
            [self.uploadButton setEnabled:YES];
        }
        [self.infoLabel setStringValue:text];
    }];
  
    BOOL succ = [ftpRequest start];
    if(succ){
        [self.uploadButton setEnabled:NO];
        [self.infoLabel setStringValue:NSLocalizedString(@"CONNECTING", nil)];
    }else{
        [self.infoLabel setStringValue:NSLocalizedString(@"CAN_NOT_UPLOAD", nil)];
    }
}

- (IBAction)UploadButtonClicked:(id)sender{
    NSMenuItem *btn = sender;
    if(btn.tag == 1){
        //CMA SaveData
      
    }
}

- (IBAction)UploadDataFiles:(id)sender{
    NSURL *splitURL = [[Util shareInstance] getCacheFolder:@"SplitTransfer"];
    NSString *sourceName = [game[@"file"] lastPathComponent];
    sourceName = [sourceName stringByDeletingPathExtension];
    NSString *dataPath = [[splitURL URLByAppendingPathComponent:sourceName] path];
    BOOL isDir = NO;
    if([[NSFileManager defaultManager] fileExistsAtPath:dataPath isDirectory:&isDir] && isDir){
        NSURL *appURL = [[NSURL URLWithString:@"app"] URLByAppendingPathComponent:game[@"info"][@"ID"]];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.uploadButton setEnabled:NO];
                [[Util shareInstance] CreateFolderBeforeUpload:dataPath toPath:[appURL path] withProgress:^(int code, float progress, NSObject *message) {
                    NSLog(@"%d %@",code,message);
                    NSString *text = nil;
                    if(code == 0){
                        NSString *fileName = (NSString *)message;
                        text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"UPLOADING", nil),fileName];
                    }else if(code == -1 || code == -2){
                        text = NSLocalizedString(@"UPLOADED", nil);
                        [self.uploadButton setEnabled:YES];
                    }else if(code == -3){
                        [self.uploadButton setEnabled:YES];
                    }
                    if(text != nil)
                        [self.infoLabel setStringValue:text];
                }];
            });
        });
    }
    

}

- (IBAction)UploadSplitPackage:(id)sender{
    
    VitaPackageHelper *helper = [[VitaPackageHelper alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{[self.uploadButton setEnabled:NO];});
        NSString *file = [helper splitPackage:game[@"file"] withProgress:^(int state, float progress, NSString *file) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *text = @"";
                if(state == 0){
                    text = file;
                }else{
                    text = [NSString stringWithFormat:NSLocalizedString(@"EXTRACTING", nil), file,progress * 100];
                }
                if(text.length > 0)
                    [self.infoLabel setStringValue:text];
            });
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            LxFTPRequest *ftpRequest = [[Util shareInstance] UploadWithFTP:file withName:[NSString stringWithFormat:@"%@-MINI",game[@"info"][@"ID"]] withProgress:^(int code, float progress, NSObject *message) {
                NSString *text = @"";
                if(code == 1){
                    text = NSLocalizedString(@"UPLOADING", nil);
                    //Uploading...
                    //text = [NSString stringWithFormat:NSLocalizedString(@"UPLOADING_PROGRESS", nil),message,progress];
                }else if(code == 2){
                    //Success
                    text = NSLocalizedString(@"UPLOADED", nil);
                    [self.uploadButton setEnabled:YES];
                }else if (code == 0){
                    //Error
                    text = [NSString stringWithFormat:@"%@",message];
                    [self.uploadButton setEnabled:YES];
                }
                [self.infoLabel setStringValue:text];
            }];
            
            BOOL succ = [ftpRequest start];
            if(succ){
                [self.uploadButton setEnabled:NO];
                [self.infoLabel setStringValue:NSLocalizedString(@"CONNECTING", nil)];
            }else{
                [self.infoLabel setStringValue:NSLocalizedString(@"CAN_NOT_UPLOAD", nil)];
            }
        });
       
    });
 
    

}

- (IBAction)PatchGame:(id)sender{
    NSButton *btn = sender;
    NSString *infoBackup = self.infoLabel.stringValue;
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:NO];
    [panel setCanCreateDirectories:NO];
    [panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            NSArray* urls = [panel URLs];
            for (NSURL *url in urls) {
                //here how to judge the url is a directory or a file
                if (url.isFileURL) {
                    VitaPackageHelper *helper = [[VitaPackageHelper alloc] init];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [btn setEnabled:NO];
                            [btn setNeedsDisplay];
                            [self.infoLabel setStringValue:NSLocalizedString(@"PREPARING", nil)];
                        });
                        [helper patchPackage:game[@"file"] withPatchFile:[url path] withProgress:^(int state,float progress,NSString *file) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSString *text = @"";
                                if(state == 1){
                                    text = [NSString stringWithFormat:NSLocalizedString(@"EXTRACTING_WITH_PERCENT", nil), file,progress];
                                }else if (state == 2){
                                    text = [NSString stringWithFormat:NSLocalizedString(@"PATCHING_WITH_PERCENT", nil), file,progress];
                                }else if(state == 3){
                                    text = NSLocalizedString(@"REBUILDING", nil);
                                }else{
                                    text = @"";
                                    NSRunAlertPanel(NSLocalizedString(@"ERROR", nil), file, NSLocalizedString(@"OK", nil), nil,nil);
                                }
                                if(text.length > 0)
                                    [self.infoLabel setStringValue:text];
                            });
                        }];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [btn setEnabled:YES];
                            [self.infoLabel setStringValue:infoBackup];
                            [btn setNeedsDisplay];
                            [self sendNotification:@"reload_library"];
                        });
                    });
                }
            }
        }
    }];
    
    

}

- (void) viewWillDraw{
    [self.uploadButton setAction:@selector(UploadGame:)];
    [self.uploadButton setTarget:self];
    [self.patchButton setAction:@selector(PatchGame:)];
    [self.patchButton setTarget:self];
    [self initCMAMenu];
}

@end
