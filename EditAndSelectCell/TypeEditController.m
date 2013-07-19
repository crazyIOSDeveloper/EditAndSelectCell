//
//  TypeEditController.m
//  EditAndSelectCell
//
//  Created by zhangchaoqun on 13-7-14.
//  Copyright (c) 2013年 zhangchaoqun. All rights reserved.
//

#import "TypeEditController.h"
#import "TypeEditingCell.h"
#import "TypeSelectCell.h"
#import "TypeDataObj.h"
@interface TypeEditController ()

@end

@implementation TypeEditController
@synthesize dataArr;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)tableViewEdit:(id)sender{
    
#ifdef TotalAPPend
    UIButton * btn = (UIButton *)sender;
#else
    UIBarButtonItem * item = (UIBarButtonItem *)sender;
    
#endif
    [_tableView setEditing:!_tableView.editing animated:YES];
    
    
    BOOL editing =_tableView.editing;
    
    if (editing)
    {
#ifdef TotalAPPend
        [btn setTitle:@"保存" forState:UIControlStateNormal];
#else
        item.title = @"保存";
        
#endif
        if (!editDlgObj)
        {
            editDlgObj = [[TypeEditViewDelegate alloc] initWithArray:self.dataArr andDelegate:self];
        }
        NSArray * showArr = [selectDlbObj tableShowDataArr];
        [editDlgObj startWithShowArray:showArr];
        
        _tableView.dataSource = editDlgObj;
        _tableView.delegate = editDlgObj;
        
        NSIndexSet * set = [NSIndexSet indexSetWithIndex:1];
        [_tableView reloadSections:set withRowAnimation:UITableViewRowAnimationFade];
        
        NSArray * array = [_tableView indexPathsForVisibleRows];
        [_tableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationFade];
        [_tableView reloadData];
        
        [selectDlbObj release];
        selectDlbObj = nil;
        
    }else
    {
#ifdef TotalAPPend
        [btn setTitle:@"编辑" forState:UIControlStateNormal];
#else
        item.title = @"编辑";
        
#endif
        [editDlgObj stopTypeNameEdit];
        
        NSArray * total = [editDlgObj endEditTypeWithNowTypeData];
        [self.dataArr removeAllObjects];
        [self.dataArr addObjectsFromArray:total];
        
        
        [self saveNowSortTypesArray:nil];
        
        if (!selectDlbObj)
        {
            selectDlbObj = [[TypeSelectViewDelegate alloc] initWithArray:self.dataArr andDelegate:self];
        }
        NSArray * showArr = [editDlgObj tableShowDataArr];
        [selectDlbObj startWithShowArray:showArr];
        
        _tableView.dataSource = selectDlbObj;
        _tableView.delegate = selectDlbObj;
        
        NSIndexSet * set = [NSIndexSet indexSetWithIndex:1];
        [_tableView reloadSections:set withRowAnimation:UITableViewRowAnimationFade];
        
        
        NSArray * array = [_tableView indexPathsForVisibleRows];
        [_tableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationFade];
        [_tableView reloadData];
        
        
        [editDlgObj release];
        editDlgObj = nil;
    }
}

-(void)saveNowSortTypesArray:(id)sender
{
#ifdef TotalAPPend
    //数据库处理
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        
        LocalDBDataManager * manager = [LocalDBDataManager defaultManager];
        [manager selectObjects:[UserSortsObject class] where:nil];
        NSArray * totalArray = self.dataArr;
        [TypeDataObj showNamesFromArr:totalArray];
        
        
        //此数据 仅有子类型数组，没有名称        //全部数据，根数据结构
        NSArray * objArr = [TypeDataObj totalRootTypeObjsArrFromTotalDataArray:totalArray];
        NSMutableArray * jsonArr = [NSMutableArray array];
        for (TypeDataObj * obj in objArr )
        {
            NSDictionary * jsonDic = [obj jsonDic];
            [jsonArr addObject:jsonDic];
        }
        NSString * jsonStr = [jsonArr JSONString];
        NSLog(@"存储json %@",jsonStr);
        
        UserSortsObject * sort = [[UserSortsObject alloc] init];
        sort.sortsShopId_ = [NSString stringWithFormat:@"%@",[[NSDate date] description]];
        sort.lastDate_= [[NSDate date] description];
        sort.sortsStruct_ = jsonStr;
        sort.personIdStr_ = @"未登录";
        
        LoginController * login = [LoginController sharedLoginController];
        NSString * idStr = login.loginTel;
        if (idStr)
        {
            sort.personIdStr_ = idStr;
        }
        
        [manager insertObject:sort];
    });
#endif
    
    
}

-(void)readLocalSortTypes:(id)sender
{
#ifdef TotalAPPend
    LocalDBDataManager * manager = [LocalDBDataManager defaultManager];
    NSArray * array = [manager selectObjects:[UserSortsObject class] where:nil];
    
    UserSortsObject * sortData = [array lastObject];
    NSString * structStr = sortData.sortsStruct_;
    
    NSLog(@"使用json %@",structStr);
    NSArray * objJsonArr = [structStr objectFromJSONString];
    NSMutableArray * totalArr = [NSMutableArray array];
    for (NSDictionary * dic in objJsonArr)
    {
        TypeDataObj * eveObj = [TypeDataObj totalTypeDataFromJSONDic:dic];
        NSArray * subTotal = [eveObj totalSubTypesArray];
        [totalArr addObjectsFromArray:subTotal];
    }
    
    
    if (!totalArr||[totalArr count]==0)
    {
        return ;
    }
    self.dataArr = [NSMutableArray arrayWithArray:totalArr];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [editDlgObj setSourceArray:totalArr];
        [selectDlbObj setSourceArray:totalArr];
        
        [_tableView reloadData];
    });
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
    });
#endif
    
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    TypeDataObj * typeData = [TypeDataObj normalTypeObj];
    NSArray * array = [typeData totalSubTypesArray];
    
    //首次初始化数据，应该由数据库读取
    self.dataArr = [NSMutableArray arrayWithArray:array];
    
    selectDlbObj = [[TypeSelectViewDelegate alloc] initWithArray:array andDelegate:self];
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    rect.size.height = rect.size.height*3/4;
    _tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    
    
    [self.view addSubview:_tableView];
    _tableView.delegate = selectDlbObj;
    _tableView.dataSource = selectDlbObj;
    _tableView.allowsSelectionDuringEditing = YES;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStyleDone target:self action:@selector(tableViewEdit:)];
}
#pragma mark TypeSelectDelegate
-(void)endSelectWithChooseTypeArray:(NSArray *)array
{
    NSLog(@"endSelectWithChooseTypeArray %@ ",array);
}
-(UITableView *)tableViewForTypeSelectDelegate
{
    return _tableView;
}
#pragma mark TypeEditDelegate
-(UITableView *)tableViewForTypeEditDelegate
{
    return _tableView;
}

#pragma mark -UITableViewDelegate--


#pragma mark -------------------------

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
