//
//  ViewController.m
//  LVFrameAnimation
//
//  Created by meipai_lv on 2018/4/3.
//  Copyright © 2018年 Meipai_Lv. All rights reserved.
//

#import "ViewController.h"
#import "AllScreenFrameAnimationBaseController.h"
#import "SpriteFrameAnimationBaseController.h"

#import "MTFactoryObject.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource> {
    NSArray<MTFactoryClassObject *> *_itemsArray;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.TableView.delegate = self;
    self.TableView.dataSource = self;
    [self.TableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    _itemsArray = @[[MTFactoryClassObject createObjectWithName:@"全屏帧动画处理方案"
                                                       object:[AllScreenFrameAnimationBaseController class]],
                   [MTFactoryClassObject createObjectWithName:@"小精灵帧动画处理方案"
                                                       object:[SpriteFrameAnimationBaseController class]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *vc = [[(_itemsArray[indexPath.row]).obj alloc] init];
    vc.title = _itemsArray[indexPath.row].title;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = _itemsArray[indexPath.row].title;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _itemsArray.count;
}

@end
