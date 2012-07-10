//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Robert Cole on 6/29/12.
//  Copyright (c) 2012 Robert Cole. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"

#pragma mark - Private properties and operations

@interface CalculatorViewController ()

@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic, strong) CalculatorBrain *brain;
@property (nonatomic, strong) NSDictionary *testVariableValues;

- (void)appendDigitToDisplay:(NSString *)digitAsString;

- (void)updateDisplay;

@end

#pragma mark - Implementation

@implementation CalculatorViewController

@synthesize display;
@synthesize historyDisplay;
@synthesize variablesDisplay;
@synthesize userIsInTheMiddleOfEnteringANumber;
@synthesize brain = _brain;
@synthesize testVariableValues;

#pragma mark - Getters (private)

- (CalculatorBrain *)brain {
    if (!_brain) {
        _brain = [[CalculatorBrain alloc]init];
    }
    
    return _brain;
}

#pragma mark - Actions

- (IBAction)digitPressed:(UIButton *)sender {
    NSString *digit = sender.currentTitle;
    [self appendDigitToDisplay:digit];

}

- (IBAction)decimalPressed {
    if ([self.display.text rangeOfString:@"."].location == NSNotFound) {
        [self appendDigitToDisplay:@"."];
    }
}

- (IBAction)enterPressed {
    [self.brain pushOperand:[self.display.text doubleValue]];
    
    [self updateDisplay];
    
    self.userIsInTheMiddleOfEnteringANumber = NO;
}

- (IBAction)clearPressed {
    [self.brain clearAllOperands];
    self.display.text = @"0";
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.historyDisplay.text = @"";
}

- (IBAction)operationPressed:(UIButton *)sender {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    
    NSString *operation = [sender currentTitle];
    
    [self.brain performOperation:operation];
    
    [self updateDisplay];
}

- (IBAction)variablePressed:(UIButton *)sender {
    NSString *variable = sender.currentTitle;
    
    [self.brain pushVariable:variable];
    
    [self updateDisplay];
}

- (IBAction)undoPressed {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [self.display.text substringToIndex:([self.display.text length] - 1)];
        
        if ([self.display.text length] <= 0) {
            self.userIsInTheMiddleOfEnteringANumber = NO;
            self.display.text = @"0";
        }
    } else {
        [self.brain undoLastOperationVariableOrOperand];
        [self updateDisplay];
    }
}

- (IBAction)test1Pressed {
    self.testVariableValues = [[NSDictionary alloc]initWithObjects:
                               [[NSArray alloc]initWithObjects:
                                [NSNumber numberWithDouble:10.5], 
                                [NSNumber numberWithDouble:2.0], 
                                [NSNumber numberWithDouble:5.3], 
                                nil] 
                                                           forKeys:
                               [[NSArray alloc]initWithObjects:
                                @"x", 
                                @"a", 
                                @"b", 
                                nil]];
    
    [self updateDisplay];
}

- (IBAction)test2Pressed {
    self.testVariableValues = [[NSDictionary alloc]initWithObjects:
                               [[NSArray alloc]initWithObjects:
                                [NSNumber numberWithDouble:8.4],  
                                [NSNumber numberWithDouble:3.0], 
                                nil] 
                                                           forKeys:
                               [[NSArray alloc]initWithObjects:
                                @"x",  
                                @"b", 
                                nil]];
    
    [self updateDisplay];
}

- (IBAction)test3Pressed {
    self.testVariableValues = nil;
    
    [self updateDisplay];
}

#pragma mark - Methods (private)

- (void)appendDigitToDisplay:(NSString *)digitAsString {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [self.display.text stringByAppendingString:digitAsString];
    } else {
        self.display.text = digitAsString;
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
}

- (void)updateDisplay {
    double result = [CalculatorBrain runProgram:self.brain.program usingVariableValues:self.testVariableValues];
    
    self.display.text = [NSString stringWithFormat:@"%g", result];
    
    self.historyDisplay.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
    
    NSString *variablesString = @"";
    
    NSArray *variables = [[CalculatorBrain variablesUsedInProgram:self.brain.program] allObjects];
    
    for (int i=0; i<[variables count]; i++) {
        NSString *variableName = [variables objectAtIndex:i];
        
        NSNumber *variableNumber = [self.testVariableValues objectForKey:variableName];
        
        if (!variableNumber) {
            variableNumber = [NSNumber numberWithDouble:0];
        }
        
        variablesString = [variablesString stringByAppendingFormat:@"%@=%@ ", variableName, variableNumber];
    }
    
    self.variablesDisplay.text = variablesString;
}

- (void)viewDidUnload {
    [self setHistoryDisplay:nil];
    [self setVariablesDisplay:nil];
    [self setDisplay:nil];
    [super viewDidUnload];
}
@end
