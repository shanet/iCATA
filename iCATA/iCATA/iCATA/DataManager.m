//
//  DataManager.m
//
// Most of this is the boilerplate code that Apple provides for Core Data.  A
// delegate provides a place for custom behavior: naming the Core Data model and
// the initial creation of the database (NSManaged Objects).  This class also provides
// a convenient method for fetching managed objects for a given entity name.
//
//  Created by John Hannan on 10/11/10.
//  Copyright 2010, 2011, 2012, 2013 Penn State University. All rights reserved.
//

#import "DataManager.h"
#import "DataManagerDelegate.h"

#import  <CoreData/CoreData.h>

@interface DataManager ()

@property (nonatomic, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic,readonly) NSString *modelName;
@end

@implementation DataManager
@synthesize managedObjectContext=_managedObjectContext;
@synthesize managedObjectModel=_managedObjectModel;
@synthesize persistentStoreCoordinator=_persistentStoreCoordinator;


#pragma mark - Initialization

+(id)sharedInstance {
    static id singleton = nil;
    if (singleton == nil) {
        singleton = [[self alloc] init];
    }
    return singleton;
}


// Once the delegate is set we can ask it to create the database if it doesn't exist
-(void)setDelegate:(id<DataManagerDelegate>)delegate {
    _delegate = delegate;
    if (![self databaseExists]) {
        [self.delegate createDatabaseFor:self];
    }
}

#pragma mark - Save Context

- (void)saveContext {
    
    NSError *error = nil;
    if (_managedObjectContext != nil) {
        if ([_managedObjectContext hasChanges] && ![_managedObjectContext save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:[self.delegate xcDataModelName]
                                                          ofType:@"momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [NSURL fileURLWithPath: [self databasePath]];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSString *)databasePath
{
    NSString *sqlite = [NSString stringWithFormat:@"%@.sqlite", [self.delegate xcDataModelName]];
	return [[self applicationDocumentsDirectory] stringByAppendingPathComponent: sqlite];
}


- (BOOL)databaseExists
{
	NSString	*path = [self databasePath];
	BOOL		databaseExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
	
	return databaseExists;
}


#pragma mark -
#pragma mark Application's Documents directory

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark -
#pragma mark Fetching Data

- (NSArray *)fetchManagedObjectsForEntity:(NSString*)entityName
                                 sortKeys:(NSArray*)sortKeys
                                predicate:(NSPredicate *)predicate
{
	NSFetchRequest	*request = [NSFetchRequest fetchRequestWithEntityName:entityName];
	request.predicate = predicate;
	
    // create array of sort descriptors from array of sort keys
    NSMutableArray *sortDescriptors = [[NSMutableArray alloc] init];
    for (NSString *key in sortKeys) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key
                                                                       ascending:YES];
        [sortDescriptors addObject:sortDescriptor];
    }
	request.sortDescriptors=sortDescriptors ;
	
    NSManagedObjectContext	*context = [self managedObjectContext];
	NSArray	*results = [context executeFetchRequest:request error:nil];
	return results;
}



@end
