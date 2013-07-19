//
//  TypeEditingCell.h
//  EditAndSelectCell
//
//  Created by zhangchaoqun on 13-7-14.
//  Copyright (c) 2013年 zhangchaoqun. All rights reserved.
//

#import "JZSwipeCell.h"
#import "TypeSelectCell.h"

@interface TypeEditingCell : JZSwipeCell<UITextFieldDelegate>
{
    
}

@property (nonatomic,assign)id<TypeShowCellClickedDelegate> clickedDelegate;

@property (nonatomic,retain)IBOutlet UILabel * typeTxtLbl;

@property (nonatomic,retain)IBOutlet UIButton * subTypeCellBtn;

@property (nonatomic,retain)IBOutlet UIButton * addSubTypeBtn;

@property (nonatomic,retain) UITextField * editTfd;

-(void)startEditNameWithEditTfd;
-(void)endTfdEditName;
+(NSString *)cellID;



@end
