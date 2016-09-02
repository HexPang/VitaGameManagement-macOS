//
//  SettingViewController.h
//  VitaGameManager
//
//  Created by Hex Pang on 16/9/3.
//  Copyright © 2016年 HexPang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SettingViewController : NSViewController
@property (weak,nonatomic) IBOutlet NSTextField *libraryField;

@property (weak,nonatomic) IBOutlet NSTextField *vitaIPField;
@property (weak,nonatomic) IBOutlet NSTextField *vitaPortField;
@end
