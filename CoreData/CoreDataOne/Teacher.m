//
//  Teacher.m
//  CoreDataOne
//
//  Created by zhulin on 14-3-26.
//  Copyright (c) 2014年 Julius. All rights reserved.
//

#import "Teacher.h"


@implementation Teacher

@dynamic name;
@dynamic tea_id;

+ (void)updateUserInfo:(NSMutableDictionary *)dict inManagedObjectContext:(NSManagedObjectContext *)moc
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:moc];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setIncludesPendingChanges:YES];
    
    NSArray *results = [moc executeFetchRequest:fetchRequest error:nil];
    if (results.count == 0)
    {
        Teacher *record = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:moc];
        record.name = [dict objectForKey:@"name"];
        record.tea_id = [dict objectForKey:@"stu_id"];
        
    }
    else
    {
        Teacher *record = [results objectAtIndex:0];
        record.name = [dict objectForKey:@"name"];
        record.tea_id = [dict objectForKey:@"stu_id"];
        
    }
}

+ (void)readUserInfoInManagedObjectContext:(NSManagedObjectContext *)moc
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:moc];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setIncludesPendingChanges:YES];
    
    NSArray *results = [moc executeFetchRequest:fetchRequest error:nil];
    if (results.count > 0)
    {
        Teacher *record = [results objectAtIndex:0];
        NSLog(@"name = %@",record.name);
        NSLog(@"tea_id = %@",record.tea_id);
    }
}

+ (void)insertLoginItem:(NSMutableDictionary *)loginItem inManagedObjectContext:(NSManagedObjectContext *)moc
{
    if (loginItem != nil) {
        NSString *stu_id = [loginItem objectForKey:@"stu_id"];
        [self removeLoginItem:stu_id inManagedObjectContext:moc]; // 删除重复的数据
        
        Teacher *login = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class])
                                                       inManagedObjectContext:moc];
        login.name = [loginItem objectForKey:@"tea_id"];
    }
}



+ (void)removeLoginItem:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)moc
{
    if (name) {
        NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([self class])
                                                  inManagedObjectContext:moc];
        NSPredicate *predicate = nil;
        
        predicate = [NSPredicate predicateWithFormat:@"name == %@", name];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setIncludesPendingChanges:YES];
        
        NSArray *results = [moc executeFetchRequest:fetchRequest error:nil];
        fetchRequest = nil;
        for (Teacher *login in results) {
            [moc deleteObject:login];
        }
    }
    
}

@end
