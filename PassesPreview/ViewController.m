//
//  ViewController.m
//  PassesPreview
//
//  Created by Matthew Burke on 10/4/12.
//  Modified on 3 January 2013.
//
//  Copyright (c) 2012, 2013 Matthew M. Burke. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software to deal in the Software without
// restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
// IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//
// Based on the FAQ for Ray Wenderlich's site (available at http://www.raywenderlich.com/faq), portions of this file should
// have the following copyright notice:
//
//  Copyright (c) 2012 Ray Wenderlich
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software to deal in the Software without
// restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
// IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
// Although I'm wondering if really that should be "Copyright (c) 2012 Marin Todorov" since I'm guessing the FAQ was written
// before Ray added additional tutorial writers to his site.
//
#import "ViewController.h"
#import <PassKit/PassKit.h>


static NSString *const PASS_SUFFIX = @".pkpass";


@interface ViewController () <PKAddPassesViewControllerDelegate>
@property (nonatomic, strong) NSArray *passes;

- (NSString *)passesDirectory;
- (void)updatePasses;
- (void)openPassWithName:(NSString *)name;
@end



@implementation ViewController

#pragma mark - View Lifecycle and Memory Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(updatePasses) forControlEvents:UIControlEventValueChanged];
    
    if (![PKPassLibrary isPassLibraryAvailable]) {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"PassKit not available"
                                   delegate:nil
                          cancelButtonTitle:@"Pity"
                          otherButtonTitles:nil] show];
        return;
    }

    [self updatePasses];
    
    if (1 == [self.passes count]) {
        [self openPassWithName:self.passes[0]];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.passes = nil;
}


#pragma mark - PkAddPassesViewControllerDelegate Methods


- (void)addPassesViewControllerDidFinish:(PKAddPassesViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UITableViewDataSource, UITableViewDelegate Methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.passes count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    NSString *object = self.passes[indexPath.row];
    cell.textLabel.text = object;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *passName = self.passes[indexPath.row];
    [self openPassWithName:passName];
}


#pragma mark - Pass Methods


- (NSString *)passesDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return paths[0];
    
}


- (void)updatePasses
{
    NSMutableArray *newPasses = [[NSMutableArray alloc] init];
    NSArray *passFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self passesDirectory] error:nil];
    
    for (NSString *passFile in passFiles) {
        if ([passFile hasSuffix:PASS_SUFFIX]) {
            [newPasses addObject:passFile];
        }
    }
    self.passes = newPasses;
    [self.tableView reloadData];
    
    [self.refreshControl endRefreshing];
}


- (void)openPassWithName:(NSString *)name
{
    NSString *passFile = [[self passesDirectory] stringByAppendingPathComponent:name];
    NSData *passData = [NSData dataWithContentsOfFile:passFile];
    NSError *error = nil;
    PKPass *newPass = [[PKPass alloc] initWithData:passData error:&error];
    
    if (error != nil) {
        [[[UIAlertView alloc] initWithTitle:@"Passes Error"
                                    message:[error localizedDescription]
                                   delegate:nil
                          cancelButtonTitle:@"Oops"
                          otherButtonTitles:nil] show];
        return;
    }
    
    PKAddPassesViewController *addController = [[PKAddPassesViewController alloc] initWithPass:newPass];
    addController.delegate = self;
    [self presentViewController:addController animated:YES completion:nil];
}



@end
