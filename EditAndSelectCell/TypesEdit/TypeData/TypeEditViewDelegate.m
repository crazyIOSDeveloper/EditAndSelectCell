//
//  TypeEditViewDelegate.m
//  EditAndSelectCell
//
//  Created by zhangchaoqun on 13-7-14.
//  Copyright (c) 2013年 zhangchaoqun. All rights reserved.
//

#import "TypeEditViewDelegate.h"
#import "TypeSelectCell.h"
#import "TypeDataObj.h"
@interface TypeEditViewDelegate()
@property (nonatomic,retain) NSMutableArray * totalArr;
@end

@implementation TypeEditViewDelegate
@synthesize sourceArray;
@synthesize totalArr;
-(id)initWithArray:(NSArray *)array andDelegate:(id<TypeEditDelegate>)delegate;
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
//设置初始化数组数据，主要是为编辑与选择的动画设置
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
    if (_delegate&&[_delegate respondsToSelector:@selector(tableViewForTypeEditDelegate)])
    {
        return [_delegate tableViewForTypeEditDelegate];
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
    self.totalArr = [NSMutableArray array];
    [totalArr addObjectsFromArray:data];
    
    [showArr removeAllObjects];
    [showArr addObjectsFromArray:data];
}

-(void)closeSubCellsForIndexpath:(NSIndexPath *)indexPath inTableView:(UITableView *)table
{
    int index = indexPath.row;
    TypeDataObj * obj = [showArr objectAtIndex:index];
    int section = indexPath.section;
    
    [self closeSubCellsForTypeData:obj inSection:section];
}


-(void)closeSubCellsForTypeData:(TypeDataObj *)obj inSection:(int)section
{
    UITableView * tableView = [self tableView];
    if (![obj containNext])
    {//不包含子项，
        return;
    }
    
    int index = [showArr indexOfObject:obj];
    if (index==NSNotFound)
    {
        return;
    }
    
    //处理子类型
    NSArray * subTypes = [self directSubTypesArrayFor:obj];
    //包含子项的情况
    for (int i=0;i<[subTypes count] ;i++ )
    {
        id newObj =[subTypes objectAtIndex:i];
        [self removeSubCellsForTypeData:newObj withChangeContain:NO  withSection:section];

    }

    [tableView reloadData];
    
}

//移除的仅为showArr内容，调用的方法需要自己决定是否处理totalArr
-(void)removeSubCellsForTypeData:(TypeDataObj *)obj withChangeContain:(BOOL)change withSection:(int)section
{
    UITableView * tableView = [self tableView];
    int index = [showArr indexOfObject:obj];
    if (index==NSNotFound)
    {
        return;
    }
    
    //处理父类型
    NSArray * brothers = nil;
    if (change)
    {
        brothers= [self brotherTypesFor:obj];
    }
    
    if (brothers&&[brothers count]==0)
    {
        TypeDataObj * superObj = [self superTypeDataForTypeData:obj];
        superObj.containNext = NO;
        //此时，当前位置的上一个，肯定为其父类型
        int superIndex = [showArr indexOfObject:superObj];
        NSIndexPath * superPath =[NSIndexPath indexPathForRow:superIndex inSection:section];
        
        [tableView beginUpdates];
        [tableView reloadRowsAtIndexPaths:@[superPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
        
    }
    
    if ([obj containNext])
    {//不包含子项        //处理子类型
        NSArray * subTypes = [self directSubTypesArrayFor:obj];
        //包含子项的情况
        for (int i=0;i<[subTypes count] ;i++ )
        {
            TypeDataObj * newObj =[subTypes objectAtIndex:i];
            [self removeSubCellsForTypeData:newObj withChangeContain:change  withSection:section];
        }

    }
    
    [showArr removeObject:obj];
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:index inSection:section];
    [tableView beginUpdates];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [tableView endUpdates];

}


-(void)openSubCellsFor:(UITableView *)tableView withIndexpath:(NSIndexPath *)indexPath
{
    //可能删除，也可能增加
    int index = indexPath.row;
    int section = indexPath.section;
    TypeDataObj * obj = [showArr objectAtIndex:index];
    if (![obj containNext])
    {
        return;
    }
    index++;
    
    //判定子类在展示数组中有无，如果没有，添加，如果有，移除
    NSArray * arr = [self directSubTypesArrayFor:obj];
    TypeDataObj * last = [arr lastObject];
    
    if ([showArr containsObject:last])
    {//移除
        [self closeSubCellsForTypeData:obj inSection:section];
        
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
        [tableView beginUpdates];
        [tableView insertRowsAtIndexPaths:pathArr withRowAnimation:UITableViewRowAnimationRight];
        [tableView endUpdates];
    }
    
    [tableView reloadData];
    
}

#pragma mark TypeChooseClickedDelegate
-(void)clickedForChooseOnCell:(UITableViewCell *)cell
{
    UITableView * table = [self tableView];
    NSIndexPath * indexPath =[table indexPathForCell:cell];
    int index = indexPath.row;
    TypeDataObj * obj= [showArr objectAtIndex:index];
    if (!obj)
    {
        return;
    }
    obj.containNext = YES;
        
    TypeDataObj * newObj = [TypeDataObj typeDataObjWithTypeName:@"子项"];
    newObj.typeLeavel = obj.typeLeavel+1;
    index++;
    [showArr insertObject:newObj atIndex:index];

    [table beginUpdates];
    NSIndexPath * newIndexPath = [NSIndexPath indexPathForRow:index inSection:indexPath.section];
    [table insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [table reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [table endUpdates];
    
    int totalIndex = [self indexAtTotalArrayWithTypeDataObj:obj];
    
    if (totalIndex!=-1)
    {   
        totalIndex++;
        [totalArr insertObject:newObj atIndex:totalIndex];
    }

    
}
-(void)clickedForOpenOnCell:(UITableViewCell *)cell
{
    UITableView * table = [self tableView];
    NSIndexPath * indexPath =[table indexPathForCell:cell];

    [self openSubCellsFor:table withIndexpath:indexPath];
    [self backInputKeyBoard:nil];
}
-(void)endEditTypeCell:(UITableViewCell *)cell withString:(NSString *)str
{
    UITableView * table = [self tableView];
    NSIndexPath * indexPath = [table indexPathForCell:cell];
    
    int index = indexPath.row;
    NSLog(@"[%d] name %@",index,str);
    
    TypeDataObj * obj = [showArr objectAtIndex:index];
    obj.typeName = str;
    [TypeDataObj showNamesFromArr:showArr];
    [TypeDataObj showNamesFromArr:totalArr];
}

#pragma mark -UISCrollView---
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self backInputKeyBoard:nil];
}


#pragma mark -UITableViewDelegate--

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"showArr %@",showArr);
    int index = indexPath.row;
    TypeDataObj * obj= [showArr objectAtIndex:index];
    
    TypeEditingCell *cell = [tableView dequeueReusableCellWithIdentifier:[TypeEditingCell cellID]];
	if (!cell)
	{
		cell = [[[TypeEditingCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[TypeEditingCell cellID]] autorelease];
        cell.shortSwipeLength = 1;//仅使用左右区分，不区分长短
	}
    cell.backgroundView.backgroundColor = [UIColor whiteColor];
	cell.delegate = self;
    cell.clickedDelegate = self;
    
//    cell.typeTxtLbl.text = [NSString stringWithFormat:@"[%d](%d)%@",obj.typeLeavel,indexPath.row,obj.typeName];
    cell.typeTxtLbl.text = obj.typeName;
    
	cell.indentationLevel = obj.typeLeavel;
    cell.addSubTypeBtn.hidden = obj.containNext;
        
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
    return 0;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //可能删除，也可能增加
    
    TypeEditingCell * edit = (TypeEditingCell *)[tableView cellForRowAtIndexPath:indexPath];
    int index = indexPath.row;
    if (index>0)
    {
        index--;
    }
    CGPoint point = CGPointMake(0,index*edit.frame.size.height);
    [tableView setContentOffset:point animated:YES];
    
    [edit startEditNameWithEditTfd];

    lastCell = edit;
}




//哪几行可以编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
//当 tableview 为 editing 时,左侧按钮的 style
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}

//哪几行可以移动(可移动的行数小于等于可编辑的行数)
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    if (sourceIndexPath==destinationIndexPath)
    {
        return;
    }
    
    //只对传统的tableview,移动source位置至destination即可
    //先移除sourceIndexPath，后添加，添加到目标位置destinationIndexPath
    int section = sourceIndexPath.section;
    NSMutableArray * uploadArr = [NSMutableArray arrayWithArray:[tableView indexPathsForVisibleRows]];
    
    int startIndex = sourceIndexPath.row;
    int endIndex = destinationIndexPath.row;
    TypeDataObj * startObj = [showArr objectAtIndex:sourceIndexPath.row];
    TypeDataObj * endObj = [showArr objectAtIndex:destinationIndexPath.row];
    
    [startObj retain];
    
    BOOL slowDown = YES;
    slowDown = startIndex<endIndex?YES:NO;
    
    //对showArr的处理，可以考虑先把对象插入目标位置，之后删除原位置数据
    NSArray * sourceSub = [self totalSubTypesArrayFor:startObj];
    NSArray * destinationSbu = [self totalSubTypesArrayFor:endObj];
    
    
    //处理showArr删除
    [showArr removeObjectAtIndex:startIndex];
    NSMutableArray * deleteArr = [NSMutableArray array];
    //先全部取出
    id obj = [sourceSub lastObject];
    if ([showArr containsObject:obj])
    {//子项处于打开状态
        NSRange sourceRange = NSMakeRange(startIndex, [sourceSub count]);
        [showArr removeObjectsInRange:sourceRange];
        //需要移除动画
        //原数据的位置
        for (int i =0;i<sourceRange.length;i++)
        {
            NSIndexPath * path = [NSIndexPath indexPathForRow:i+startIndex+1 inSection:section];
            [deleteArr addObject:path];
        }
        
    }
    
    //处理totalArr删除
    int totalIndex = [self indexAtTotalArrayWithTypeDataObj:startObj];
    NSRange totalRange = NSMakeRange(totalIndex, [sourceSub count]+1);
    [totalArr removeObjectsInRange:totalRange];
    
    
    //子项未打开，无动画、需要移动total中数据
    //处理showArr添加        
    int insertIndex = endIndex;
    if (slowDown)
    {
        insertIndex = endIndex - [sourceSub count] + [destinationSbu count];
    }
    [showArr insertObject:startObj atIndex:insertIndex];
    insertIndex++;
    NSMutableArray * insertPaths = [NSMutableArray array];
    for (int i=0;i<[sourceSub count] ;i++)
    {
        id obj = [sourceSub objectAtIndex:i];
        [showArr insertObject:obj atIndex:insertIndex+i];
        
        NSIndexPath * path = [NSIndexPath indexPathForRow:insertIndex+i-1 inSection:section];
        [insertPaths addObject:path];
    }

    //totalArr处理添加
    int endTotalIndex = [self indexAtTotalArrayWithTypeDataObj:endObj];
    int endInsertIndex = endTotalIndex+[destinationSbu count]+1;

    [totalArr insertObject:startObj atIndex:endInsertIndex];
    
    endInsertIndex++;
    for (int i = 0;i<[sourceSub count] ;i++ )
    {
        id newObj = [sourceSub objectAtIndex:i];
        [totalArr insertObject:newObj atIndex:endInsertIndex+i];
    }
    
    
    [startObj release];
    
    
    
    //动画
    [tableView beginUpdates];
    [tableView deleteRowsAtIndexPaths:deleteArr withRowAnimation:UITableViewRowAnimationLeft];
    [tableView insertRowsAtIndexPaths:insertPaths withRowAnimation:UITableViewRowAnimationRight];
    [tableView endUpdates];
    
    [tableView beginUpdates];
    [tableView reloadRowsAtIndexPaths:uploadArr withRowAnimation:UITableViewRowAnimationFade];
    [tableView endUpdates];
    
    [tableView reloadData];
    
}
- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    UITableViewCell * source = [tableView cellForRowAtIndexPath:sourceIndexPath];
    UITableViewCell * pose = [tableView cellForRowAtIndexPath:proposedDestinationIndexPath];
    if (source.indentationLevel==pose.indentationLevel)
    {
        int startIndex = sourceIndexPath.row;
        int endIndex = proposedDestinationIndexPath.row;
        TypeDataObj * typeObj = [showArr objectAtIndex:startIndex];
        TypeDataObj * anotherOjb = [showArr objectAtIndex:endIndex];
        NSArray * brothers = [self brotherTypesFor:typeObj];
        
        if ([brothers containsObject:anotherOjb])
        {
            return proposedDestinationIndexPath;
        }
        
    }
    
    return sourceIndexPath;
}

#pragma mark - JZSwipeCellDelegate methods

- (void)swipeCell:(JZSwipeCell*)cell triggeredSwipeWithType:(JZSwipeType)swipeType
{
    UITableView * _tableView = [self tableView];
	if (swipeType != JZSwipeTypeNone)
	{
        NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
        int index = indexPath.row;
        
        
        //添加，复制
        if ([cell isRightSwipeType:swipeType]&&indexPath)
        {
            id data =[showArr objectAtIndex:index];
            int totalIndex = [self indexAtTotalArrayWithTypeDataObj:data];
            id obj = [data copy];
            
            [totalArr insertObject:obj atIndex:totalIndex];
            [showArr insertObject:obj atIndex:index];
//            index;

            NSIndexPath * newPath = [NSIndexPath indexPathForRow:index inSection:indexPath.section];
            [_tableView insertRowsAtIndexPaths:@[newPath] withRowAnimation:UITableViewRowAnimationLeft];
        }
        
        //删除，删除比新增复杂，需要考虑删除后父类型无子项
        if ([cell isLeftSwipeType:swipeType]&&indexPath)
        {
            TypeDataObj * data = [showArr objectAtIndex:index];
            
            //检查是否需要修改父类型
            NSArray * brothers = [self brotherTypesFor:data];
            if (!brothers||[brothers count]==0)
            {
                TypeDataObj * superObj = [self superTypeDataForTypeData:data];
                if (superObj)
                {
                    int superIndex = [showArr indexOfObject:superObj];
                    superObj.containNext = NO;
                    
                    NSIndexPath * superPath =[NSIndexPath indexPathForRow:superIndex inSection:indexPath.section];
                    [_tableView reloadRowsAtIndexPaths:@[superPath] withRowAnimation:UITableViewRowAnimationFade];
                }
                                
            }
            
            
            //处理动画，以及showArr
            int section = indexPath.section;
            [self removeSubCellsForTypeData:data withChangeContain:YES withSection:section];
            
            NSArray * array = [self totalSubTypesArrayFor:data];
            
            //totalArr数据处理
            [totalArr removeObject:data];
            [totalArr removeObjectsInArray:array];
        }
        
        [_tableView reloadData];
        
	}
	
}




- (void)swipeCell:(JZSwipeCell *)cell swipeTypeChangedFrom:(JZSwipeType)from to:(JZSwipeType)to
{
	// perform custom state changes here
	NSLog(@"Swipe Changed From (%d) To (%d)", from, to);
}



#pragma mark privateMethods

//直属子类
-(NSArray *)directSubTypesArrayFor:(TypeDataObj *)obj
{
    NSArray * totalSub = [self totalSubTypesArrayFor:obj];
    if ([totalSub count]>0)
    {
        id obj = [totalSub objectAtIndex:0];
        NSArray * brothers = [self brotherTypesFor:obj];
        
        NSMutableArray * array = [NSMutableArray array];
        [array addObject:obj];
        [array addObjectsFromArray:brothers];
        
        return array;
    }
    
    return nil;
}

//全部子类，包括子类的子类
-(NSArray *)totalSubTypesArrayFor:(TypeDataObj *)obj
{
    if (!self.totalArr)
    {
        NSArray * array =[TypeDataObj totalSubTypesArrayFromArr:sourceArr];
        [self.totalArr removeAllObjects];
        [self.totalArr addObjectsFromArray:array];
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
        [self.totalArr removeAllObjects];
        [self.totalArr addObjectsFromArray:array];
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
//数据在全部数据中的位置
-(int)indexAtTotalArrayWithTypeDataObj:(TypeDataObj *)obj
{
    if (!self.totalArr)
    {
        NSArray * array =[TypeDataObj totalSubTypesArrayFromArr:sourceArr];
        [self.totalArr removeAllObjects];
        [self.totalArr addObjectsFromArray:array];
    }
    double typeId = obj.typeId;

    for (int i = 0;i<[self.totalArr count];i++ )
    {
        TypeDataObj * newObj = [totalArr objectAtIndex:i];
        double newId = newObj.typeId;
        if (typeId == newId)
        {
            return i;
        }

    }
    return -1;
}
-(void)backInputKeyBoard:(id)sender
{
    if (lastCell)
    {
        [lastCell endTfdEditName];
        lastCell = nil;
    }
}
-(void)stopTypeNameEdit
{
    [self backInputKeyBoard:nil];
}
-(NSArray *)endEditTypeWithNowTypeData
{
    
    return totalArr;
}


//将totalArr里面的数据压缩处理
//当前数据,压缩处理
-(NSArray *)endTypeEditWithNowType
{
    //统计当前数据，返回结果，并存储数据库
    NSArray * array  = [TypeDataObj totalRootTypeObjsArrFromTotalDataArray:totalArr];
    return array;
}


//父类型数据，没有子类数组
-(id)superTypeDataForTypeData:(TypeDataObj *)obj
{
    if (obj.typeLeavel==0)
    {
        return nil;
    }
    if (!self.totalArr)
    {
        NSArray * array =[TypeDataObj totalSubTypesArrayFromArr:sourceArr];
        [self.totalArr removeAllObjects];
        [self.totalArr addObjectsFromArray:array];
    }
    
    NSMutableArray * array = [NSMutableArray array];
    int leavel = obj.typeLeavel;
    for (TypeDataObj * eveObj in  totalArr)
    {
        int newLeavel = eveObj.typeLeavel;
        if (newLeavel<=leavel)
        {
            [array addObject:eveObj];
        }
    }
    int index = [array indexOfObject:obj];
    
    leavel--;
    for (int i=index;i>=0;i--)
    {
        TypeDataObj * newObj =[array objectAtIndex:i];
        if (newObj.typeLeavel==leavel)
        {
            return newObj;
            break;
        }
    }
    return nil;
}





- (void)dealloc
{
    self.sourceArray = nil;

    [chooseArr release];
    [showArr release];
    [super dealloc];
}
@end
