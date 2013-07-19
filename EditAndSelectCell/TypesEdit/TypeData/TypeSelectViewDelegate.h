//
//  TypeSelectViewDelegate.h
//  EditAndSelectCell
//
//  Created by zhangchaoqun on 13-7-15.
//  Copyright (c) 2013年 zhangchaoqun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TypeSelectCell.h"

@protocol TypeSelectDelegate <NSObject>

-(UITableView *)tableViewForTypeSelectDelegate;

@optional
-(void)endSelectWithChooseTypeArray:(NSArray *)array;

@end

@interface TypeSelectViewDelegate : NSObject<UITableViewDataSource,UITableViewDelegate,TypeShowCellClickedDelegate>
{
    id<TypeSelectDelegate> _delegate;
    NSArray * sourceArr;
    
    NSMutableArray * chooseArr;
    //选中的
    
    NSMutableArray * showArr;
    //在其内的，表示已经展示的
    
    UIView * finishView;
}
//传入的格式
@property (nonatomic,retain) NSArray * sourceArray;


-(id)initWithArray:(NSArray *)array andDelegate:(id<TypeSelectDelegate>)delegate;

//设置初始化数组数据
-(void)startWithShowArray:(NSArray *)array;

//返回当前的列表数据
-(NSArray *)tableShowDataArr;

-(UITableView *)tableView;




@end
