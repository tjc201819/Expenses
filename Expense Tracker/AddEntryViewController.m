//
//  AddEntryViewController.m
//  Expenses
//
//  Created by Hendrik Noeller on 30.06.14.
//  Copyright (c) 2015 Hendrik Noeller. All rights reserved.
//
/*Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.*/
//

#import "AddEntryViewController.h"
#import "Expense.h"
#import "NSString+CommaDoubleValue.h"
#import "NSDate+Formatted.h"
#import "StaticValues.h"

@interface AddEntryViewController()
@property (weak, nonatomic) IBOutlet UISegmentedControl *addSpendSegmented;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (weak, nonatomic) IBOutlet UITextField *amountTextField;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation AddEntryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _addSpendSegmented.selectedSegmentIndex = 1;
    _descriptionTextField.text = @"";
    _dateButton.titleLabel.text = @"";
    _amountTextField.text = @"";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_expense) {
        _descriptionTextField.text = _expense.name;
        [_dateButton setTitle:_expense.date.formattedWhole forState:UIControlStateNormal];
        _datePicker.date = _expense.date;
        if (_expense.amount < 0) {
            _amountTextField.text = [NSString stringWithFormat:@"%.02f", ((double)_expense.amount)/-100.0];
            _addSpendSegmented.selectedSegmentIndex = 1;
        } else {
            _amountTextField.text = [NSString stringWithFormat:@"%.02f", ((double)_expense.amount)/100.0];
            _addSpendSegmented.selectedSegmentIndex = 0;
        }
        _amountTextField.text = [_amountTextField.text stringByReplacingOccurrencesOfString:@"." withString:@","];
        self.navigationItem.title = NSLocalizedString(@"ADD_ENTRY_EDIT_ENTRY", @"");
    } else {
        self.navigationItem.title = NSLocalizedString(@"ADD_ENTRY_ADD_ENTRY", @"");
        [_dateButton setTitle:[NSDate date].formattedWhole forState:UIControlStateNormal];
        self.datePicker.date = [NSDate date];
    }
    [self.amountTextField becomeFirstResponder];
    [self updateInfoLabel];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _expense = nil;
    _indexOfExpense = 0;
    [self.descriptionTextField resignFirstResponder];
    [self.amountTextField resignFirstResponder];
}

- (IBAction)segmentedDidChange:(id)sender
{
    [self updateInfoLabel];
}

- (IBAction)amountFieldDidChange:(id)sender
{
    [self updateInfoLabel];
}

- (IBAction)dateDidChange:(id)sender
{
    [_dateButton setTitle:[self.datePicker.date formattedWhole] forState:UIControlStateNormal];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.amountTextField) {
        [self.descriptionTextField becomeFirstResponder];
    } else if (textField == self.descriptionTextField) {
        [self.descriptionTextField resignFirstResponder];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField selectAll:nil];
}

- (IBAction)dateSelect:(id)sender
{
    [self.descriptionTextField resignFirstResponder];
    [self.amountTextField resignFirstResponder];
}

- (void)updateInfoLabel
{
    double value = 0.0;
    if (_expense) {
        if (_addSpendSegmented.selectedSegmentIndex == 1) {
            value = self.account.saldo - [_amountTextField.text commaDoubleValue] - (_expense.amount / 100.0);
        } else if (_addSpendSegmented.selectedSegmentIndex == 0) {
            value = self.account.saldo + [_amountTextField.text commaDoubleValue] - (_expense.amount / 100.0);
        }
    } else {
        if (_addSpendSegmented.selectedSegmentIndex == 1) {
            value = self.account.saldo - _amountTextField.text.commaDoubleValue;
        } else if (_addSpendSegmented.selectedSegmentIndex == 0) {
            
            value = self.account.saldo + _amountTextField.text.commaDoubleValue;
        }
    }
    _infoLabel.text = [NSString stringWithFormat:@"%@ %@%.02f", NSLocalizedString(@"ADD_ENTRY_YOU_ARE_LEFT", @""), [self.account currencyWithSpace], value];
    _infoLabel.text = [_infoLabel.text stringByReplacingOccurrencesOfString:@"." withString:@","];
    if (value < 0) {
        _infoLabel.textColor = RED_COLOR;
    } else {
        _infoLabel.textColor = [UIColor lightGrayColor];
    }
}

- (IBAction)done:(id)sender
{
    //Seemingly stupid calculation to increase presicion to overcome floating point error that sometimes lost cents when using *100 instead of *10000/100
    NSInteger amount = (_amountTextField.text.commaDoubleValue*10000)/100;
    if (_addSpendSegmented.selectedSegmentIndex == 1) {
        amount = -amount;
    }
    if (_expense) {
        [self.account editExepense:amount name:_descriptionTextField.text date:self.datePicker.date atIndex:_indexOfExpense];
    } else {
        [self.account addExpense:amount name:_descriptionTextField.text date:self.datePicker.date];
    }
    [self closeModalView];
}

- (IBAction)cancel:(id)sender
{
    [self closeModalView];
}

- (void)closeModalView
{
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
