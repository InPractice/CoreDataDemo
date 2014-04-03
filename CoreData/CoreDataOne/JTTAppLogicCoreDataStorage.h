//
//  JTTAppLogicCoreDataStorage.h
//  CoreDataOne
//
//  Created by zhulin on 14-3-26.
//  Copyright (c) 2014年 Julius. All rights reserved.
//

#import "CoreDataStorage.h"

@interface JTTAppLogicCoreDataStorage : CoreDataStorage

+ (JTTAppLogicCoreDataStorage *)sharedInstance;

-(void)insertStudentItem:(NSMutableDictionary *)LoginItem;
-(void)removeStudentItem:(NSString *)name;

- (void)updateStudentInfo:(NSMutableDictionary *)dict;
- (void)readStudentInfoFromDataBase;

-(void)insertTeacherItem:(NSMutableDictionary *)LoginItem;
-(void)removeTeacherItem:(NSString *)name;

- (void)updateTeacherInfo:(NSMutableDictionary *)dict;
- (void)readTeacherInfoFromDataBase;


@end
