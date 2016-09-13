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
    NSString *rootFolder;
    NSString *currentFolder;
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
    [item setPath:fileName];
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

- (void)gameItemNotification:(NSNotification *)notification {
    NSDictionary *notify = notification.object;
    NSString *action = notify[@"action"];
    NSString *param = notify[@"param"];
    if([action isEqualToString:@"open"]){
        NSString *path = param;
        NSLog(@"Path : %@",path);
        [self ListFolderViaFTP:path];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameItemNotification:) name:@"MY_VITA_NOTIFICATION" object:nil];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)ListFolderViaFTP:(NSString *)folder{
    if(rootFolder == nil){
        rootFolder = @"/";
    }
    if([folder isEqualToString:@"/"]){
        currentFolder = @"";
        folder = @"";
    }
    if(currentFolder != nil && ![currentFolder isEqualToString:@"/"] && ![folder isEqualToString:@"/"] && ![folder isEqualToString:currentFolder]){
        folder = [NSString stringWithFormat:@"%@%@",currentFolder,folder];
    }
    LxFTPRequest *ftpRequest = [[Util shareInstance] ListWithFTP:[folder stringByAppendingString:@"/"] withProgress:^(int code, float progress, NSObject *message) {
        if(code == 2){
            if(![folder isEqualToString:@"/"]){
                currentFolder = [folder stringByAppendingString:@"/"];
            }else{
                currentFolder = folder;
            }
            folderList = (NSArray *)message;
            [self.collectionView reloadData];
        }else if(code == 0){
            //Error
            NSLog(@"%@",message);
        }
    }];
    BOOL succ = [ftpRequest start];
    if(!succ){
        NSLog(@"Can't fetch FTP.");
    }
}

- (IBAction)ConnectToMyVita_Clicked:(id)sender{
    [self ListFolderViaFTP:@"/"];
//    NSButton *btn = (NSButton *)sender;
//    [btn setEnabled:NO];
//    LxFTPRequest *ftpRequest = [[Util shareInstance] ListWithFTP:@"/" withProgress:^(int code, float progress, NSObject *message) {
//        if(code == 2){
//            folderList = (NSArray *)message;
//            [self.collectionView reloadData];
//        }else if(code == 0){
//            //Error
//            NSLog(@"%@",message);
//        }
//        [btn setEnabled:YES];
//    }];
//    if(![ftpRequest start]){
//        [btn setEnabled:YES];
//    }
}

@end
