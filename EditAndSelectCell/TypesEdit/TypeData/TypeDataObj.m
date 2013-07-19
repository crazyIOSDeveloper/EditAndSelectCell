//
//  TypeDataObj.m
//  EditAndSelectCell
//
//  Created by zhangchaoqun on 13-7-14.
//  Copyright (c) 2013年 zhangchaoqun. All rights reserved.
//

#import "TypeDataObj.h"

@implementation TypeDataObj
@synthesize typeName;
@synthesize typeId;
@synthesize subTypes;
@synthesize typeLeavel;
@synthesize containNext;
//drop table "tablename"


-(NSString *)description
{
    return [NSString stringWithFormat:@"[%d]%@[%f]",typeLeavel,typeName,typeId];
}
-(id)initWithTypeName:(NSString *)name
{
    self = [super init];
    if (self)
    {
        self.typeLeavel = 0;
        self.containNext = NO;
        self.typeName = name;
        self.typeId = [NSDate timeIntervalSinceReferenceDate];
    }
    return self;
}
+(TypeDataObj *)typeDataObjWithTypeName:(NSString *)name
{
    TypeDataObj * obj = [[TypeDataObj alloc] initWithTypeName:name];
    return [obj autorelease];
}
- (id)copyWithZone:(NSZone *)zone
{
    TypeDataObj *obj = [[[self class] allocWithZone:zone] init];
    obj.typeId = [NSDate timeIntervalSinceReferenceDate];
    obj.subTypes = nil;
    obj.typeName = [self.typeName copy];
    obj.typeLeavel = self.typeLeavel;
    obj.containNext = NO;
    return [obj autorelease];
}
//示例类
+(TypeDataObj *)normalTypeObj
{
    NSArray * ageArr = [NSArray arrayWithObjects:@"男人",@"女人",@"儿童",@"老年人", nil];
    NSMutableArray * array = [NSMutableArray array];
    TypeDataObj * obj = nil;
    for (NSString * age in ageArr)
    {
        obj = [TypeDataObj typeDataObjWithTypeName:age];
        [array addObject:obj];
    }
    
    TypeDataObj * ageObj = [TypeDataObj typeDataObjWithTypeName:@"年龄"];
    ageObj.subTypes = array;
    
    
    
    array = [NSMutableArray array];
    NSArray * colorArr = [NSArray arrayWithObjects:@"红色",@"黑色",@"白色",@"黑白色",@"深蓝色", nil];
    for (NSString * name in colorArr)
    {
        obj = [TypeDataObj typeDataObjWithTypeName:name];
        [array addObject:obj];
    }
    
    
    TypeDataObj * colorObj = [TypeDataObj typeDataObjWithTypeName:@"颜色"];
    colorObj.subTypes = array;
    
    
    obj = [TypeDataObj typeDataObjWithTypeName:@"精品推荐"];
    obj.subTypes = [NSArray arrayWithObjects:ageObj,colorObj, nil];
    
    return obj;
    
}
+(TypeDataObj *)normalTypeObj_another
{
    NSArray * ageArr = [NSArray arrayWithObjects:@"男人",@"女人",@"儿童",@"老年人", nil];
    NSMutableArray * array = [NSMutableArray array];
    TypeDataObj * obj = nil;
    for (NSString * age in ageArr)
    {
        obj = [TypeDataObj typeDataObjWithTypeName:age];
        [array addObject:obj];
    }
    
    TypeDataObj * ageObj = [TypeDataObj typeDataObjWithTypeName:@"年龄"];
    ageObj.subTypes = array;
    
    
    
    array = [NSMutableArray array];
    NSArray * colorArr = [NSArray arrayWithObjects:@"红色",@"黑色",@"白色",@"黑白色",@"深蓝色", nil];
    for (NSString * name in colorArr)
    {
        obj = [TypeDataObj typeDataObjWithTypeName:name];
        [array addObject:obj];
    }
    
    
    TypeDataObj * colorObj = [TypeDataObj typeDataObjWithTypeName:@"颜色"];
    colorObj.subTypes = array;
    
    
    obj = [TypeDataObj typeDataObjWithTypeName:@"精品推荐"];
    obj.subTypes = [NSArray arrayWithObjects:ageObj,colorObj, nil];
    
    return obj;

}


+(NSArray *)showArrayFromSource:(NSArray *)source
{
    NSMutableArray * array = [NSMutableArray array];
    for (TypeDataObj * obj in source)
    {
        TypeDataObj * new = [obj copy];
        [array addObject:new];
    }
    
    return array;
}


//某一对象的所有子类的数组
-(NSArray *)totalSubTypesArray
{
    NSMutableArray * array = [NSMutableArray array];
    TypeDataObj * first = [self copy];
    [array addObject:first];
    
    if ([self.subTypes count]!=0)
    {
        first.containNext = YES;
        for (TypeDataObj * obj in self.subTypes)
        {
            obj.typeLeavel = first.typeLeavel+1;
            NSArray * subArr = [obj totalSubTypesArray];
            [array addObjectsFromArray:subArr];
        }
    }else
    {
        first.containNext = NO;
    }
    
//    for (TypeDataObj * obj in self.subTypes)
//    {
//        TypeDataObj * new = [obj copy];
//        new.typeLeavel = self.typeLeavel+1;
//
//        NSArray * subArray = [obj totalSubTypesArray];
//        //有下级目录
//        if (subArray&&[subArray count]!=0)
//        {
//            new.containNext = YES;
//        }
//        [array addObject:new];
//        [array addObjectsFromArray:subArray];
//    }
    
    return array;
}


//对数组取所有值
+(NSArray *)totalSubTypesArrayFromArr:(NSArray *)data
{
    NSMutableArray * array = [NSMutableArray array];
    for (TypeDataObj *obj in data)
    {
        TypeDataObj * new = [obj copy];
        
        NSArray * subArray = [obj totalSubTypesArray];
        //有下级目录
        if (subArray&&[subArray count]!=0)
        {
            new.containNext = YES;
        }
        
        [array addObject:new];
        [array addObjectsFromArray:subArray];
    }
    
    return array;
}

+(void)showNamesFromArr:(NSArray *)array
{
    NSMutableString * str = [NSMutableString string];
    for (int i=0;i<[array count] ;i++ )
    {
        TypeDataObj * obj = [array objectAtIndex:i];
        [str appendFormat:@"%@,",obj.typeName];
    }
    NSLog(@"showNamesFromArr %@",str);
}





//方便转换为json串//方便数据存储
-(NSDictionary *)jsonDic
{
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    NSMutableArray * array = [NSMutableArray array];
    for (TypeDataObj * obj in self.subTypes)
    {
        [array addObject:[obj jsonDic]];
    }
    
    if (array&&[array count]!=0)
    {
        [dic setValue:array forKey:@"subTypes"];
    }
    if (self.typeName)
    {
        [dic setValue:self.typeName forKey:@"typeName"];
    }
    if (self.typeId)
    {
        [dic setValue:[NSString stringWithFormat:@"%f",self.typeId] forKey:@"typeId"];
    }
    
    [dic setValue:[NSString stringWithFormat:@"%d",self.typeLeavel] forKey:@"typeLeavel"];

    
    [dic setValue:@"0" forKey:@"containNext"];
    if (self.containNext)
    {
        [dic setValue:@"1" forKey:@"containNext"];
    }
    
    return dic;
}

//返回总体数据
+(TypeDataObj *)totalTypeDataFromJSONDic:(NSDictionary *)dic
{
    NSString * typeName = [dic valueForKey:@"typeName"];
    NSString * typeId = [dic valueForKey:@"typeId"];
    NSString * typeLeavel = [dic valueForKey:@"typeLeavel"];
    NSString * contentNext = [dic valueForKey:@"containNext"];
    
    TypeDataObj * obj = [[TypeDataObj alloc] initWithTypeName:typeName];
    obj.typeId =[typeId doubleValue];
    obj.typeLeavel = [typeLeavel intValue];
    obj.containNext = NO;
    if ([contentNext isEqualToString:@"1"])
    {
        obj.containNext =YES;
    }
    
    NSMutableArray * array = [NSMutableArray array];
//    [array addObject:obj];
    
    NSArray * subTypes = [dic valueForKey:@"subTypes"];
    for (NSDictionary * newDic in subTypes)
    {
        TypeDataObj * newObj =[TypeDataObj totalTypeDataFromJSONDic:newDic];
        [array addObject:newObj];
    }
    obj.subTypes = array;
    
    return obj;
}

+(TypeDataObj *)totalSuperDataObjFromArray:(NSArray *)dataArr
{
    TypeDataObj * obj = nil;
    if ([dataArr count]>0)
    {
        obj = [dataArr objectAtIndex:0];
    }
    int leavel = obj.typeLeavel;
    leavel++;
    
    NSMutableArray * indexNum = [NSMutableArray array];
    for (int i=0;i<[dataArr count];i++)
    {
        TypeDataObj * newObj = [dataArr objectAtIndex:i];
        if (newObj.typeLeavel==leavel)
        {
            NSNumber * number = [NSNumber numberWithInt:i];
            [indexNum addObject:number];
        }
    }
    
    
    NSMutableArray * subTypes =[NSMutableArray array];
    for (int i=0;i<[indexNum count];i++ )
    {
        NSNumber * start = [indexNum objectAtIndex:i];
        int length = [dataArr count]-[start intValue];
        if ([indexNum count]!=i+1)
        {
            NSNumber * end = [indexNum objectAtIndex:i+1];
            length = [end intValue]-[start intValue];
        }
        NSRange range = NSMakeRange([start intValue], length);
        NSArray * subArr = [dataArr subarrayWithRange:range];
        if ([obj containNext])
        {
            TypeDataObj * newObj = [self totalSuperDataObjFromArray:subArr];
            [subTypes addObject:newObj];
        }
    }
    
    obj.subTypes = subTypes;
    return obj;
}

//根据全部列表数据，返回标示位为0的对象数组
+(NSArray *)totalRootTypeObjsArrFromTotalDataArray:(NSArray *)dataArr;
{
    int startIndex = 0;
    int endIndex = 0;
    
    BOOL haveStart = NO;
    NSMutableArray * array = [NSMutableArray array];
    for (int i=0;i<[dataArr count];i++)
    {
        TypeDataObj * eveObj = [dataArr objectAtIndex:i];
        if (eveObj.typeLeavel==0)
        {
            if (haveStart)
            {
                endIndex = i;
                
                NSRange range =NSMakeRange(startIndex,endIndex-startIndex);
                NSArray * subArr = [dataArr subarrayWithRange:range];
                TypeDataObj * obj = [TypeDataObj totalSuperDataObjFromArray:subArr];
                [array addObject:obj];
                //进行操作
                
                startIndex = endIndex;
                
            }else
            {
                startIndex = i;
                haveStart = YES;
            }
        }
    }
    
    if (haveStart)
    {
        endIndex = [dataArr count];
        //表示只有1个0节点
        NSRange range =NSMakeRange(startIndex,endIndex-startIndex);
        NSArray * subArr = [dataArr subarrayWithRange:range];
        TypeDataObj * obj = [TypeDataObj totalSuperDataObjFromArray:subArr];
        [array addObject:obj];
    }
    
    
    return array;
}



@end
