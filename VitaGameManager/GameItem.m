//
//  GameItem.m
//  VitaGameManager
//
//  Created by Hex Pang on 16/9/2.
//  Copyright © 2016年 HexPang. All rights reserved.
//

#import "GameItem.h"
#import "GameItemView.h"

@interface GameItem (){
}

@end

@implementation GameItem

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}




- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    GameItemView *infoView = (GameItemView*)self.view;
    if (selected){
        [infoView.infoView setHidden:NO];
    }
    else{
        [infoView.infoView setHidden:YES];
    }
}

@end
