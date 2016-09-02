//
//  GameItemView.h
//  VitaGameManager
//
//  Created by Hex Pang on 16/9/3.
//  Copyright © 2016年 HexPang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GameItemView : NSView
@property IBOutlet NSImageView *iconView;
@property IBOutlet NSTextField *titleLabel;
@property IBOutlet NSTextField *versionLabel;
@property IBOutlet NSImageView *backgroundView;
@end
