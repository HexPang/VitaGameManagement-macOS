//
//  MyVitaView.m
//  VitaGameManager
//
//  Created by Hex Pang on 16/9/9.
//  Copyright © 2016年 HexPang. All rights reserved.
//

#import "MyVitaView.h"

@implementation MyVitaView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (IBAction)MenuClicked:(id)sender{
    NSMenuItem *menu = (NSMenuItem *)sender;
    if(menu){
        if(menu.tag == 1){
            //Open
            NSTextField *textField = [self viewWithTag:2];
            [self sendNotification:@"open" withParam:textField.stringValue];
        }
    }
}

- (void)sendNotification:(NSString *)action withParam:(NSString *)param{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MY_VITA_NOTIFICATION" object:@{@"param":param,@"action":action} userInfo:nil];
}

@end
