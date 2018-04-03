//
//  AllScreenFrameAnimationBaseController.m
//  LVFrameAnimation
//
//  Created by meipai_lv on 2018/4/3.
//  Copyright © 2018年 Meipai_Lv. All rights reserved.
//

#import "AllScreenFrameAnimationBaseController.h"
#import "NomalAllScreenFrameAnimationController.h"
#import "LVAllScreenFrameAnimationController.h"

#import "MTFactoryObject.h"

@interface AllScreenFrameAnimationBaseController () {
    NSArray<MTFactoryClassObject *> *_itemsArray;
}
@end

@implementation AllScreenFrameAnimationBaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    _itemsArray = @[[MTFactoryClassObject createObjectWithName:@"UIImageView.Animations"
                                                        object:[NomalAllScreenFrameAnimationController class]],
                    [MTFactoryClassObject createObjectWithName:@"NSCache+Sqlite3+Queue"
                                                        object:[LVAllScreenFrameAnimationController class]]];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

#pragma mark - TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *vc = [[(_itemsArray[indexPath.row]).obj alloc] init];
    vc.title = _itemsArray[indexPath.row].title;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - TableViewData source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _itemsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = (_itemsArray[indexPath.row]).title;
    return cell;
}

@end
