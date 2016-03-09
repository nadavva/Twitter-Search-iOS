//
//  Search+CoreDataProperties.h
//  Twitter Search
//
//  Created by Mario Cecchi on 06/03/2016.
//  Copyright © 2016 Mario Cecchi. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Search.h"

NS_ASSUME_NONNULL_BEGIN

@interface Search (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *query;
@property (nullable, nonatomic, retain) NSDate *date;

@end

NS_ASSUME_NONNULL_END
