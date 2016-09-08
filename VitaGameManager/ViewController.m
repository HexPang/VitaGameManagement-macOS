//
//  ViewController.m
//  VitaGameManager
//
//  Created by Hex Pang on 16/9/2.
//  Copyright © 2016年 HexPang. All rights reserved.
//

#import "ViewController.h"
#import "VitaPackageHelper.h"
#import "GameItem.h"
#import "GameItemView.h"

@implementation ViewController{
    NSArray *gameList;
    NSDictionary *regionPrefix;
}

- (void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths{
//    NSLog(@"Selected %@",self.menu);
    if([indexPaths count] > 0){
        [self.rightMenu popUpMenuPositioningItem:nil atLocation:[NSEvent mouseLocation] inView:collectionView];
        
    }
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *game = gameList[indexPath.item];
    
    GameItem *item = [collectionView makeItemWithIdentifier:@"GameItem" forIndexPath:indexPath];
    GameItemView *itemView = (GameItemView *)item.view;
    [itemView setGame:game];
    [itemView.titleLabel setStringValue:game[@"info"][@"TITLE"]];
    NSString *cacheDir = [[[Util shareInstance] getCacheFolder:@"icon"] path];
    NSString *dir = [NSString stringWithFormat:@"%@/%@",cacheDir,game[@"info"][@"CONTENT_ID"]];
    NSString *iconFile =[NSString stringWithFormat:@"%@/icon0.png",dir];
    NSString *picFile = [NSString stringWithFormat:@"%@/pic0.png",dir];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:picFile]){
        NSData *picData = [[NSData alloc] initWithContentsOfFile:picFile];
        [itemView.backgroundView setImage:[[NSImage alloc] initWithData:picData]];
    }
    
    if([[NSFileManager defaultManager] fileExistsAtPath:iconFile]){
        NSData *iconData = [[NSData alloc] initWithContentsOfFile:iconFile];
        [itemView.iconView setImage:[[NSImage alloc] initWithData:iconData]];
    }
    

    
    NSString *gameRegion = @"";
    
    for (NSString *prefix in regionPrefix) {
        if([game[@"info"][@"ID"] hasPrefix:prefix]){
            gameRegion = regionPrefix[prefix];
            break;
        }
    }
    
    unsigned long long size = [[NSFileManager defaultManager] attributesOfItemAtPath:game[@"file"] error:nil].fileSize;
    
    NSString *gameSize = @"";
   
    //[NSByteCountFormatter stringFromByteCount:1999 countStyle:NSByteCountFormatterCountStyleFile];

    gameSize = [NSByteCountFormatter stringFromByteCount:size countStyle:NSByteCountFormatterCountStyleFile];
    NSLog(@"%@",NSLocalizedString(@"GAME_INFO_TEXT", nil));
    NSString *infoText = [NSString stringWithFormat:NSLocalizedString(@"GAME_INFO_TEXT", nil),game[@"info"][@"ID"],gameSize,gameRegion];
    
    [itemView.infoLabel setStringValue:infoText];
//    [itemView.infoLabel.layer setMasksToBounds:YES];
//    [itemView.infoLabel.layer setCornerRadius:5];
    
    if(game[@"info"][@"APP_VER"] != nil){
        [itemView.versionLabel setStringValue:game[@"info"][@"APP_VER"]];
    }else{
        [itemView.versionLabel setHidden:YES];
    }

    return item;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [gameList count];
}

- (void)notificationRecv:(NSNotification *)notification {
    NSDictionary *notify = notification.object;
    NSString *action = notify[@"action"];
    NSDictionary *g = notify[@"game"];
    if([action isEqualToString:@"reload_library"]){
        [self loadGames];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.collectionView setDelegate:self];
    [self.collectionView setDataSource:self];
    regionPrefix = @{@"PCSF":@"EU",@"PCSE":@"US",@"PCSG":@"JP",@"PCSH":@"HK",@"PCSD":@"CN",@"PCSB":@"AU",@"PCSA":@"US"};
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationRecv:) name:@"GAME_ITEM_NOTIFICATION" object:nil];
}

- (void)loadGames{
    VitaPackageHelper *helper = [[VitaPackageHelper alloc]init];
//    [helper splitPackage:@"/Volumes/Mac/PSVita_VPK/Split/MC.VPK" withProgress:^(int state, float progress, NSString *file) {
////        NSLog(@"%@ - %.2f",file,progress);
//    }];
//    return;
    NSURL *library = [[NSUserDefaults standardUserDefaults] URLForKey:@"library"];
    if(library != nil){
        gameList = [helper loadPackage:library.path];
        [self.collectionView reloadData];
    }
}

- (void)viewDidAppear{
    [self loadGames];
}

@end
