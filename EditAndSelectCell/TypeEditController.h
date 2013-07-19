//
//  TypeEditController.h
//  EditAndSelectCell
//
//  Created by zhangchaoqun on 13-7-14.
//  Copyright (c) 2013年 zhangchaoqun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JZSwipeCell.h"

#import "TypeEditViewDelegate.h"
#import "TypeSelectViewDelegate.h"
@interface TypeEditController : UIViewController<TypeSelectDelegate,TypeEditDelegate>
{
    UITableView * _tableView;
    TypeEditViewDelegate * editDlgObj;
    TypeSelectViewDelegate * selectDlbObj;
    
}



@property (nonatomic,retain) NSMutableArray * dataArr;



@end
