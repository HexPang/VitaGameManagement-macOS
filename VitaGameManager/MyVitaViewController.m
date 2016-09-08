//
//  MyVitaViewController.m
//  VitaGameManager
//
//  Created by Hex Pang on 16/9/6.
//  Copyright © 2016年 HexPang. All rights reserved.
//

#import "MyVitaViewController.h"

@interface MyVitaViewController (){
    NSArray *folderList;
}

@end

@implementation MyVitaViewController

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath{
    MyVitaViewItem *item = [collectionView makeItemWithIdentifier:@"MyVitaViewItem" forIndexPath:indexPath];
    NSTextField *title = [item.view viewWithTag:2];
    NSImageView *icon = [item.view viewWithTag:1];
    NSDictionary *file = folderList[indexPath.item];
    NSString *iconName = @"";
    NSString *fileName = file[@"kCFFTPResourceName"];
    [title setStringValue:fileName];
    if([file[@"kCFFTPResourceType"] intValue] == 4){
        //Folder
        iconName = @"Folder";
    }else{
        //File
        iconName = @"File";
        if([file[@"kCFFTPResourceType"] intValue] == 8){
            if([[[fileName pathExtension] lowercaseString] isEqualToString:@"vpk"]){
                iconName = @"VPK";
            }
        }
    }
    [icon setImage:[NSImage imageNamed:iconName]];
    return item;
}

- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [folderList count];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (IBAction)ConnectToMyVita_Clicked:(id)sender{
    NSButton *btn = (NSButton *)sender;
    [btn setEnabled:NO];
    LxFTPRequest *ftpRequest = [[Util shareInstance] ListWithFTP:@"/" withProgress:^(int code, float progress, NSObject *message) {
        if(code == 2){
            folderList = (NSArray *)message;
            [self.collectionView reloadData];
        }else if(code == 0){
            //Error
            NSLog(@"%@",message);
        }
        [btn setEnabled:YES];
    }];
    if(![ftpRequest start]){
        [btn setEnabled:YES];
    }
}

@end
