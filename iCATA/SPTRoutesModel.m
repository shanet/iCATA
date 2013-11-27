//
//  SPTBuildingsModel.m
//  PSU Directory Search
//
//  Created by shane on 10/5/13.
//  Copyright (c) 2013 shane. All rights reserved.
//

#import "SPTRoutesModel.h"

// http://stackoverflow.com/questions/1560081/how-can-i-create-a-uicolor-from-a-hex-string
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface SPTRoutesModel()
@property (strong, nonatomic) NSMutableArray *routes;
@end

@implementation SPTRoutesModel

- (id) init {
    self = [super init];
    
    if(self) {
        _routes = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (NSString*) xcDataModelName {
    return @"Routes";
}

- (void) createDatabaseFor:(DataManager*)dataManager {
    // Inflate the routes and groups plist's into objects to be inserted into the database
    [self inflateRoutesPlistWithDataManager:dataManager];
    [self inflateRouteGroupsPlistWithDataManager:dataManager];
    
    [dataManager saveContext];
}

- (void) inflateRoutesPlistWithDataManager:(DataManager*)dataManager {
    NSString *routesPlistPath = [[NSBundle mainBundle]pathForResource:@"routes" ofType:@"plist"];
    NSArray *routesPlist = [NSArray arrayWithContentsOfFile:routesPlistPath];
        
    for(NSDictionary *dict in routesPlist) {
        SPTRoute *route = [NSEntityDescription insertNewObjectForEntityForName:@"Route" inManagedObjectContext:dataManager.managedObjectContext];
        
        route.name = [dict objectForKey:@"name"];
        route.code = [dict objectForKey:@"code"];
        route.routeId = [dict objectForKey:@"routeId"];
        route.hexColor = [dict objectForKey:@"color"];
        route.type = [dict objectForKey:@"type"];
        route.weight = [dict objectForKey:@"weight"];
        
        // Tint the icon according to the color of the route
        NSScanner *scanner = [NSScanner scannerWithString:[dict objectForKey:@"color"]];
        NSUInteger hexColor;
        [scanner scanHexInt:&hexColor];
        UIColor *tintColor = UIColorFromRGB(hexColor);
        UIImage *routeIcon = [UIImage imageNamed:@"routeIcon@2x.png"];
        route.icon = UIImagePNGRepresentation([SPTRoutesModel tintImage:routeIcon withColor:tintColor]);
        
        [self.routes addObject:route];
    }
}

- (void) inflateRouteGroupsPlistWithDataManager:(DataManager*)dataManager {
    NSString *groupsPlistPath = [[NSBundle mainBundle]pathForResource:@"groups" ofType:@"plist"];
    NSArray *groupsPlist = [NSArray arrayWithContentsOfFile:groupsPlistPath];
    
    for(NSDictionary *dict in groupsPlist) {
        SPTRouteGroup *group = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:dataManager.managedObjectContext];
        
        group.name = [dict objectForKey:@"name"];
        
        for(NSNumber *routeId in [dict objectForKey:@"routes"]) {
            SPTRoute *route = [self getRouteWithId:routeId];
            if(route != nil) {
                [group.routes addObject:route];
            }
        }
    }
}

- (SPTRoute*) getRouteWithId:(NSNumber*)routeId {
    for(SPTRoute *route in self.routes) {
        if([routeId isEqualToNumber:route.routeId]) {
            return route;
        }
    }
    
    return nil;
}

+ (void) addGroupToDatabase:(NSDictionary*)dict {
    DataManager *dataManager = [DataManager sharedInstance];
    SPTRouteGroup *group = [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:dataManager.managedObjectContext];
    
    group.name = [dict objectForKey:@"name"];
    
    for(SPTRoute *route in [dict objectForKey:@"routes"]) {
        [group.routes addObject:route];
    }
    
    [dataManager saveContext];
}

// http://stackoverflow.com/questions/3514066/how-to-tint-a-transparent-png-image-in-iphone
+ (UIImage *) tintImage:(UIImage*)image withColor:(UIColor *)tintColor {
    UIGraphicsBeginImageContextWithOptions (image.size, NO, [[UIScreen mainScreen] scale]);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    // draw original image
    [image drawInRect:rect blendMode:kCGBlendModeNormal alpha:1.0f];
    
    // tint image (loosing alpha).
    // kCGBlendModeOverlay is the closest I was able to match the
    // actual process used by apple in navigation bar
    CGContextSetBlendMode(context, kCGBlendModeOverlay);
    [tintColor setFill];
    CGContextFillRect(context, rect);
    
    // mask by alpha values of original image
    [image drawInRect:rect blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tintedImage;
}


@end
