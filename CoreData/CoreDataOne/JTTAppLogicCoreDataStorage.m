//
//  JTTAppLogicCoreDataStorage.m
//  CoreDataOne
//
//  Created by zhulin on 14-3-26.
//  Copyright (c) 2014年 Julius. All rights reserved.
//

#import "JTTAppLogicCoreDataStorage.h"
#import "CoreDataStorageProtected.h"

#import "Student.h"
#import "Teacher.h"


@implementation JTTAppLogicCoreDataStorage

static JTTAppLogicCoreDataStorage *sharedInstance;

+ (JTTAppLogicCoreDataStorage *)sharedInstance
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[JTTAppLogicCoreDataStorage alloc] initWithDatabaseFilename:nil];
	});
	
	return sharedInstance;
}

- (id)init
{
	return [self initWithDatabaseFilename:nil];
}

- (id)initWithDatabaseFilename:(NSString *)aDatabaseFileName
{
	if ((self = [super initWithDatabaseFilename:aDatabaseFileName]))
	{
		
	}
	return self;
}
//增删改查
#pragma mark - Student相关操作
-(void)insertStudentItem:(NSMutableDictionary *)LoginItem
{
    
    [self scheduleBlock:^{
		
		NSManagedObjectContext *moc = [self managedObjectContext];
		
        [Student insertLoginItem:LoginItem inManagedObjectContext:moc];
    }];
}


-(void)removeStudentItem:(NSString *)name
{
    [self scheduleBlock:^{
		
		NSManagedObjectContext *moc = [self managedObjectContext];
		
        [Student removeLoginItem:name inManagedObjectContext:moc];
    }];
}

- (void)updateStudentInfo:(NSMutableDictionary *)dict
{
    [self scheduleBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        [Student updateUserInfo:dict inManagedObjectContext:moc];
    }];
}

- (void)readStudentInfoFromDataBase
{
    [self executeBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        [Student  readUserInfoInManagedObjectContext:moc];
    }];
}
#pragma mark - Teacher相关操作
-(void)insertTeacherItem:(NSMutableDictionary *)LoginItem
{
    
    [self scheduleBlock:^{
		
		NSManagedObjectContext *moc = [self managedObjectContext];
		
        [Teacher insertLoginItem:LoginItem inManagedObjectContext:moc];
    }];
}


-(void)removeTeacherItem:(NSString *)name
{
    [self scheduleBlock:^{
		
		NSManagedObjectContext *moc = [self managedObjectContext];
		
        [Teacher removeLoginItem:name inManagedObjectContext:moc];
    }];
}

- (void)updateTeacherInfo:(NSMutableDictionary *)dict
{
    [self scheduleBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        [Teacher updateUserInfo:dict inManagedObjectContext:moc];
    }];
}

- (void)readTeacherInfoFromDataBase
{
    [self executeBlock:^{
        NSManagedObjectContext *moc = [self managedObjectContext];
        [Teacher  readUserInfoInManagedObjectContext:moc];
    }];
}
@end
