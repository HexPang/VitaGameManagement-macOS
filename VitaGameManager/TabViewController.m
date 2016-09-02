//
//  TabViewController.m
//  VitaGameManager
//
//  Created by Hex Pang on 16/9/3.
//  Copyright © 2016年 HexPang. All rights reserved.
//

#import "TabViewController.h"

@interface TabViewController ()

@end

@implementation TabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    NSURL *library = [[NSUserDefaults standardUserDefaults] URLForKey:@"library"];
    if(library != nil){
        [self setSelectedTabViewItemIndex:0];
    }
}

@end
