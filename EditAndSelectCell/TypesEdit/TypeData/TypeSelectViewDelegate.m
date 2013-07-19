//
//  TypeSelectViewDelegate.m
//  EditAndSelectCell
//
//  Created by zhangchaoqun on 13-7-15.
//  Copyright (c) 2013年 zhangchaoqun. All rights reserved.
//

#import "TypeSelectViewDelegate.h"
#import "TypeSelectCell.h"
#import "TypeDataObj.h"
@interface TypeSelectViewDelegate()
@property (nonatomic,retain) NSArray * totalArr;
@end

@implementation TypeSelectViewDelegate
@synthesize sourceArray;
@synthesize totalArr;
-(id)initWithArray:(NSArray *)array andDelegate:(id<TypeSelectDelegate>)delegate;
{
    self = [super init];
    if(self)
    {
        _delegate = delegate;
        chooseArr = [[NSMutableArray alloc] init];
        showArr = [[NSMutableArray alloc] init];
    }
    self.sourceArray = array;
    
    return self;
}

//设置初始化数组数据
-(void)startWithShowArray:(NSArray *)array
{
    [showArr removeAllObjects];
    [showArr addObjectsFromArray:array];
}

//返回当前的列表数据
-(NSArray *)tableShowDataArr
{
    return showArr;
}
-(UITableView *)tableView
{
    if (_delegate&&[_delegate respondsToSelector:@selector(tableViewForTypeSelectDelegate)])
    {
        return [_delegate tableViewForTypeSelectDelegate];
    }
    return nil;
}

-(void)setSourceArray:(NSArray *)data
{
    if (sourceArr)
    {
        [sourceArr release];
        sourceArr = nil;
    }
    sourceArr = [data retain];
    
    
//    NSArray * array =[TypeDataObj totalSubTypesArrayFromArr:data];
//    self.totalArr = array;
    self.totalArr = data;
    
    
    [showArr removeAllObjects];
    [showArr addObjectsFromArray:data];
}



-(void)clickenOnFinishedSelected:(id)sender
{
    //填充数据chooseArr
    
    if (_delegate&&[_delegate respondsToSelector:@selector(endSelectWithChooseTypeArray:)])
    {
        [_delegate endSelectWithChooseTypeArray:chooseArr];
    }
}
-(void)openSubCellsFor:(UITableView *)tableView withIndexpath:(NSIndexPath *)indexPath
{
    //可能删除，也可能增加
    
    int index = indexPath.row;
    TypeDataObj * obj = [showArr objectAtIndex:index];
    if (![obj containNext])
    {
        return;
    }
    index++;
    
    //判定子类在展示数组中有无，如果没有，添加，如果有，移除
    NSArray * arr = [self totalSubTypesArrayFor:obj];
    TypeDataObj * last = [arr lastObject];
    if ([showArr containsObject:last])
    {//移除
        NSMutableArray * pathArr = [NSMutableArray array];
        for (int i = 0;i<[arr count]; i++)
        {
            NSIndexPath * newPath = [NSIndexPath indexPathForRow:index+i inSection:indexPath.section];
            [pathArr addObject:newPath];
        }
        [showArr removeObjectsInArray:arr];
        [tableView deleteRowsAtIndexPaths:pathArr withRowAnimation:UITableViewRowAnimationLeft];
        
    }else
    {//添加
        NSMutableArray * pathArr = [NSMutableArray array];
        for (int i = 0;i<[arr count]; i++)
        {
            NSIndexPath * newPath = [NSIndexPath indexPathForRow:index+i inSection:indexPath.section];
            [pathArr addObject:newPath];
            
            id obj = [arr objectAtIndex:i];
            [showArr insertObject:obj atIndex:index+i];
        }
        [tableView insertRowsAtIndexPaths:pathArr withRowAnimation:UITableViewRowAnimationRight];
    }
}



#pragma mark TypeChooseClickedDelegate
-(void)clickedForChooseOnCell:(UITableViewCell *)cell
{
    UITableView * table = [self tableView];
    
    NSIndexPath * indexPath = [table indexPathForCell:cell];
    int index = indexPath.row;
    TypeDataObj * obj = [showArr objectAtIndex:index];
    
    if (![chooseArr containsObject:obj])
    {
        [chooseArr addObject:obj];
        [(TypeSelectCell *)cell setTypeSelectCellType:YES];
    }else
    {
        [chooseArr removeObject:obj];
        [(TypeSelectCell *)cell setTypeSelectCellType:NO];
    }
    //仅能单选，所以要去掉排斥的
    
    if([obj containNext])
    {//此种情况不应显示 异常
        NSLog(@"");
        return;
    }
    
    //
    NSArray * brothers = [self brotherTypesFor:obj];
    id data = [brothers firstObjectCommonWithArray:chooseArr];
    if (data)
    {
        int newIndex = [showArr indexOfObject:data];
        NSIndexPath * newPath = [NSIndexPath indexPathForRow:newIndex inSection:indexPath.section];
        //设置状态改变
        TypeSelectCell * newCell = (TypeSelectCell *)[table cellForRowAtIndexPath:newPath];
        [newCell setTypeSelectCellType:NO];
        
        [chooseArr removeObject:data];
        //        data = [brothers firstObjectCommonWithArray:chooseArr];
    }
    
    
}
-(void)clickedForOpenOnCell:(UITableViewCell *)cell
{
    UITableView * table = [self tableView];
    NSIndexPath * indexPath =[table indexPathForCell:cell];
    [self openSubCellsFor:table withIndexpath:indexPath];
}

#pragma mark -UITableViewDelegate--
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    int index = indexPath.row;
    TypeDataObj * obj= [showArr objectAtIndex:index];
    
    TypeSelectCell * cell =[tableView dequeueReusableCellWithIdentifier:[TypeSelectCell cellID]];
    if (!cell)
    {
        cell =[[[TypeSelectCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[TypeSelectCell cellID]] autorelease];
    }
    cell.typeTxtLbl.text = obj.typeName;
	cell.indentationLevel = obj.typeLeavel;
    cell.clickedDelegate = self;
    cell.chooseBtn.hidden = obj.containNext;
    
    
    return cell;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==1)
    {
        return 0;
    }
    return [showArr count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section==1)
    {
        return 44;
    }
    return 0;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section==0)
    {
        return nil;
    }
    
    if (!finishView)
    {
        UIView * aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 44)];
//        aView.backgroundColor = [UIColor blueColor];
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [aView addSubview:btn];
        [btn setTitle:@"完成" forState:UIControlStateNormal];
        CGSize btnSize = CGSizeMake(150,40);
        btn.frame=CGRectMake(0, 0, btnSize.width, btnSize.height);
        btn.center = CGPointMake(aView.center.x, aView.center.y);
        [btn setBackgroundColor:[UIColor orangeColor]];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(clickenOnFinishedSelected:) forControlEvents:UIControlEventTouchUpInside];
        
        finishView = aView;
    }
    
 
    return finishView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self openSubCellsFor:tableView withIndexpath:indexPath];
}
#pragma mark privateMethods

-(NSArray *)totalSubTypesArrayFor:(TypeDataObj *)obj
{
    if (!self.totalArr)
    {
        NSArray * array =[TypeDataObj totalSubTypesArrayFromArr:sourceArr];
        self.totalArr = array;
    }
    
    if (![obj containNext])
    {
        return nil;
    }
    NSMutableArray * data = [NSMutableArray array];
    
    int startIndex = [totalArr indexOfObject:obj];
    startIndex++;
    for (int i = startIndex;i< [totalArr count];i++)
    {
        TypeDataObj * eveObj = [totalArr objectAtIndex:i];
        if (obj.typeLeavel>=eveObj.typeLeavel)
        {
            break;
        }
        [data addObject:eveObj];
    }
    return data;
}

//兄弟类型的对象，仅限于同一父类
-(NSArray *)brotherTypesFor:(TypeDataObj *)obj
{
    if (!self.totalArr)
    {
        NSArray * array =[TypeDataObj totalSubTypesArrayFromArr:sourceArr];
        self.totalArr = array;
    }
    NSMutableArray * newArray = [NSMutableArray array];
    int leavel = obj.typeLeavel;
    for (TypeDataObj * eveObj in totalArr)
    {
        if (eveObj.typeLeavel<=leavel)
        {
            [newArray addObject:eveObj];
        }
    }//此时的数组，obj最底层节点
    
    int index = [newArray indexOfObject:obj];
    int endIndex = index+1;
    int startIndex = index-1;
    
    NSMutableArray * data = [NSMutableArray array];
    for (int i= endIndex;i<[newArray count];i++ )
    {
        TypeDataObj * newObj = [newArray objectAtIndex:i];
        if (newObj.typeLeavel==leavel)
        {
            [data addObject:newObj];
        }else
        {
            break;
        }
    }
    for (int i= startIndex;i>0;i-- )
    {
        TypeDataObj * newObj = [newArray objectAtIndex:i];
        if (newObj.typeLeavel==leavel)
        {
            [data addObject:newObj];
        }else
        {
            break;
        }
    }
    return data;
    
}














- (void)dealloc
{
    self.sourceArray = nil;
    [finishView release];
    [chooseArr release];
    [showArr release];
    [super dealloc];
}
@end

