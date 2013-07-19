//
//  TypeSelectCell.h
//  EditAndSelectCell
//
//  Created by zhangchaoqun on 13-7-14.
//  Copyright (c) 2013年 zhangchaoqun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TypeSelectCell;
@protocol TypeShowCellClickedDelegate <NSObject>

@optional
-(void)clickedForChooseOnCell:(UITableViewCell *)cell;
-(void)clickedForOpenOnCell:(UITableViewCell *)cell;

-(void)endEditTypeCell:(UITableViewCell *)cell withString:(NSString *)str;


@end

@interface TypeSelectCell : UITableViewCell
//此界面需要的控件 1、选中标记（控制选中与否）
//2、打开子项按钮(文件夹、打开子目录)
//3、展示lbl，提供内容展示
@property (nonatomic,assign)id<TypeShowCellClickedDelegate> clickedDelegate;

@property (nonatomic,retain)IBOutlet UILabel * typeTxtLbl;

@property (nonatomic,retain)IBOutlet UIButton * subTypeCellBtn;

@property (nonatomic,retain)IBOutlet UIButton * chooseBtn;
@property (nonatomic,retain)IBOutlet UIButton * showImgBtn;

//设定选中与否状态
-(void)setTypeSelectCellType:(BOOL)select;

+(NSString *)cellID;




@end
