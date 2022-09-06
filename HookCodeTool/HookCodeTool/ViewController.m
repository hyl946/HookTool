//
//  ViewController.m
//  HookCodeTool
//
//  Created by Loren on 2018/1/3.
//  Copyright © 2018年 Loren. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<NSTextViewDelegate>
@property (unsafe_unretained) IBOutlet NSTextView *classTextView;
@property (unsafe_unretained) IBOutlet NSTextView *textView1;
@property (unsafe_unretained) IBOutlet NSTextView *textView2;
@property (weak) IBOutlet NSButton *change;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textView1.delegate = self;
//    self.textView1.string = @"+ (_Bool)verifierAuthResult:(id)arg1 openId:(id *)arg2 authCode:(id *)arg3;";
//    self.classTextView.string = @"NSString";
}
//- (_Bool)verifierAuthResult:(id)arg1 openId:(id *)arg2 authCode:(id *)arg3;


- (IBAction)changeAction:(id)sender {
    NSString * classString = self.classTextView.string;
    NSString * funsString = self.textView1.string;
    NSArray * funsArray = [funsString componentsSeparatedByString:@"\n"];
    NSInteger funsCount = funsArray.count;
    NSMutableArray * dataSource = [NSMutableArray array];
    for (int m = 0; m<funsCount; m++) {
        NSString * funString = [funsArray objectAtIndex:m];
        NSMutableString * s0 = [NSMutableString stringWithFormat:@"%@",funString];
        [s0 deleteCharactersInRange:NSMakeRange(funString.length - 1, 1)];;
        NSString * s1 = s0;
        BOOL isClass = ![[s1 substringToIndex:1] isEqualToString:@"-"];
        NSMutableArray * ma = [NSMutableArray array];
        NSString * returnstring = @"";
        NSArray * array = [s1 componentsSeparatedByString:@":"];
        for (int i = 0; i<array.count; i++) {
            NSString * t = array[i];
            int cs = 0;//类型开始
            int ce = 0;//类型结束
            
            for (int a=0; a<t.length; a++) {
                NSString * ts = [t substringWithRange:NSMakeRange(a, 1)];
                NSString * tss;
                if (a>0) tss = [t substringWithRange:NSMakeRange(a-1, 1)];
                if([ts isEqualToString:@"("]){
                    NSLog(@"类型检测开始");
                    cs = a+1;
                }
                else if ([ts isEqualToString:@")"]){
                    NSLog(@"类型检测结束");
                    ce = a;
                }
            }
            NSString * ffs = [t substringWithRange:NSMakeRange(ce+1, t.length-ce-1)];
            NSArray * array2 = [ffs componentsSeparatedByString:@" "];
            //类型
            NSString * c = [t substringWithRange:NSMakeRange(cs, ce-cs)] ;
            NSLog(@"类型 - %@",c);
            
            if (i>0){
                [ma addObject:c];
            }
            else{
                returnstring = c;
            }
            for (int a= 0; a<array2.count; a++) {
                [ma addObject:array2[a]];
            }
        }
        NSLog(@"%@是类方法",isClass?@"":@"不");
        NSLog(@"返回值类型%@",returnstring);
        NSLog(@"%@",ma);
        [dataSource addObject:@{@"isClass":@(isClass),
                                @"returnstring":returnstring,
                                @"ma":ma
                                }];
    }
    
    
    NSMutableString * dec = [NSMutableString stringWithString:@"CHDeclareClass("];
    [dec appendString:classString];
    [dec appendString:@")"];
    
    NSMutableString * chs = [NSMutableString string];
    
    NSMutableString * cons = [NSMutableString stringWithFormat:@"CHConstructor{\n\tCHLoadLateClass(%@);\n",classString];

    for (int n = 0 ; n<dataSource.count; n++) {
        NSDictionary * data = [dataSource objectAtIndex:n];
        NSArray * ma = data[@"ma"];
        NSInteger count = ma.count/3;
        BOOL isClass = [data[@"isClass"] boolValue];
        NSString * returnstring = data[@"returnstring"];
        
        NSMutableString * tchs = [NSMutableString stringWithFormat:@"CH%@Method%ld(%@,%@",isClass?@"Class":@"",count,[self replace:returnstring],classString];;
        NSMutableString * sus = [NSMutableString stringWithFormat:@"%@CHSuper%ld(%@",![returnstring isEqualToString:@"void"]?[NSString stringWithFormat:@"%@ i = ",[self replace:returnstring]]:@"",count,classString];
        NSMutableString * tempCons = [NSMutableString stringWithString:[NSString stringWithFormat:@"\tCH%@Hook%ld(%@",isClass?@"Class":@"",count,classString]];
        for (int a=0; a<ma.count; a++) {
            NSString * s = ma[a];
            [tchs appendString:@", "];
            int c = a%3;
            if(c == 1){
                [tchs appendString:[self replace:s]];
            }
            else{
                [tchs appendString:s];
            }
            if (c != 1) {
                [sus appendString:@", "];
                [sus appendString:s];
            }
            if (c == 0) {
                [tempCons appendString:@", "];
                [tempCons appendString:s];
            }
        }
        [sus appendString:@");"];
        if (![returnstring isEqualToString:@"void"]) {
            [sus appendString:@"\n\treturn i;"];
        }
        [tchs appendString:@"){\n\t"];
        [tchs appendString:sus];
        [tchs appendString:@"\n}\n"];
        [tempCons appendString:@");"];
        [cons appendString:tempCons];
        [cons appendString:@"\n"];
        [chs appendString:tchs];
    }
    [cons appendString:@"}"];
    
    NSLog(@"%@",dec);
    NSLog(@"%@",chs);
    NSLog(@"%@",cons);
    self.textView2.string = [NSString stringWithFormat:@"%@\n%@\n%@\n",dec,chs,cons];
    
    
}
- (NSString *)replace:(NSString *)string{
    if ([string isEqualToString:@"_Bool"]) {
        return @"BOOL";
    }
    else if ([string isEqualToString:@"CDUnknownBlockType"]){
        return @"id";
    }
    return string;
}
#pragma mark - delegate
- (void)textViewDidChangeSelection:(NSNotification *)notification{
    
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
