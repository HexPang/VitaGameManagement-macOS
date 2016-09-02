//
//  GameItem.m
//  VitaGameManager
//
//  Created by Hex Pang on 16/9/2.
//  Copyright © 2016年 HexPang. All rights reserved.
//

#import "GameItem.h"

@interface GameItem ()

@end

@implementation GameItem

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (selected)
        [self.view setAlphaValue:0.6f];
//        self.view.layer.backgroundColor = [NSColor redColor].CGColor;
    else
        [self.view setAlphaValue:1.0f];
}

@end
