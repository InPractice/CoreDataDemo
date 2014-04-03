//
//  Student.m
//  CoreDataOne
//
//  Created by zhulin on 14-3-26.
//  Copyright (c) 2014年 Julius. All rights reserved.
//

#import "Student.h"


@implementation Student

@dynamic name;
@dynamic stu_id;

+ (void)updateUserInfo:(NSMutableDictionary *)dict inManagedObjectContext:(NSManagedObjectContext *)moc
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:moc];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setIncludesPendingChanges:YES];
    
    NSArray *results = [moc executeFetchRequest:fetchRequest error:nil];
    if (results.count == 0)
    {
        Student *record = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:moc];
        record.name = [dict objectForKey:@"name"];
        record.stu_id = [dict objectForKey:@"stu_id"];
    
    }
    else
    {
        Student *record = [results objectAtIndex:0];
        record.name = [dict objectForKey:@"name"];
        record.stu_id = [dict objectForKey:@"stu_id"];
    
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
//        Student *record = [results objectAtIndex:0];
//        NSLog(@"name = %@",record.name);
//        NSLog(@"stu_id = %@",record.stu_id);
        for (int i=0; i<results.count; i++) {
            Student *record = [results objectAtIndex:i];
            NSLog(@"name = %@",record.name);
            NSLog(@"stu_id = %@",record.stu_id);
        }
    }
}

+ (void)insertLoginItem:(NSMutableDictionary *)loginItem inManagedObjectContext:(NSManagedObjectContext *)moc
{
    if (loginItem != nil) {
        NSString *stu_id = [loginItem objectForKey:@"stu_id"];
        [self removeLoginItem:stu_id inManagedObjectContext:moc]; // 删除重复的数据
        
        Student *login = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class])
                                                        inManagedObjectContext:moc];
        login.name = [loginItem objectForKey:@"name"];
        login.stu_id = [loginItem objectForKey:@"stu_id"];
    }
}



+ (void)removeLoginItem:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)moc
{
    if (name) {
        NSLog(@"NSStringFromClass([self class]) = %@",NSStringFromClass([self class]));
        NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([self class])
                                                  inManagedObjectContext:moc];
        NSPredicate *predicate = nil;
        
        predicate = [NSPredicate predicateWithFormat:@"stu_id == %@", name];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setIncludesPendingChanges:YES];
        
        NSArray *results = [moc executeFetchRequest:fetchRequest error:nil];
        fetchRequest = nil;
        for (Student *login in results) {
            [moc deleteObject:login];
        }
    }
    
}

@end
