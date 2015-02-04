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
@property (copy, nonatomic, readonly) ItemSelected itemSelectionHandler;

@property (strong, nonatomic) NSString *entityName;
@property (strong, nonatomic) NSString *sectionNameKeyPath;
@property (strong, nonatomic) NSArray *sortingKeyPaths;
@property (strong, nonatomic) FSDataPair *predicateValues;

@property (assign, nonatomic) NSInteger staticCellCount;

@property (weak, nonatomic) NSManagedObjectContext *context;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSMutableArray *sectionChanges;
@property (strong, nonatomic) NSMutableArray *itemChanges;

@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) UICollectionView *collectionView;

@property (strong, nonatomic) NSString *reuseIdentifier;

@property (strong, nonatomic) NSBlockOperation *updateOperation;
@property (assign, nonatomic) BOOL shouldReloadCollectionView;

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
    self.fetchedResultsController = nil;
    
    _sectionNameKeyPath = sectionNameKeyPath;
}

- (void)setSortingKeyPaths:(NSArray *)sortingKeyPaths {
    self.fetchedResultsController = nil;
    
    _sortingKeyPaths = sortingKeyPaths;
}

- (void)setPredicateValues:(FSDataPair *)predicateValues{
    self.fetchedResultsController = nil;
    
    _predicateValues = predicateValues;
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
    [request setFetchBatchSize:100];
    
    if(sortDescriptors) {
        [request setSortDescriptors:sortDescriptors];
    }

    if(self.predicateValues) {
        [request setPredicate:[NSPredicate predicateWithFormat:self.predicateValues.first, self.predicateValues.second]];
    }
    
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

- (void)setItemSelectionHandler:(ItemSelected)itemSelectionHandler {
    _itemSelectionHandler = itemSelectionHandler;
}

- (void)setReuseIdentifier:(NSString *)reuseIdentifier {
    _reuseIdentifier = reuseIdentifier;
}

- (void)setStaticCellCount:(NSInteger)staticCellCount {
    _staticCellCount = staticCellCount;
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

- (NSArray *)fetchedObjects {
    return self.fetchedResultsController.fetchedObjects;
}

- (id)objectInResultsAtIndexPath:(NSIndexPath *)indexPath {
    if(self.fetchedResultsController) {
        return [self.fetchedResultsController objectAtIndexPath:indexPath];
    } else {
        return nil;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
     return [[[self fetchedResultsController] sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id sectionInfo = [[self fetchedResultsController] sections][section];
    return [sectionInfo numberOfObjects] + self.staticCellCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_reuseIdentifier];
    
    _tableViewCellSource(tableView, cell, [self fetchedResultsController], indexPath);
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(_itemSelectionHandler) {
        _itemSelectionHandler(tableView, [self fetchedResultsController], indexPath);
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [[[self fetchedResultsController] sections] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    id sectionInfo = [[self fetchedResultsController] sections][section];
    return [sectionInfo numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_reuseIdentifier forIndexPath:indexPath];
    
    _collectionViewCellSource(collectionView, cell, [self fetchedResultsController], indexPath);
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if(kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SectionView" forIndexPath:indexPath];
        UILabel *label = (UILabel *)[header viewWithTag:99];
        NSString *sectionTitle = [[[[self fetchedResultsController] sections] objectAtIndex:[indexPath section]] name];
        [label setText:sectionTitle];
        
        return header;
    }
    
    return nil;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if(_itemSelectionHandler) {
        _itemSelectionHandler(collectionView, [self fetchedResultsController], indexPath);
    }
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
    self.shouldReloadCollectionView = NO;
    self.updateOperation = [NSBlockOperation new];
}

- (void)didChangeCollectionViewContent:(NSFetchedResultsController *)controller {
    
    if(!self.collectionView.window) {
        [self.collectionView reloadData];
    }
    
    if (self.shouldReloadCollectionView || !self.collectionView.window) {
        [self.collectionView reloadData];
    } else {
        [self.collectionView performBatchUpdates:^{
            [self.updateOperation start];
        } completion:nil];
    }
}

- (void)didChangeCollectionViewSection:(id)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    if(!self.collectionView.window) {
        return;
    }
    
    __weak UICollectionView *collectionView = self.collectionView;
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            self.shouldReloadCollectionView = YES;
            /*[self.updateOperation addExecutionBlock:^{
                [collectionView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
            }];*/
            break;
        }
        case NSFetchedResultsChangeDelete: {
            self.shouldReloadCollectionView = YES;
            /*[self.updateOperation addExecutionBlock:^{
                [collectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
            }];*/
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            [self.updateOperation addExecutionBlock:^{
                [collectionView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
            }];
            break;
        }
        default:
            break;
    }
}

- (void)didChangeCollectionViewObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if(!self.collectionView.window) {
        return;
    }
    
    __weak UICollectionView *collectionView = self.collectionView;
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            if ([self.collectionView numberOfSections] > 0) {
                if ([self.collectionView numberOfItemsInSection:indexPath.section] == 0) {
                    self.shouldReloadCollectionView = YES;
                } else {
                    [self.updateOperation addExecutionBlock:^{
                        [collectionView insertItemsAtIndexPaths:@[newIndexPath]];
                    }];
                }
            } else {
                self.shouldReloadCollectionView = YES;
            }
            break;
        }
        case NSFetchedResultsChangeDelete: {
            if ([self.collectionView numberOfItemsInSection:indexPath.section] == 1) {
                self.shouldReloadCollectionView = YES;
            } else {
                [self.updateOperation addExecutionBlock:^{
                    [collectionView deleteItemsAtIndexPaths:@[indexPath]];
                }];
            }
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            [self.updateOperation addExecutionBlock:^{
                [collectionView reloadItemsAtIndexPaths:@[indexPath]];
            }];
            break;
        }
        case NSFetchedResultsChangeMove: {
            if([collectionView numberOfItemsInSection:indexPath.section] == 1) {
                [collectionView reloadData];
            } else {
                [self.updateOperation addExecutionBlock:^{
                    [collectionView moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
                }];
            }
            break;
        }
    }
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
