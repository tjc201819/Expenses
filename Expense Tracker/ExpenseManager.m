//
//  ExpenseManager.m
//  Expense Tracker
//
//  Created by Hendrik Noeller on 29.06.14.
//  Copyright (c) 2014 Hendrik Noeller. All rights reserved.
//

#import "ExpenseManager.h"
@interface ExpenseManager ()
@property (strong, nonatomic) NSString *createdExpenseName;
@property (nonatomic) BOOL createdExpensePositive;
@property (nonatomic, copy) void (^completion)();
@end
@implementation ExpenseManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self load];
        if (!_expenses) {
            _expenses = [[NSMutableArray alloc] init];
        }
    }
    return self;
}

- (void)load
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@/expenses", docDir];
    _expenses = [NSKeyedUnarchiver unarchiveObjectWithFile:fileName];
}

- (void)save
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@/expenses", docDir];
    [NSKeyedArchiver archiveRootObject:_expenses toFile:fileName];
}


#pragma mark - Expense Management

- (void)addExpense:(NSInteger)amount name:(NSString *)name
{
    Expense *expense = [[Expense alloc] init];
    expense.name = name;
    expense.amount = amount;
    [self.expenses addObject:expense];
    [self save];
}

- (void)removeExpenseAtIndex:(NSInteger)index
{
    [_expenses removeObjectAtIndex:index];
    [self save];
}

- (void)editExepense:(NSInteger)amount name:(NSString*)name atIndex:(NSInteger)index
{
    Expense *expense = [[Expense alloc] init];
    expense.name = name;
    expense.amount = amount;
    [_expenses setObject:expense atIndexedSubscript:index];
    [self save];
}

- (void)moveExpenseFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
{
    Expense *temp = _expenses[fromIndex];
    [_expenses removeObjectAtIndex:fromIndex];
    [_expenses insertObject:temp atIndex:toIndex];
    [self save];
}


#pragma mark - Value Getters

- (float)saldo {
    float saldo = 0;
    for (Expense *expense in _expenses) {
        saldo = saldo+expense.amount;
    }
    return saldo/100;
}

- (float)positives {
    float positives = 0;
    for (Expense *expense in _expenses) {
        if(expense.amount > 0) {
            positives = positives + expense.amount;
        }
    }
    return positives/100;
}

- (float)negatives {
    float negatives = 0;
    for (Expense *expense in _expenses) {
        if(expense.amount < 0) {
            negatives = negatives - expense.amount;
        }
    }
    return negatives/100;
}



@end
