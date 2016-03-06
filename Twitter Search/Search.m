//
//  Search.m
//  Twitter Search
//
//  Created by Mario Cecchi on 06/03/2016.
//  Copyright © 2016 Mario Cecchi. All rights reserved.
//

#import "Search.h"

@implementation Search

+ (instancetype)searchWithUniqueQuery:(NSString *)uniqueQuery inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:NSStringFromClass(self.class) inManagedObjectContext:context];
    request.predicate = [NSPredicate predicateWithFormat:@"query == %@", uniqueQuery];
    
    NSError *error;
    Search *search = [[context executeFetchRequest:request error:&error] lastObject];
    
    if (error) {
        NSLog(@"Error fetching previous searches with query %@/ %@", uniqueQuery, error.localizedDescription);
    } else if (!search) {
        search = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self.class) inManagedObjectContext:context];
        search.query = uniqueQuery;
    }
    
    return search;
}

@end
