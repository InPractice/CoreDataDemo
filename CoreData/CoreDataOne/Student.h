//
//  Student.h
//  CoreDataOne
//
//  Created by zhulin on 14-3-26.
//  Copyright (c) 2014年 Julius. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Student : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * stu_id;

+ (void)insertLoginItem:(NSMutableDictionary *)loginItem inManagedObjectContext:(NSManagedObjectContext *)moc;

+ (void)removeLoginItem:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)moc;


+ (void)updateUserInfo:(NSMutableDictionary *)dict inManagedObjectContext:(NSManagedObjectContext *)moc;
+ (void)readUserInfoInManagedObjectContext:(NSManagedObjectContext *)moc;

@end
