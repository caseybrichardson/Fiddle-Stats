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

@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) UICollectionView *collectionView;

@property (strong, nonatomic) NSString *reuseIdentifier;

@end

@implementation FSDataDelegate

- (instancetype)initWithType:(FSDataDelegateType)type forView:(id)view entityName:(NSString *)entityName inContext:(NSManagedObjectContext *)context{
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
        
        switch(type) {
            case FSDataDelegateTypeTableView:
                self.tableView = view;
                break;
            case FSDataDelegateTypeCollectionView:
                self.collectionView = view;
                break;
        }
    }
    
    return self;
}

- (void)setSectionNameKeyPath:(NSString *)sectionNameKeyPath {
    _fetchedResultsController = nil;
    
    _sectionNameKeyPath = sectionNameKeyPath;
}

- (void)setSortingKeyPaths:(NSArray *)sortingKeyPaths {
    _fetchedResultsController = nil;
    
    _sortingKeyPaths = sortingKeyPaths;
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
        for (FSDataPair *t in self.sortingKeyPaths) {
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

- (void)setReuseIdentifier:(NSString *)reuseIdentifier {
    _reuseIdentifier = reuseIdentifier;
}

- (void)performFetch {
    NSError *error;
    if(![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"%@ %@", error, [error userInfo]);
    } else {
        switch (self.delegateType) {
            case FSDataDelegateTypeTableView:
                [self.tableView reloadData];
                break;
            case FSDataDelegateTypeCollectionView:
                [self.collectionView reloadData];
                break;
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_reuseIdentifier];
    
    _tableViewCellSource(tableView, cell, [self fetchedResultsController], indexPath);
    
    return cell;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    id sectionInfo = [[self fetchedResultsController] sections][section];
    return [sectionInfo numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_reuseIdentifier forIndexPath:indexPath];
    
    _collectionViewCellSource(collectionView, cell, [self fetchedResultsController], indexPath);
    
    return cell;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    switch (self.delegateType) {
        case FSDataDelegateTypeTableView:
            [self willChangeTableViewContent:controller];
            break;
        case FSDataDelegateTypeCollectionView:
            [self willChangeCollectionViewContent:controller];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    switch (self.delegateType) {
        case FSDataDelegateTypeTableView:
            [self didChangeTableViewContent:controller];
            break;
        case FSDataDelegateTypeCollectionView:
            [self didChangeCollectionViewContent:controller];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch (self.delegateType) {
        case FSDataDelegateTypeTableView:
            [self didChangeTableViewSection:sectionInfo atIndex:sectionIndex forChangeType:type];
            break;
        case FSDataDelegateTypeCollectionView:
            [self didChangeCollectionViewSection:sectionInfo atIndex:sectionIndex forChangeType:type];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch (self.delegateType) {
        case FSDataDelegateTypeTableView:
            [self didChangeTableViewObject:anObject atIndexPath:indexPath forChangeType:type newIndexPath:newIndexPath];
            break;
        case FSDataDelegateTypeCollectionView:
            [self didChangeCollectionViewObject:anObject atIndexPath:indexPath forChangeType:type newIndexPath:newIndexPath];
            break;
    }
}

#pragma mark - Collection View Functions

- (void)willChangeCollectionViewContent:(NSFetchedResultsController *)controller {
    self.sectionChanges = [NSMutableArray array];
    self.itemChanges = [NSMutableArray array];
}

- (void)didChangeCollectionViewContent:(NSFetchedResultsController *)controller {
    [self.collectionView performBatchUpdates:^{
        for (NSDictionary *dict in self.sectionChanges) {
            [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                
                switch (type) {
                    case NSFetchedResultsChangeInsert:
                        [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                        break;
                    case NSFetchedResultsChangeDelete:
                        [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                        break;
                    case NSFetchedResultsChangeUpdate:
                        break;
                    case NSFetchedResultsChangeMove:
                        break;
                }
            }];
        }
        
        for (NSDictionary *dict in self.itemChanges) {
            [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                
                switch (type) {
                    case NSFetchedResultsChangeInsert:
                        [self.collectionView insertItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeDelete:
                        [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeUpdate:
                        [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeMove:
                        [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                        break;
                }
            }];
        }
    } completion:^(BOOL finished) {
        self.sectionChanges = nil;
        self.itemChanges = nil;
    }];
}

- (void)didChangeCollectionViewSection:(id)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    NSMutableDictionary *change = [NSMutableDictionary dictionary];
    change[@(type)] = @(sectionIndex);
    [self.sectionChanges addObject:change];
}

- (void)didChangeCollectionViewObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    NSMutableDictionary *change = [NSMutableDictionary dictionary];
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    
    [self.itemChanges addObject:change];
}

#pragma mark - Table View Functions

- (void)willChangeTableViewContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)didChangeTableViewContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

- (void)didChangeTableViewSection:(id)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationNone];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationNone];
            break;
        case NSFetchedResultsChangeMove:
        case NSFetchedResultsChangeUpdate:
            break;
    }
}

- (void)didChangeTableViewObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
        case NSFetchedResultsChangeUpdate:
            _tableViewCellSource(self.tableView, [self.tableView cellForRowAtIndexPath:indexPath], [self fetchedResultsController], indexPath);
            break;
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            break;
    }
}

@end
