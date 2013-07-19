//
//  TypeEditingCell.m
//  EditAndSelectCell
//
//  Created by zhangchaoqun on 13-7-14.
//  Copyright (c) 2013年 zhangchaoqun. All rights reserved.
//

#import "TypeEditingCell.h"

@implementation TypeEditingCell
@synthesize typeTxtLbl;
@synthesize addSubTypeBtn;
@synthesize subTypeCellBtn;
@synthesize clickedDelegate;
@synthesize editTfd;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.imageSet = SwipeCellImageSetMake([UIImage imageNamed:@"balloons"], [UIImage imageNamed:@"balloons"], [UIImage imageNamed:@"ice-cream"], [UIImage imageNamed:@"ice-cream"]);
		self.colorSet = SwipeCellColorSetMake([UIColor greenColor], [UIColor greenColor], [UIColor redColor], [UIColor redColor]);
		[self configureCellForEditing];
	}
	
	return self;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	[self configureCellForEditing];
}
-(void)configureCellForEditing
{
    if(!self.typeTxtLbl)
    {
        UILabel * lbl = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)] autorelease];
        self.typeTxtLbl = lbl;
        [self.contentView addSubview:lbl];

        
        lbl.font = [UIFont systemFontOfSize:20];
        lbl.backgroundColor=[UIColor clearColor];
        
#ifdef SHOWTESTCOLOR
        lbl.backgroundColor = [UIColor redColor];
#endif
        
    }
    if (!self.subTypeCellBtn)
    {
        
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 30, 30);
        [self.contentView addSubview:btn];
        
        //        [btn setTitle:@"子类" forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"Folder56.png"] forState:UIControlStateNormal];
        self.subTypeCellBtn = btn;
        [btn addTarget:self action:@selector(clickedOnOpenCell:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    if (!self.editTfd)
    {
        UITextField * tfd = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
        [self.typeTxtLbl addSubview:tfd];
        [tfd release];
        
        self.editTfd = tfd;
        tfd.hidden = YES;
        tfd.font = [UIFont systemFontOfSize:20];
        tfd.borderStyle = UITextBorderStyleRoundedRect;
        tfd.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        tfd.backgroundColor = [UIColor whiteColor];
    }
    if (!self.addSubTypeBtn)
    {
        UIButton  * bigBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        bigBtn.frame = CGRectMake(0, 0, 70, 44);
        [bigBtn addTarget:self action:@selector(clickedOnChooseBigBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:bigBtn];
        self.addSubTypeBtn = bigBtn;
        
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 20, 10);
        [bigBtn addSubview:btn];
        
        //        [btn setTitle:@"选中" forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"DownAccessory.png"] forState:UIControlStateNormal];
        btn.center = CGPointMake(bigBtn.frame.size.width/2.0, bigBtn.frame.size.height/2.0);
        btn.userInteractionEnabled = NO;
                
#ifdef SHOWTESTCOLOR
        bigBtn.backgroundColor = [UIColor blueColor];
#endif
        
    }
    

    
}
-(void)clickedOnChooseBigBtn:(id)sender
{
    [self clickedOnChooseSelectCell:self.addSubTypeBtn];
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
-(void)startEditNameWithEditTfd
{
    self.editTfd.hidden = NO;
    self.editTfd.text = self.typeTxtLbl.text;
    [self.editTfd becomeFirstResponder];
    
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(textFieldEndEdit:)
                   name:UITextFieldTextDidEndEditingNotification
                 object:nil];
    
}
-(void)endTfdEditName
{
    [self.editTfd resignFirstResponder];
}
-(void)textFieldEndEdit:(id)sender
{
    self.editTfd.hidden = YES;
    self.typeTxtLbl.text = self.editTfd.text;
    
    //此处需要代理，修改数据
    if (self.clickedDelegate&&[self.clickedDelegate respondsToSelector:@selector(endEditTypeCell:withString:)])
    {
        NSString * lastStr = self.editTfd.text;
        [self.clickedDelegate endEditTypeCell:self withString:lastStr];
    }
    
    
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self
                      name:UITextFieldTextDidEndEditingNotification
                    object:nil];
    
}
- (void)prepareForReuse
{
    [super prepareForReuse];
    //数据清空

    
    
}



- (void)layoutSubviews
{
    [super layoutSubviews];
    //确定位置
    int countNum = self.indentationLevel;
    
    float startPointX = 10+countNum*self.indentationWidth;
    float height = self.contentView.frame.size.height;
    float width = self.contentView.frame.size.width;
    
    self.subTypeCellBtn.center = CGPointMake(startPointX + self.subTypeCellBtn.frame.size.width/2.0 , height/2.0);
    
    self.addSubTypeBtn.center = CGPointMake(width-20-self.addSubTypeBtn.frame.size.width/2.0, height/2.0);
    
    self.typeTxtLbl.frame = CGRectMake(startPointX+self.subTypeCellBtn.frame.size.width+20,0,width - startPointX -10 -10 -self.addSubTypeBtn.frame.size.width - self.subTypeCellBtn.frame.size.width ,height);
    
    
    self.editTfd.frame = self.typeTxtLbl.bounds;
    
//    [self addNormalBottomLineToCell];
    
}
+(NSString *)cellID
{
    return @"TypeEditingCell";
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void)dealloc
{
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self
                      name:UITextFieldTextDidEndEditingNotification
                    object:nil];
    
    
    [super dealloc];
}


@end
