//
//  TypeEditViewDelegate.h
//  EditAndSelectCell
//
//  Created by zhangchaoqun on 13-7-14.
//  Copyright (c) 2013年 zhangchaoqun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TypeEditingCell.h"
@protocol TypeEditDelegate <NSObject>

-(UITableView *)tableViewForTypeEditDelegate;

@optional

@end

@interface TypeEditViewDelegate : NSObject<UITableViewDataSource,UITableViewDelegate,JZSwipeCellDelegate,TypeShowCellClickedDelegate>
{
    NSArray * sourceArr;
    
    NSMutableArray * chooseArr;
    //选中的
    
    NSMutableArray * showArr;
    //在其内的，表示已经展示的
    
    id<TypeEditDelegate> _delegate;
    
    TypeEditingCell * lastCell;
    
}
//传入的格式
@property (nonatomic,retain) NSArray * sourceArray;

-(id)initWithArray:(NSArray *)array andDelegate:(id<TypeEditDelegate>)delegate;

//设置初始化数组数据
-(void)startWithShowArray:(NSArray *)array;

//返回当前的列表数据
-(NSArray *)tableShowDataArr;


-(UITableView *)tableView;

-(void)stopTypeNameEdit;

//当前数据，挤压后
-(NSArray *)endTypeEditWithNowType;

//当前横列数据
-(NSArray *)endEditTypeWithNowTypeData;


@end
