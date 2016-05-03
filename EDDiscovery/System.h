//
//  System.h
//  EDDiscovery
//
//  Created by Michele Noberasco on 18/04/16.
//  Copyright © 2016 Michele Noberasco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@class Note;
@class Distance;
@class Image;
@class Jump;

@interface System : NSManagedObject

+ (NSArray *)allSystems;
+ (System *)systemWithName:(NSString *)name;
+ (void)updateSystemsFromEDSM:(void(^)(void))response;

- (NSUInteger)numVisits;
- (BOOL)hasCoordinates;
- (NSNumber *)distanceToSol;

- (NSArray <System *> *)suggestedReferences;

- (void)updateFromEDSM:(void(^__nullable)(void))response;

@property(nonatomic, strong  ) NSArray  *distanceSortDescriptors;
@property(nonatomic, readonly) NSArray  *sortedDistances;
@property(nonatomic, readonly) NSArray  *suggestedReferences;
@property(nonatomic, strong  ) NSString *note;

@end

NS_ASSUME_NONNULL_END

#import "System+CoreDataProperties.h"
