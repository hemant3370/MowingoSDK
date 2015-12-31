//
//  StoresViewController.m
//  SDK_Sample_App
//
//  Created by Bellurbis on 6/23/15.
//  Copyright (c) 2015 Mowingo. All rights reserved.
//

#import "StoresViewController.h"
#import "StoreTableViewCell.h"

@interface StoresViewController ()

@end

@implementation StoresViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self retreiveStoreForSearch:nil andMaxStores:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // set header title
    self.navigationItem.title = @"Stores";
    
//    self.edgesForExtendedLayout = UIRectEdgeNone;
//    self.extendedLayoutIncludesOpaqueBars = NO;
//    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - table view delegate


//Asks the data source to return the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//Tells the data source to return the number of rows in a given section of a table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return stores.count;
}

//Asks the delegate for the height to use for the footer of a particular section.
-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1.0;
}

//Asks the delegate for the height to use for a row in a specified location.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 236.0;
}

//Asks the data source for a cell to insert in a particular location of the table view.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"storeCell";
    
    StoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    return cell;
}

//Tells the delegate the table view is about to draw a cell for a particular row.
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    StoreTableViewCell *storeCell = (StoreTableViewCell *)cell;
    
    [storeCell renderCellForStore:stores[indexPath.row]];
}

/**
 *  Tells the delegate that the specified row is now selected.
 *
 *  @param tableView A table-view object informing the delegate about the new row selection.
 *  @param indexPath An index path locating the new selected row in tableView.
 */
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - store list

- (void) retreiveStoreForSearch:(NSString *)searchString andMaxStores:(NSNumber *)max
{
    //start progress
    if (activity && ![activity isAnimating])
    {
        [activity startAnimating];
    }
    
    [MWGSDKManager MWGGetStoresWithSearchString:searchString
                                      maxStores:max
                                completionBlock:^(NSArray *storesArray, NSError *result) {
                                    
                                    if (result)
                                    {
                                        switch (result.code)
                                        {
                                            case MWG_SUCCESS:
                                            {
                                                // successful
                                                stores = storesArray;
                                                
                                                [tblStores reloadData];//load table with array data
                                                tblStores.hidden = NO;// display list
                                                
                                                if (stores && [stores count] > 0)
                                                {
                                                    
                                                }
                                                else
                                                {
                                                    [[[UIAlertView alloc] initWithTitle:@""
                                                                                message:@"No Stores were found."
                                                                               delegate:nil
                                                                      cancelButtonTitle:@"OK"
                                                                      otherButtonTitles:nil] show];
                                                }
                                            }
                                                break;
                                            case MWG_SDK_CALL_ERROR:
                                            {
                                                NSLog(@"Init Error message  ---->  code : %ld\n description : %@\n reason : %@\n recovery : %@",(long)result.code, [result localizedDescription], [result localizedFailureReason], [result localizedRecoverySuggestion]);
                                            }
                                                break;
                                            case MWG_NETWORK_ERROR:
                                            {
                                                NSLog(@"Init Error message  ---->  code : %ld\n description : %@\n reason : %@\n recovery : %@",(long)result.code, [result localizedDescription], [result localizedFailureReason], [result localizedRecoverySuggestion]);
                                            }
                                                break;
                                            case MWG_AUTH_ERROR:
                                            {
                                                NSLog(@"Init Error message  ---->  code : %ld\n description : %@\n reason : %@\n recovery : %@",(long)result.code, [result localizedDescription], [result localizedFailureReason], [result localizedRecoverySuggestion]);
                                            }
                                                break;
                                            default:
                                            {
                                                NSLog(@"Init Error message  ---->  code : %ld\n description : %@\n reason : %@\n recovery : %@",(long)result.code, [result localizedDescription], [result localizedFailureReason], [result localizedRecoverySuggestion]);
                                            }
                                                break;
                                        }
                                    }
                                    else
                                    {
                                        NSLog(@"Some error occurred");
                                    }
                                    
                                    //stop progress
                                    if (activity && [activity isAnimating])
                                    {
                                        [activity stopAnimating];
                                    }
                                    
                                }];
}


@end
