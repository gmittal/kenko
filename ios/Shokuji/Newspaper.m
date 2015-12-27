//
//  Newspaper.m
//  Shokuji
//
//  Created by Kevin Frans on 9/5/15.
//  Copyright © 2015 Kevin Frans. All rights reserved.
//

#import "Newspaper.h"
#import "News.h"

@interface Newspaper ()

@end

@implementation Newspaper
{
    NSString* sjson;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void) giveJson:(NSString *)json
{
    NSLog(@" stting %@",json);
    sjson = json;
    [self load];
}

-(void) viewDidAppear:(BOOL)animated
{
//    [self load];
}

-(void) load
{
    NSLog(@"SJASON %@",sjson);
    
    NSData *tdata = [sjson dataUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@" tdata %@",tdata);
    
    NSArray* parse = [NSJSONSerialization JSONObjectWithData:tdata options:0 error:nil];
    NSLog(@" array : %@",parse);
    
//    [parse objectAtIndex:0];

    UIScrollView* scroll = [[UIScrollView alloc] initWithFrame:self.view.frame];
    scroll.pagingEnabled = YES;
    scroll.contentSize = CGSizeMake(self.view.frame.size.width * [parse count], self.view.frame.size.height);
    [self.view addSubview:scroll];
    
    for(int i = 0; i < [parse count]; i++)
    {
        News* n = [[News alloc] init];
        [scroll addSubview:n.view];
        n.view.frame = CGRectMake(n.view.frame.size.width*i, 0, n.view.frame.size.width, n.view.frame.size.height);
        [n setupJson:[parse objectAtIndex:i]];
    }
    
    UIButton* chevron = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 50, 50)];
    //    chevron.backgroundColor = [UIColor blueColor];
    [chevron setImage:[UIImage imageNamed:@"chevron-left.png"] forState:UIControlStateNormal];
    //    chevron.imageView.image = [UIImage imageNamed:@"chevron-left.png"];
    [scroll addSubview:chevron];
    [chevron addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) close
{
   [self dismissViewControllerAnimated:NO completion:^{}];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
