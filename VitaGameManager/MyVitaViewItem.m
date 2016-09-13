//
//  MyVitaViewItem.m
//  VitaGameManager
//
//  Created by Hex Pang on 16/9/9.
//  Copyright © 2016年 HexPang. All rights reserved.
//

#import "MyVitaViewItem.h"

@interface MyVitaViewItem (){
    NSString *path;
}
@end

@implementation MyVitaViewItem

- (void)setPath:(NSString *)p{
    path = p;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    //
    if (selected){
        [self.view setAlphaValue:0.8f];
        //        [infoView.infoView setHidden:NO];
    }
    else{
        [self.view setAlphaValue:1.0f];
        //        [infoView.infoView setHidden:YES];
    }
}

@end
