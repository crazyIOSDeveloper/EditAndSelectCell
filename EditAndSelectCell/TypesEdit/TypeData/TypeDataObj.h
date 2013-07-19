//
//  TypeDataObj.h
//  EditAndSelectCell
//
//  Created by zhangchaoqun on 13-7-14.
//  Copyright (c) 2013年 zhangchaoqun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TypeDataObj : NSObject<NSCopying>


//编号
@property (nonatomic,assign) double typeId;
//子类
@property (nonatomic,retain) NSArray * subTypes;
//名字
@property (nonatomic,retain) NSString * typeName;
//父类
@property (nonatomic,assign) int typeLeavel;

//是否有下级目录
@property (nonatomic,assign) BOOL containNext;

-(id)initWithTypeName:(NSString *)name;

+(TypeDataObj *)typeDataObjWithTypeName:(NSString *)name;

//示例类
+(TypeDataObj *)normalTypeObj;

//提供方法，以便产品化
+(NSArray *)showArrayFromSource:(NSArray *)source;

//所有子类的数组，此方法只能对未进行copy的对象使用
-(NSArray *)totalSubTypesArray;

//对数组取所有值
+(NSArray *)totalSubTypesArrayFromArr:(NSArray *)array;

+(void)showNamesFromArr:(NSArray *)array;


//方便转换为json串//方便数据存储
-(NSDictionary *)jsonDic;

//返回总体数据
+(TypeDataObj *)totalTypeDataFromJSONDic:(NSDictionary *)dic;



//根据全部列表数据，返回标示位为0的对象数组
+(NSArray *)totalRootTypeObjsArrFromTotalDataArray:(NSArray *)dataArr;


@end
