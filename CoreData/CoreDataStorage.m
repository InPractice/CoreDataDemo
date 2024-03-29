#import "CoreDataStorage.h"
#import <objc/runtime.h>
#import <libkern/OSAtomic.h>

#if OS_OBJECT_USE_OBJC_RETAIN_RELEASE
#define maybe_bridge(x) ((__bridge void *) x)
#else
#define maybe_bridge(x) (x)
#endif

@implementation CoreDataStorage

static NSMutableSet *databaseFileNames;

+ (void)initialize
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		databaseFileNames = [[NSMutableSet alloc] init];
	});
}

+ (BOOL)registerDatabaseFileName:(NSString *)dbFileName
{
	BOOL result = NO;
	
	@synchronized(databaseFileNames)
	{
		if (![databaseFileNames containsObject:dbFileName])
		{
			[databaseFileNames addObject:dbFileName];
			result = YES;
		}
	}
	
	return result;
}

+ (void)unregisterDatabaseFileName:(NSString *)dbFileName
{
	@synchronized(databaseFileNames)
	{
		[databaseFileNames removeObject:dbFileName];
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Override Me
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSString *)managedObjectModelName
{
	// Override me, if needed, to provide customized behavior.
	// 
	// This method is queried to get the name of the ManagedObjectModel within the app bundle.
	// It should return the name of the appropriate file (*.xdatamodel / *.mom / *.momd) sans file extension.
	// 
	// The default implementation returns the name of the subclass, stripping any suffix of "CoreDataStorage".
	// E.g., if your subclass was named "ExtensionCoreDataStorage", then this method would return "Extension".
	// 
	// Note that a file extension should NOT be included.
	
	NSString *className = NSStringFromClass([self class]);
	NSString *suffix = @"CoreDataStorage";
	
	if ([className hasSuffix:suffix] && ([className length] > [suffix length]))
	{
		return [className substringToIndex:([className length] - [suffix length])];
	}
	else
	{
		return className;
	}
}

- (NSString *)defaultDatabaseFileName
{
	// Override me, if needed, to provide customized behavior.
	// 
	// This method is queried if the initWithDatabaseFileName method is invoked with a nil parameter.
	// 
	// You are encouraged to use the sqlite file extension.
	
//    NSLog(@"打开:%@",[NSString stringWithFormat:@"%@.sqlite", [self managedObjectModelName]]);
	return [NSString stringWithFormat:@"%@.sqlite", [self managedObjectModelName]];
}

- (void)willCreatePersistentStoreWithPath:(NSString *)storePath
{
	// Override me, if needed, to provide customized behavior.
	// 
	// If you are using a database file with non-persistent data (e.g. for memory optimization purposes on iOS),
	// you may want to delete the database file if it already exists on disk.
	// 
	// If this instance was created via initWithDatabaseFilename, then the storePath parameter will be non-nil.
	// If this instance was created via initWithInMemoryStore, then the storePath parameter will be nil.
}

- (BOOL)addPersistentStoreWithPath:(NSString *)storePath error:(NSError **)errorPtr
{
	// Override me, if needed, to completely customize the persistent store.
	// 
	// Adds the persistent store path to the persistent store coordinator.
	// Returns true if the persistent store is created.
	// 
	// If this instance was created via initWithDatabaseFilename, then the storePath parameter will be non-nil.
	// If this instance was created via initWithInMemoryStore, then the storePath parameter will be nil.
			
    NSPersistentStore *persistentStore;
	
	if (storePath)
	{
		// SQLite persistent store
		
		NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
		
		// Default support for automatic lightweight migrations
		NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
		                         [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
		                         [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, 
		                         nil];
		
		persistentStore = [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
		                                                           configuration:nil
		                                                                     URL:storeUrl
		                                                                 options:options
		                                                                   error:errorPtr];
	}
	else
	{
		// In-Memory persistent store
		
		persistentStore = [persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType
		                                                           configuration:nil
		                                                                     URL:nil
		                                                                 options:nil
		                                                                   error:errorPtr];
	}
	
    return persistentStore != nil;
}

- (void)didNotAddPersistentStoreWithPath:(NSString *)storePath error:(NSError *)error
{
  
}

- (void)didCreateManagedObjectContext
{
	// Override me to provide customized behavior.
	// 
	// For example, you may want to perform cleanup of any non-persistent data before you start using the database.
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Setup
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@synthesize databaseFileName;

- (void)commonInit
{
	saveThreshold = 500;
	storageQueue = dispatch_queue_create(class_getName([self class]), NULL);
	dispatch_queue_set_specific(storageQueue, (__bridge void *)self, maybe_bridge(storageQueue), NULL);
	
}

- (id)init
{
    return [self initWithDatabaseFilename:nil];
}

- (id)initWithDatabaseFilename:(NSString *)aDatabaseFileName
{
	if ((self = [super init]))
	{
		if (aDatabaseFileName)
			databaseFileName = [aDatabaseFileName copy];
		else
			databaseFileName = [[self defaultDatabaseFileName] copy];
		
//		if (![[self class] registerDatabaseFileName:databaseFileName])
//		{
//			[self dealloc];
//			return nil;
//		}
		
		[self commonInit];
	}
	return self;
}

- (id)initWithInMemoryStore
{
	if ((self = [super init]))
	{
		
		
		[self commonInit];
	}
	return self;
}

- (BOOL)configureWithParent:(id)aParent queue:(dispatch_queue_t)queue
{
	// This is the standard configure method used by xmpp extensions to configure a storage class.
	// 
	// Feel free to override this method if needed,
	// and just invoke super at some point to make sure everything is kosher at this level as well.
	
	NSParameterAssert(aParent != nil);
	NSParameterAssert(queue != NULL);
	
	if (queue == storageQueue)
	{
		// This class is designed to be run on a separate dispatch queue from its parent.
		// This allows us to optimize the database save operations by buffering them,
		// and executing them when demand on the storage instance is low.
		
		return NO;
	}
	
	return YES;
}

- (NSUInteger)saveThreshold
{
	if (dispatch_get_specific((__bridge void *)self) == maybe_bridge(storageQueue))
	{
		return saveThreshold;
	}
	else
	{
		__block NSUInteger result;
		
		dispatch_sync(storageQueue, ^{
			result = saveThreshold;
		});
		
		return result;
	}
}

- (void)setSaveThreshold:(NSUInteger)newSaveThreshold
{
	dispatch_block_t block = ^{
		saveThreshold = newSaveThreshold;
	};
	
	if (dispatch_get_specific((__bridge void *)self) == maybe_bridge(storageQueue))
		block();
	else
		dispatch_async(storageQueue, block);
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Core Data Setup
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSString *)persistentStoreDirectory
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
	
	// Attempt to find a name for this application
//	NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
//	if (appName == nil) {
//		appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];	
//	}
//	
//	if (appName == nil) {
//		appName = @"SouFun";
//	}
	
	
//	NSString *result = [basePath stringByAppendingPathComponent:appName];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if (![fileManager fileExistsAtPath:basePath])
	{
		[fileManager createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:nil];
	}
	
    return basePath;
}

- (NSManagedObjectModel *)managedObjectModel
{
	// This is a public method.
	// It may be invoked on any thread/queue.
	
	dispatch_block_t block = ^{
		
		if (managedObjectModel)
		{
			return;
		}
		
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
        
		NSString *momName = [self managedObjectModelName];
        NSString *className = NSStringFromClass([self class]);
        if ([className isEqualToString:@"JTTAppLogicCoreDataStorage11"]) {
            NSString * version = [NSString stringWithString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
            momName = [momName stringByAppendingString:version];
            NSString *momPath = [[NSBundle mainBundle] pathForResource:momName ofType:@"mom" inDirectory:@"JTTAppLogic.momd"];
//            NSLog(@"momPath =%@",momPath);
		    if (momPath == nil)
		    {
                // The model may be versioned or created with Xcode 4, try momd as an extension.
                momPath = [[NSBundle mainBundle] pathForResource:momName ofType:@"momd" inDirectory:@"JTTAppLogic.momd"];
		    }
            
		    if (momPath)
		    {
                // If path is nil, then NSURL or NSManagedObjectModel will throw an exception
                
                NSURL *momUrl = [NSURL fileURLWithPath:momPath];
                
                managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momUrl];
		    }
		    else
		    {
                
            }
            
        }
		else
        {
            NSString *momPath = [[NSBundle mainBundle] pathForResource:momName ofType:@"mom"];
		    if (momPath == nil)
		    {
                // The model may be versioned or created with Xcode 4, try momd as an extension.
                momPath = [[NSBundle mainBundle] pathForResource:momName ofType:@"momd"];
		    }
            
		    if (momPath)
		    {
                // If path is nil, then NSURL or NSManagedObjectModel will throw an exception
                
                NSURL *momUrl = [NSURL fileURLWithPath:momPath];
                
                managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momUrl];
		    }
		    else
		    {
                
            }
		}
		
		[pool drain];
	};
	
	if (dispatch_get_specific((__bridge void *)self) == maybe_bridge(storageQueue))
		block();
	else
		dispatch_sync(storageQueue, block);
	
	return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
	// This is a public method.
	// It may be invoked on any thread/queue.
	
	dispatch_block_t block = ^{
		
		if (persistentStoreCoordinator)
		{
			return;
		}
		
		NSManagedObjectModel *mom = [self managedObjectModel];
		if (mom == nil)
		{
			return;
		}
		
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
			
		persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
		
		if (databaseFileName)
		{
			// SQLite persistent store
			
			NSString *docsPath = [self persistentStoreDirectory];
			NSString *storePath = [docsPath stringByAppendingPathComponent:databaseFileName];
			if (storePath)
			{
				// If storePath is nil, then NSURL will throw an exception
				
				[self willCreatePersistentStoreWithPath:storePath];
				
				NSError *error = nil;
				if (![self addPersistentStoreWithPath:storePath error:&error])
				{
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
					[self didNotAddPersistentStoreWithPath:storePath error:error];
				}
			}
			else
			{
				
			}
		}
		else
		{
			// In-Memory persistent store
			
			[self willCreatePersistentStoreWithPath:nil];
			
			NSError *error = nil;
			if (![self addPersistentStoreWithPath:nil error:&error])
			{
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
				[self didNotAddPersistentStoreWithPath:nil error:error];
			}
		}
		
		[pool drain];
	};
	
	if (dispatch_get_specific((__bridge void *)self) == maybe_bridge(storageQueue))
		block();
	else
		dispatch_sync(storageQueue, block);

    return persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext
{
	// This is a private method.
	// 
	// NSManagedObjectContext is NOT thread-safe.
	// Therefore it is VERY VERY BAD to use our private managedObjectContext outside our private storageQueue.
	// 
	// You should NOT remove the assert statement below!
	// You should NOT give external classes access to the storageQueue! (Excluding subclasses obviously.)
	// 
	// When you want a managedObjectContext of your own (again, excluding subclasses),
	// you should create your own using the public persistentStoreCoordinator.
	// 
	// If you even comtemplate ignoring this warning,
	// then you need to go read the documentation for core data,
	// specifically the section entitled "Concurrency with Core Data".
	// 
	NSAssert(dispatch_get_specific((__bridge void *)self) == maybe_bridge(storageQueue), @"Invoked on incorrect queue");
	// 
	// Do NOT remove the assert statment above!
	// Read the comments above!
	// 
	
	if (managedObjectContext)
	{
		return managedObjectContext;
	}
	
	NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	if (coordinator)
	{
		managedObjectContext = [[NSManagedObjectContext alloc] init];
//        id delegate = [[UIApplication sharedApplication] delegate];
//        self.managedObjectContext = [delegate managedObjectContext];
		[managedObjectContext setPersistentStoreCoordinator:coordinator];
		
		[self didCreateManagedObjectContext];
	}
	
	return managedObjectContext;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Utilities
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSUInteger)numberOfUnsavedChanges
{
	NSManagedObjectContext *moc = [self managedObjectContext];
	
	NSUInteger unsavedCount = 0;
	unsavedCount += [[moc updatedObjects] count];
	unsavedCount += [[moc insertedObjects] count];
	unsavedCount += [[moc deletedObjects] count];
	
	return unsavedCount;
}

- (void)save
{
	// I'm fairly confident that the implementation of [NSManagedObjectContext save:]
	// internally checks to see if it has anything to save before it actually does anthing.
	// So there's no need for us to do it here, especially since this method is usually
	// called from maybeSave below, which already does this check.
	
	NSError *error = nil;
	if (![[self managedObjectContext] save:&error])
	{
		
		
		[[self managedObjectContext] rollback];
	}
}

- (void)maybeSave:(int32_t)currentPendingRequests
{
	NSAssert(dispatch_get_specific((__bridge void *)self) == maybe_bridge(storageQueue), @"Invoked on incorrect queue");
	
	
	if ([[self managedObjectContext] hasChanges])
	{
		if (currentPendingRequests == 0)
		{
			[self save];
		}
		else
		{
			NSUInteger unsavedCount = [self numberOfUnsavedChanges];
			if (unsavedCount >= saveThreshold)
			{
				
				
				[self save];
			}
		}
	}
}

- (void)maybeSave
{
	// Convenience method in the very rare case that a subclass would need to invoke maybeSave manually.
	
	[self maybeSave:OSAtomicAdd32(0, &pendingRequests)];
}

- (void)executeBlock:(dispatch_block_t)block
{
	// By design this method should not be invoked from the storageQueue.
	// 
	// If you remove the assert statement below, you are destroying the sole purpose for this class,
	// which is to optimize the disk IO by buffering save operations.
	// 
	NSAssert(dispatch_get_specific((__bridge void *)self) != maybe_bridge(storageQueue), @"Invoked on incorrect queue");
	// 
	// For a full discussion of this method, please see XMPPCoreDataStorageProtocol.h
	//
	// dispatch_Sync
	//          ^
	
	OSAtomicIncrement32(&pendingRequests);
	dispatch_sync(storageQueue, ^{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		block();
		
		// Since this is a synchronous request, we want to return as quickly as possible.
		// So we delay the maybeSave operation til later.
		
		dispatch_async(storageQueue, ^{
			NSAutoreleasePool *innerPool = [[NSAutoreleasePool alloc] init];
			
			[self maybeSave:OSAtomicDecrement32(&pendingRequests)];
			
			[innerPool drain];
		});
		
		[pool drain];
	});
}

- (void)scheduleBlock:(dispatch_block_t)block
{
	// By design this method should not be invoked from the storageQueue.
	// 
	// If you remove the assert statement below, you are destroying the sole purpose for this class,
	// which is to optimize the disk IO by buffering save operations.
	// 
	NSAssert(dispatch_get_specific((__bridge void *)self) != maybe_bridge(storageQueue), @"Invoked on incorrect queue");
	// 
	// For a full discussion of this method, please see XMPPCoreDataStorageProtocol.h
	// 
	// dispatch_Async
	//          ^
	
	OSAtomicIncrement32(&pendingRequests);
	dispatch_async(storageQueue, ^{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		block();
		
		[self maybeSave:OSAtomicDecrement32(&pendingRequests)];
		[pool drain];
	});
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Memory Management
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	if (databaseFileName)
	{
		[[self class] unregisterDatabaseFileName:databaseFileName];
		[databaseFileName release];
	}
	
	
	if (storageQueue)
	{
		dispatch_release(storageQueue);
	}
	
	[managedObjectContext release];
	[persistentStoreCoordinator release];
	[managedObjectModel release];
	
	[super dealloc];
}

@end
