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

- (void)setGame:(NSDictionary *)info{
    game = info;
}


- (void)sendNotification:(NSString *)action{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GAME_ITEM_NOTIFICATION" object:@{@"game":game,@"action":action} userInfo:nil];
}

- (IBAction)UploadGame:(id)sender{
    [self sendNotification:@"upload"];
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
                            [self.infoLabel setStringValue:@"Preparing..."];
                        });
                        [helper patchPackage:game[@"file"] withPatchFile:[url path] withProgress:^(int state,float progress,NSString *file) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSString *text = @"";
                                if(state == 1){
                                    text = [NSString stringWithFormat:@"Extracting %@ %.2f", file,progress];
                                }else if (state == 2){
                                    text = [NSString stringWithFormat:@"Patching %@ %.2f", file,progress];
                                }else if(state == 3){
                                    text = @"Rebuilding...";
                                }else{
                                    text = @"";
                                    NSRunAlertPanel(@"Error", file, @"Ok", nil,nil);
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
}

@end
