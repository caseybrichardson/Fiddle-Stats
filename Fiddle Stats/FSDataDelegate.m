//
//  FSDataDelegate.m
//  Fiddle Stats
//
//  Created by Casey Richardson on 11/26/14.
//  Copyright (c) 2014 Casey Richardson. All rights reserved.
//

#import "FSDataDelegate.h"

@interface FSDataDelegate ()

@property (copy, nonatomic, readonly) TableViewCellSource tableViewCellSource;
@property (copy, nonatomic, readonly) CollectionViewCellSource collectionViewCellSource;

@property (strong, nonatomic) NSString *entityName;
@property (strong, nonatomic) NSString *sectionNameKeyPath;
@property (strong, nonatomic) NSArray *sortingKeyPaths;

@property (weak, nonatomic) NSManagedObjectContext *context;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSMutableArray *sectionChanges;
@property (strong, nonatomic) NSMutableArray *itemChanges;

@end

@implementation FSDataDelegate

- (instancetype)initWithType:(FSDataDelegateType)type entityName:(NSString *)entityName inContext:(NSManagedObjectContext *)context{
    self = [super init];
    
    if(self) {
        _delegateType = type;
        
        if(!entityName) {
            [NSException raise:@"Parameter \'entityName\' cannot be nil." format:nil];
        }
        
        self.entityName = entityName;
        
        if(!context) {
            [NSException raise:@"Parameter \'context\' cannot be nil." format:nil];
        }
        
        self.context = context;
    }
    
    return self;
}

- (void)setSectionNameKeyPath:(NSString *)sectionNameKeyPath {
    _fetchedResultsController = nil;
    
    self.sectionNameKeyPath = sectionNameKeyPath;
}

- (void)setSortingKeyPaths:(NSArray *)sortingKeyPaths {
    _fetchedResultsController = nil;
    
    self.sortingKeyPaths = sortingKeyPaths;
}

- (NSFetchedResultsController *)fetchedResultsController {
    if(_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:self.entityName];
    NSEntityDescription *description = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:self.context];
    
    NSMutableArray *sortDescriptors;
    if(self.sortingKeyPaths) {
        sortDescriptors = [NSMutableArray array];
        for (Tuple *t in self.sortingKeyPaths) {
            NSString *keyPath = t.first;
            BOOL ascending = [t.second boolValue];
            [sortDescriptors addObject:[NSSortDescriptor sortDescriptorWithKey:keyPath ascending:ascending]];
        }
    }
    
    [request setEntity:description];
    
    if(sortDescriptors) {
        [request setSortDescriptors:sortDescriptors];
    }
    
    [request setFetchBatchSize:100];
    
    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.context sectionNameKeyPath:self.sectionNameKeyPath cacheName:nil];
    self.fetchedResultsController = controller;
    self.fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

- (void)setTableViewCellSource:(TableViewCellSource)tableViewCellSource {
    if(_delegateType == FSDataDelegateTypeCollectionView) {
        [NSException raise:@"Setting UITableViewDataSource; expected UICollectionViewDataSource." format:nil];
    }
    
    _tableViewCellSource = tableViewCellSource;
}

- (void)setCollectionViewCellSource:(CollectionViewCellSource)collectionViewCellSource {
    if(_delegateType == FSDataDelegateTypeTableView) {
        [NSException raise:@"Setting UICollectionViewDataSource; expected UITableViewDataSource." format:nil];
    }
    
    _collectionViewCellSource = collectionViewCellSource;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return _tableViewCellSource(tableView, indexPath);
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return _collectionViewCellSource(collectionView, indexPath);
}

@end
