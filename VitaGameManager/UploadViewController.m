//
//  UploadViewController.m
//  VitaGameManager
//
//  Created by Hex Pang on 16/9/3.
//  Copyright © 2016年 HexPang. All rights reserved.
//

#import "UploadViewController.h"
#import "LxFTPRequest.h"

@interface UploadViewController (){
    NSMutableArray *queue;
    NSDictionary *config;
    LxFTPRequest *ftpRequest;
}

@end

@implementation UploadViewController

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSMutableDictionary *item = queue[row];
    if([tableColumn.identifier isEqualToString:@"id"]){
        return item[@"info"][@"ID"];
    }else if([tableColumn.identifier isEqualToString:@"file"]){
        return item[@"file"];
    }else if([tableColumn.identifier isEqualToString:@"msg"]){
        return item[@"message"];
    }else {
        return item[@"progress"];
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [queue count];
}

- (void)gameItemNotification:(NSNotification *)notification {
    NSDictionary *notify = notification.object;
    NSString *action = notify[@"action"];
    NSDictionary *g = notify[@"game"];
    if([action isEqualToString:@"upload"]){
        for (NSDictionary *item in queue) {
            if([item isEqualToDictionary:g]){
                return;
            }
        }
        NSMutableDictionary *game = [[NSMutableDictionary alloc] initWithDictionary:g];
        [queue addObject:game];
        [self.tableView reloadData];
    }else if([action isEqualToString:@"splitTransfer"]){
        NSMutableDictionary *game = [[NSMutableDictionary alloc] initWithDictionary:g];
        game[@"file"] = notify[@"file"];
        [queue addObject:game];
        [self.tableView reloadData];
    }
}

- (void) doQueue{
    NSDictionary *game = [[NSDictionary alloc] initWithDictionary:queue[0]];
    [queue removeObjectAtIndex:0];
    

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
  
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameItemNotification:) name:@"GAME_ITEM_NOTIFICATION" object:nil];
    if(!queue){
        queue = [[NSMutableArray alloc] init];
    }
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
