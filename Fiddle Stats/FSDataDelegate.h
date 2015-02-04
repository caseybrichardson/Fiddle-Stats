//
//  FSDataDelegate.h
//  Fiddle Stats
//
//  Created by Casey Richardson on 11/26/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "FSDataPair.h"
#import "SummonerGroup+Helpers.h"

typedef NS_ENUM(NSUInteger, FSDataDelegateType) {
    FSDataDelegateTypeTableView,
    FSDataDelegateTypeCollectionView
};

typedef void(^TableViewCellSource)(UITableView *tableView, UITableViewCell *cell, NSFetchedResultsController *frc, NSIndexPath *indexPath);
typedef void(^CollectionViewCellSource)(UICollectionView *collectionView, UICollectionViewCell *cell, NSFetchedResultsController *frc, NSIndexPath *indexPath);
typedef void(^ItemSelected)(id view, NSFetchedResultsController *frc, NSIndexPath *indexPath);

@interface FSDataDelegate : NSObject <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate>

@property (assign, nonatomic, readonly) FSDataDelegateType delegateType;

- (instancetype)initWithType:(FSDataDelegateType)type forView:(id)view entityName:(NSString *)entityName inContext:(NSManagedObjectContext *)context;
- (void)setSectionNameKeyPath:(NSString *)sectionNameKeyPath;
- (void)setSortingKeyPaths:(NSArray *)sortingKeyPaths;
- (void)setPredicateValues:(FSDataPair *)predicateValues;
- (void)setTableViewCellSource:(TableViewCellSource)tableViewCellSource;
- (void)setCollectionViewCellSource:(CollectionViewCellSource)collectionViewCellSource;
- (void)setItemSelectionHandler:(ItemSelected)itemSelectionHandler;
- (void)setReuseIdentifier:(NSString *)reuseIdentifier;
- (void)setStaticCellCount:(NSInteger)staticCellCount;
- (NSArray *)fetchedObjects;
- (void)performFetch;
- (id)objectInResultsAtIndexPath:(NSIndexPath *)indexPath;

@end
