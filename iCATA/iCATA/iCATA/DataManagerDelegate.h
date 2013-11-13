//
//  DataManagerDelegate.h
//  PSUSearch
//
//  Created by John Hannan on 10/9/12.
//  Copyright (c) 2012 John Hannan. All rights reserved.
//
// Delegate Protocol for use with the DataManager Class

#import <Foundation/Foundation.h>

@class DataManager;
@protocol DataManagerDelegate <NSObject>

// Provide the name of the Core Data Model (xcdadamodeld file added to project)
-(NSString*)xcDataModelName;

// create entities in the Managed Object Context using the Managed Object Model's entities
// typically initialized from data in a plist or some other form.
-(void)createDatabaseFor:(DataManager*)dataManager;
@end
