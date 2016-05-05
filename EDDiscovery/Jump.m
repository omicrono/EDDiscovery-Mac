//
//  Jump.m
//  EDDiscovery
//
//  Created by Michele Noberasco on 18/04/16.
//  Copyright © 2016 Michele Noberasco. All rights reserved.
//

#import "Jump.h"
#import "System.h"
#import "EDSM.h"
#import "EventLogger.h"
#import "CoreDataManager.h"
#import "Distance.h"
#import "Commander.h"
#import "NetLogFile.h"

@implementation Jump

+ (void)printStatsOfCommander:(Commander *)commander {
  NSManagedObjectContext *context   = CoreDataManager.instance.managedObjectContext;
  NSString               *className = NSStringFromClass([Jump class]);
  NSFetchRequest         *request   = [[NSFetchRequest alloc] init];
  NSEntityDescription    *entity    = [NSEntityDescription entityForName:className inManagedObjectContext:context];
  NSError                *error     = nil;
  NSUInteger              count     = 0;
  NSArray<Jump *>        *array     = nil;
  
  request.entity                 = entity;
  request.predicate              = CMDR_PREDICATE;
  request.returnsObjectsAsFaults = YES;
  request.includesPendingChanges = YES;

  count = [context countForFetchRequest:request error:&error];
  
  NSAssert1(error == nil, @"could not execute fetch request: %@", error);
  
  request.returnsObjectsAsFaults = NO;
  request.sortDescriptors        = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES]];
  request.fetchLimit             = 1;
  
  array = [context executeFetchRequest:request error:&error];
  
  NSAssert1(error == nil, @"could not execute fetch request: %@", error);
  
  NSTimeInterval start = array.firstObject.timestamp;
  
  request.sortDescriptors        = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]];
  
  array = [context executeFetchRequest:request error:&error];
  
  NSAssert1(error == nil, @"could not execute fetch request: %@", error);
  
  NSTimeInterval end = array.firstObject.timestamp;
  
  NSDateFormatter *dateTimeFormatter = [[NSDateFormatter alloc] init];

  dateTimeFormatter.dateFormat = @"yyyy-MM-dd";

  NSString *from = [dateTimeFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:start]];
  NSString *to   = [dateTimeFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:end]];
  NSString *msg  = [NSString stringWithFormat:@"DB contains %ld jumps from %@ to %@", (long)count, from, to];

  [EventLogger addLog:msg];
}

+ (NSArray *)allJumpsOfCommander:(Commander *)commander {
  NSManagedObjectContext *context   = commander.managedObjectContext;
  NSString               *className = NSStringFromClass([Jump class]);
  NSFetchRequest         *request   = [[NSFetchRequest alloc] init];
  NSEntityDescription    *entity    = [NSEntityDescription entityForName:className inManagedObjectContext:context];
  NSError                *error     = nil;
  NSArray                *array     = nil;
  
  request.entity                 = entity;
  request.predicate              = CMDR_PREDICATE;
  request.returnsObjectsAsFaults = NO;
  request.includesPendingChanges = YES;
  request.sortDescriptors        = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES]];
  
  array = [context executeFetchRequest:request error:&error];
  
  NSAssert1(error == nil, @"could not execute fetch request: %@", error);
  
  return array;
}

+ (Jump *)lastJumpOfCommander:(Commander *)commander {
  NSManagedObjectContext *context   = commander.managedObjectContext;
  NSString               *className = NSStringFromClass([Jump class]);
  NSFetchRequest         *request   = [[NSFetchRequest alloc] init];
  NSEntityDescription    *entity    = [NSEntityDescription entityForName:className inManagedObjectContext:context];
  NSError                *error     = nil;
  NSArray                *array     = nil;
  
  request.entity                 = entity;
  request.predicate              = CMDR_PREDICATE;
  request.returnsObjectsAsFaults = NO;
  request.includesPendingChanges = YES;
  request.sortDescriptors        = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]];
  request.fetchLimit             = 1;
  
  array = [context executeFetchRequest:request error:&error];
  
  NSAssert1(error == nil, @"could not execute fetch request: %@", error);
  NSAssert1(array.count <= 1, @"this query should return at maximum 1 element: got %lu instead", (unsigned long)array.count);
  
  return array.lastObject;
}

+ (Jump *)lastXYZJumpOfCommander:(Commander *)commander {
  NSManagedObjectContext *context   = commander.managedObjectContext;
  NSString               *className = NSStringFromClass([Jump class]);
  NSFetchRequest         *request   = [[NSFetchRequest alloc] init];
  NSEntityDescription    *entity    = [NSEntityDescription entityForName:className inManagedObjectContext:context];
  NSError                *error     = nil;
  NSArray                *array     = nil;
  
  request.entity                 = entity;
  request.predicate              = [NSCompoundPredicate andPredicateWithSubpredicates:@[CMDR_PREDICATE, [NSPredicate predicateWithFormat:@"system.x != nil && system.y != nil && system.z != nil"]]];
  request.returnsObjectsAsFaults = NO;
  request.includesPendingChanges = YES;
  request.sortDescriptors        = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]];
  request.fetchLimit             = 1;
  
  array = [context executeFetchRequest:request error:&error];
  
  NSAssert1(error == nil, @"could not execute fetch request: %@", error);
  NSAssert1(array.count <= 1, @"this query should return at maximum 1 element: got %lu instead", (unsigned long)array.count);
  
  return array.lastObject;
}

- (NSNumber *)distanceFromPreviousJump {
  NSString            *className = NSStringFromClass([Jump class]);
  NSFetchRequest      *request   = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity    = [NSEntityDescription entityForName:className inManagedObjectContext:self.managedObjectContext];
  NSError             *error     = nil;
  NSArray             *array     = nil;
  NSNumber            *distance  = nil;
  Commander           *commander = self.edsm.commander;
  
  if (commander == nil) {
    commander = self.netLogFile.commander;
  }
  
  NSAssert(commander != nil, @"Current jump must have a commander!");
  
  request.entity                 = entity;
  request.returnsObjectsAsFaults = NO;
  request.includesPendingChanges = YES;
  request.predicate              = [NSCompoundPredicate andPredicateWithSubpredicates:@[CMDR_PREDICATE, [NSPredicate predicateWithFormat:@"timestamp <= %@", [NSDate dateWithTimeIntervalSinceReferenceDate:self.timestamp]]]];
  request.sortDescriptors        = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]];
  request.fetchLimit             = 2;
  
  array = [self.managedObjectContext executeFetchRequest:request error:&error];
  
  NSAssert1(error == nil, @"could not execute fetch request: %@", error);
  NSAssert1(array.count <= 2, @"this query should return at maximum 1 element: got %lu instead", (unsigned long)array.count);
  
  if (array.count == 2) {
    Jump     *jump     = array.lastObject;
    NSString *name     = jump.system.name;
    
    
    for (Distance *aDistance in self.system.distances) {
      if (aDistance.distance == aDistance.calculatedDistance && [aDistance.name isEqualToString:name]) {
        distance = aDistance.distance;
        
        break;
      }
    }
    
    if (distance == nil) {
      for (Distance *aDistance in jump.system.distances) {
        if (aDistance.distance == aDistance.calculatedDistance && [aDistance.name isEqualToString:name]) {
          distance = aDistance.distance;
          
          break;
        }
      }
    }
  }
  
  return distance;
}

@end
