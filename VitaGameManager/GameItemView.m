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
}

- (void)setGame:(NSDictionary *)info{
    game = info;
}


- (IBAction)UploadGame:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UPLOAD_NOTIFICATION" object:game userInfo:nil];

}

- (void) viewWillDraw{
    [self.uploadButton setAction:@selector(UploadGame:)];
    [self.uploadButton setTarget:self];
}

@end
