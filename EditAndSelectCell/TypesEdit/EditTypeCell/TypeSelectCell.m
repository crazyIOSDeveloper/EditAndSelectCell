//
//  TypeSelectCell.m
//  EditAndSelectCell
//
//  Created by zhangchaoqun on 13-7-14.
//  Copyright (c) 2013年 zhangchaoqun. All rights reserved.
//

#import "TypeSelectCell.h"
@interface TypeSelectCell()
- (void)configureCell;
@end

@implementation TypeSelectCell
@synthesize typeTxtLbl;
@synthesize subTypeCellBtn;
@synthesize chooseBtn;
@synthesize clickedDelegate;
@synthesize showImgBtn;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self configureCell];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self ) {
		[self configureCell];
	}
	
	return self;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	[self configureCell];
}

-(void)configureCell
{
    if(!self.typeTxtLbl)
    {
        UILabel * lbl = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)] autorelease];
        self.typeTxtLbl = lbl;
        [self addSubview:lbl];
        
        lbl.font = [UIFont systemFontOfSize:20];
        lbl.backgroundColor=[UIColor clearColor];
        
    }
    if (!self.chooseBtn)
    {
        UIButton  * bigBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        bigBtn.frame = CGRectMake(0, 0, 70, 44);
        [bigBtn addTarget:self action:@selector(clickedOnChooseSelectCell:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:bigBtn];
        self.chooseBtn = bigBtn;
        
        
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 30, 30);
        [bigBtn addSubview:btn];
        self.showImgBtn = btn;
        //        [btn setTitle:@"选中" forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"Unselected.png"] forState:UIControlStateNormal];
        //        [btn addTarget:self action:@selector(clickedOnChooseSelectCell:) forControlEvents:UIControlEventTouchUpInside];
        btn.center = CGPointMake(bigBtn.frame.size.width, bigBtn.frame.size.height);
        btn.userInteractionEnabled = NO;

        btn.center = CGPointMake(bigBtn.frame.size.width/2.0, bigBtn.frame.size.height/2.0);

    }
    if (!self.subTypeCellBtn)
    {
        
        
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 30, 30);
        [self addSubview:btn];
        
//        [btn setTitle:@"子类" forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"Folder56.png"] forState:UIControlStateNormal];
        self.subTypeCellBtn = btn;
        [btn addTarget:self action:@selector(clickedOnOpenCell:) forControlEvents:UIControlEventTouchUpInside];
        
    }
}


-(void)clickedOnOpenCell:(id)sender
{
    if (self.clickedDelegate&&[self.clickedDelegate respondsToSelector:@selector(clickedForOpenOnCell:)])
    {
        [self.clickedDelegate clickedForOpenOnCell:self];
    }
}
-(void)clickedOnChooseSelectCell:(id)sender
{
    if (self.clickedDelegate&&[self.clickedDelegate respondsToSelector:@selector(clickedForChooseOnCell:)])
    {
        [self.clickedDelegate clickedForChooseOnCell:self];
    }
    
}



- (void)layoutSubviews
{
    [super layoutSubviews];
    //确定位置
    int countNum = self.indentationLevel;
    
    float startPointX = 10+countNum*self.indentationWidth;
    float height = self.frame.size.height;
    float width = self.frame.size.width;
    
    self.subTypeCellBtn.center = CGPointMake(startPointX + self.subTypeCellBtn.frame.size.width/2.0 , height/2.0);
    
    self.chooseBtn.center = CGPointMake(width-20-self.chooseBtn.frame.size.width/2.0, height/2.0);
    
    self.typeTxtLbl.frame = CGRectMake(startPointX+self.subTypeCellBtn.frame.size.width+20,0,width - startPointX -10 -10 -self.chooseBtn.frame.size.width - self.subTypeCellBtn.frame.size.width ,height);

//    [self addNormalBottomLineToCell];
    
}
//设定选中与否状态
-(void)setTypeSelectCellType:(BOOL)selected
{
    if (selected)
    {
        [self.showImgBtn setBackgroundImage:[UIImage imageNamed:@"Selected.png"] forState:UIControlStateNormal];
    }else
    {
        [self.showImgBtn setBackgroundImage:[UIImage imageNamed:@"Unselected.png"] forState:UIControlStateNormal];
    }
    
    
}



- (void)prepareForReuse
{
    [super prepareForReuse];
    //数据清空
    [self setTypeSelectCellType:NO];

}

+(NSString *)cellID
{
    return @"TypeSelectCell";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
