//
//  Jump+CoreDataProperties.h
//  EDDiscovery
//
//  Created by Michele Noberasco on 30/04/16.
//  Copyright © 2016 Michele Noberasco. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Jump.h"

NS_ASSUME_NONNULL_BEGIN

@interface Jump (CoreDataProperties)

@property (nonatomic) NSTimeInterval timestamp;
@property (nullable, nonatomic, retain) EDSM *edsm;
@property (nullable, nonatomic, retain) NetLogFile *netLogFile;
@property (nullable, nonatomic, retain) System *system;

@end

NS_ASSUME_NONNULL_END