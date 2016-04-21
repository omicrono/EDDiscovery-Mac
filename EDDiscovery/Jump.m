//
//  Jump.m
//  EDDiscovery
//
//  Created by thorin on 18/04/16.
//  Copyright © 2016 Moonrays. All rights reserved.
//

#import "Jump.h"
#import "System.h"
#import "EDSM.h"
#import "EventLogger.h"
#import "CoreDataManager.h"

@implementation Jump

+ (void)printStats {
  NSManagedObjectContext *context   = CoreDataManager.instance.managedObjectContext;
  NSString               *className = NSStringFromClass([Jump class]);
  NSFetchRequest         *request   = [[NSFetchRequest alloc] init];
  NSEntityDescription    *entity    = [NSEntityDescription entityForName:className inManagedObjectContext:context];
  NSError                *error     = nil;
  NSUInteger              count     = 0;
  NSArray<Jump *>        *array     = nil;
  
  request.entity                 = entity;
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

+ (NSArray *)getAllJumpsInContext:(NSManagedObjectContext *)context {
  NSString            *className = NSStringFromClass([Jump class]);
  NSFetchRequest      *request   = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity    = [NSEntityDescription entityForName:className inManagedObjectContext:context];
  NSError             *error     = nil;
  NSArray             *array     = nil;
  
  request.entity                 = entity;
  request.returnsObjectsAsFaults = NO;
  request.includesPendingChanges = YES;
  request.sortDescriptors        = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES]];
  
  array = [context executeFetchRequest:request error:&error];
  
  NSAssert1(error == nil, @"could not execute fetch request: %@", error);
  
  return array;
}

+ (Jump *)getLastJumpInContext:(NSManagedObjectContext *)context {
  NSString            *className = NSStringFromClass([Jump class]);
  NSFetchRequest      *request   = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity    = [NSEntityDescription entityForName:className inManagedObjectContext:context];
  NSError             *error     = nil;
  NSArray             *array     = nil;
  
  request.entity                 = entity;
  request.returnsObjectsAsFaults = NO;
  request.includesPendingChanges = YES;
  request.sortDescriptors        = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]];
  request.fetchLimit             = 1;
  
  array = [context executeFetchRequest:request error:&error];
  
  NSAssert1(error == nil, @"could not execute fetch request: %@", error);
  NSAssert1(array.count <= 1, @"this query should return at maximum 1 element: got %lu instead", (unsigned long)array.count);
  
  return array.lastObject;
}

@end
