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

    
    VitaPackageHelper *helper = [[VitaPackageHelper alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [btn setEnabled:NO];
            [btn setNeedsDisplay];
        });
        [helper patchPackage:@"/Volumes/Mac/PSVita_VPK/Test/source.zip" withPatchFile:@"/Volumes/Mac/PSVita_VPK/Test/patch.zip" withProgress:^(long total, int current) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.infoLabel setStringValue:[NSString stringWithFormat:@"Patching %.0f%%", (double)current / (double)total * 100 ]];
            });
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [btn setEnabled:YES];
            [self.infoLabel setStringValue:infoBackup];
            [btn setNeedsDisplay];
        });
    });
    

}

- (void) viewWillDraw{
    [self.uploadButton setAction:@selector(UploadGame:)];
    [self.uploadButton setTarget:self];
    [self.patchButton setAction:@selector(PatchGame:)];
    [self.patchButton setTarget:self];
}

@end
