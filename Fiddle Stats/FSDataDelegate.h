//
//  FSDataDelegate.h
//  Fiddle Stats
//
//  Created by Casey Richardson on 11/26/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "Tuple.h"

typedef NS_ENUM(NSUInteger, FSDataDelegateType) {
    FSDataDelegateTypeTableView,
    FSDataDelegateTypeCollectionView
};

typedef UITableViewCell *(^TableViewCellSource)(UITableView *, NSIndexPath *);
typedef UICollectionViewCell *(^CollectionViewCellSource)(UICollectionView *, NSIndexPath *);

@interface FSDataDelegate : NSObject <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate>

@property (assign, nonatomic, readonly) FSDataDelegateType delegateType;

- (instancetype)initWithType:(FSDataDelegateType)type entityName:(NSString *)entityName inContext:(NSManagedObjectContext *)context;

- (void)setTableViewCellSource:(TableViewCellSource)tableViewCellSource;
- (void)setCollectionViewCellSource:(CollectionViewCellSource)collectionViewCellSource;

@end
