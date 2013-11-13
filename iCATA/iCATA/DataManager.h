//
//  DataManager.h
//
//  Created by John Hannan on 10/11/10.
//  Copyright 2010, 2011, 2012, 2013 Penn State University. All rights reserved.
//
// Most of this is the boilerplate code that Apple provides for Core Data.  A
// delegate provides a place for custom behavior: naming the Core Data model and
// the initial creation of the database (NSManaged Objects).  This class also provides
// a convenient method for fetching managed objects for a given entity name.


@protocol DataManagerDelegate;
@class NSManagedObject;

@interface DataManager : NSObject

@property (nonatomic,weak) id<DataManagerDelegate>delegate;

// Returns the 'singleton' instance of this class
+ (id)sharedInstance;

// save the managedObjectContext to its Persistant Store
- (void)saveContext;

// Core Data's Managed Object Context
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

// Fetch the entity, filtered by predicate, ordered by the sortKeys
// returns an array of NSManagedObjects (or a subclass)
- (NSArray *)fetchManagedObjectsForEntity:(NSString*)entityName
                                 sortKeys:(NSArray*)sortKeys
                                predicate:(NSPredicate*)predicate;


@end
