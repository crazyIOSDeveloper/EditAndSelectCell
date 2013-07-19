//
//  TypeChooseController.h
//  LocalShopManager
//
//  Created by zhangchaoqun on 13-7-16.
//  Copyright (c) 2013年 zhangchaoqun. All rights reserved.
//

//#import "LSMDetailViewController.h"

#import "JZSwipeCell.h"
#import "TypeEditViewDelegate.h"
#import "TypeSelectViewDelegate.h"
//进行类型编辑的数据库操作，提供数据，保存数据、修改数据

@interface TypeChooseController : UIViewController<TypeSelectDelegate,TypeEditDelegate>
{
    UITableView * _tableView;
    
    TypeEditViewDelegate * editDlgObj;
    TypeSelectViewDelegate * selectDlbObj;
    
}

@property (nonatomic,retain) NSMutableArray * dataArr;


@end
