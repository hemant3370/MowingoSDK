//
//  AccountViewController.m
//
// Author:   Ranjan Patra
// Created:  17/6/2015
// Summary:
// Copyright (c) 2015 Mowingo. All rights reserved.
//
// Changes:
//

#import "AccountViewController.h"

#define ENGLISH_LANGUAGE @"English"
#define SPANISH_LANGUAGE @"Spanish"
#define FRENCH_LANGUAGE @"French"


@interface AccountViewController ()

@end

@implementation AccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // add save button
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.editButtonItem.title = @"Save";
    
    // add activity indicator
    activity.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    [self.view addSubview:activity];
    
    // retreive userdata
    [MWGSDKManager MWGGetUserDataWithCompletionBlock:^(MWGUserData *userData, NSError *result) {
        
        if (result)
        {
            switch (result.code)
            {
                case MWG_SUCCESS:
                {
                    // successful
                    NSLog(@"Sucessfull");
                    
                    user = userData;
                    [self renderUI];
                }
                    break;
                case MWG_SDK_CALL_ERROR:
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
        
        // stop activity indicator
        if (activity && [activity isAnimating])
        {
            [activity stopAnimating];
        }
        
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // set header title
    self.navigationItem.title = @"Account";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) renderUI
{
    if (user)
    {
        // show account table
        [self.tableView reloadData];
    }
}

#pragma mark - table view delegate

/**
 *  Tells the delegate the table view is about to draw a cell for a particular row.
 *
 *  @param tableView The table-view object informing the delegate of this impending event.
 *  @param cell      A table-view cell object that tableView is going to use when drawing the row.
 *  @param indexPath An index path locating the row in tableView.
 */
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        // set details of master cell
        [self renderTextfeildsInCell:cell.contentView];
    }
    else if (indexPath.section == 1)
    {
        // set preference switch according to their values
        [self renderPreferencesAtIndex:(int)indexPath.row
                               andCell:cell.contentView];
    }
    else if (indexPath.section == 2)
    {
        // set message preference switch according to their values
        [self renderMessagePreferencesAtIndex:(int)indexPath.row
                                      andCell:cell.contentView];
    }
    else if (indexPath.section == 3)
    {
        [self renderLanguageInCell:cell.contentView];
    }
}

/**
 *  fill textfeilds with data according to cell
 *
 *  @param cell master cell
 */
- (void)renderTextfeildsInCell :(UIView *)cell
{
    // first name
    UITextField *txtFirstName = (UITextField *)[cell viewWithTag:100];
    txtFirstName.text = user.firstName ? user.firstName : @"";
    
    //last name
    UITextField *txtLastName = (UITextField *)[cell viewWithTag:101];
    txtLastName.text = user.familyname ? user.familyname : @"";
    
    // dob
    UITextField *txtDOB = (UITextField *)[cell viewWithTag:102];
    txtDOB.text = [self getDOB];
    txtDOB.inputView = datepicker; // date picker for dob
    
    //gender
    UITextField *txtGender = (UITextField *)[cell viewWithTag:103];
    txtGender.text = [self getuserGender];
    
    //email
    UITextField *txtEmail = (UITextField *)[cell viewWithTag:104];
    txtEmail.text = user.userEmail ? user.userEmail : @"";
    
    //zip
    UITextField *txtZip = (UITextField *)[cell viewWithTag:105];
    txtZip.text = user.zip ? user.zip : @"";
    
    //phone
    UITextField *txtPhone = (UITextField *)[cell viewWithTag:106];
    txtPhone.text = user.phoneNumber ? user.phoneNumber : @"";
    txtPhone.inputAccessoryView = toolbarPhone; // toolbar with done button for phone textfeild's keyboard
}

/**
 *  renders preference values in given cell for given index
 *
 *  @param index preference index
 *  @param cell  cell
 */
- (void) renderPreferencesAtIndex:(int)index
                          andCell:(UIView *)cell
{
    if (user)
    {
        // get switch
        UISwitch *switchView = (UISwitch *)[cell viewWithTag:200 + index];
        
        // get preference flag
        BOOL preferenceFlag = [user.productPreferences[31 - index] intValue];
        
        // set switch preference value
        [switchView setOn:preferenceFlag animated:YES];
    }
}


/**
 *  renders preference values in given cell for given index
 *
 *  @param index preference index
 *  @param cell  cell
 */
- (void) renderMessagePreferencesAtIndex:(int)index
                                 andCell:(UIView *)cell
{
    if (user)
    {
        // get switch
        UISwitch *switchView = (UISwitch *)[cell viewWithTag:300 + index];
        
        // get preference flag
        BOOL preferenceFlag = [user.messagePreferences[31 - index] intValue];
        
        // set switch preference value
        [switchView setOn:preferenceFlag animated:YES];
    }
}

/**
 *  render language value in given language cell
 *
 *  @param cell language cell
 */
- (void) renderLanguageInCell:(UIView *)cell
{
    UITextField *txtLanguage = (UITextField *)[cell viewWithTag:400];
    txtLanguage.text = [self getUserlanguage];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - action methods

// action fro save button
- (void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    if (user)
    {
        [self.view endEditing:YES];
        
        // stop activity indicator
        if (activity && ![activity isAnimating])
        {
            [activity startAnimating];
        }
        
        // call set userdata api
        [MWGSDKManager MWGSetUserData:user
                  withCompletionBlock:^(NSError *result) {
                      
                      if (result)
                      {
                          switch (result.code)
                          {
                              case MWG_SUCCESS:
                              {
                                  // successful
                                  NSLog(@"Sucessfull");
                              }
                                  break;
                              case MWG_SDK_CALL_ERROR:
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
                      
                      // stop activity indicator
                      if (activity && [activity isAnimating])
                      {
                          [activity stopAnimating];
                      }
                      
                  }];
    }
    
}

/**
 *  called when any preference switch is taped by user
 *
 *  @param sender switch tapped
 */
- (IBAction) switch_onValueChanged:(UISwitch *)sender
{
    // get current switch index
    int index = (int)sender.tag - 200;
    
    // set product prefernce for the tapped switch
    user.productPreferences[31 - index] = [NSNumber numberWithBool:sender.isOn];
}

/**
 *  called when any message preference switch is taped by user
 *
 *  @param sender switch tapped
 */
- (IBAction) switchMsgPref_onValueChanged:(UISwitch *)sender
{
    // get current switch index
    int index = (int)sender.tag - 300;
    
    // set message prefernce for the tapped switch
    user.messagePreferences[31 - index] = [NSNumber numberWithBool:sender.isOn];
}

/**
 *  Called when phone textfeild keyboard's toolbar done button is tapped
 *
 *  @param sender done button instance
 */
- (IBAction)btnDone_onClick:(id)sender
{
    // get master cell content view
    UIView *cell = [self getContentViewDetailCell];
    
    // unfocus phone textfeild
    [[cell viewWithTag:106] resignFirstResponder];
}

/**
 *  called when a value is selected in date picker
 *
 *  @param sender date picker instance
 */
- (IBAction)datapicker_valueChanged:(UIDatePicker *)sender
{
    // get master cell content view
    UIView *cell = [self getContentViewDetailCell];
    
    // unfocus dob textfeild and email textfeild
    [[cell viewWithTag:102] resignFirstResponder];
    [[cell viewWithTag:103] becomeFirstResponder];
    
    // set dob of userdata
    user.dob = sender.date;
    
    // set new dob
    ((UITextField *)[cell viewWithTag:102]).text = [self getDOB];
}


#pragma mark - textfeild delegate

/**
 *  Tells the delegate that editing began for the specified text field.
 *
 *  @param textField The text field for which an editing session began.
 */
- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField.tag == 400)
    {
        [[self getLanguageSelector] showInView:self.view];
        return NO;
    }
    else if (textField.tag == 103)
    {
        [[self getGenderSelector] showInView:self.view];
        return NO;
    }
    
    return YES;
}

/**
 *  Asks the delegate if the text field should process the pressing of the return button.
 *
 *  @param textField The text field whose return button was pressed.
 *
 *  @return YES if the text field should implement its default behavior for the return button; otherwise, NO.
 */
- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    // unfocus current textfeild
    [textField resignFirstResponder];
    
    // get next textfeild tag
    int tag = (int)textField.tag;
    
    // get cell instance
    UIView *cell = [self getContentViewDetailCell];
    
    // focus next textfeild
    [[cell viewWithTag:tag+1] becomeFirstResponder];
    
    return YES;
}

/**
 *  may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
 *
 *  @param textField textfeild
 */
-(void) textFieldDidEndEditing:(UITextField *)textField
{
    // set userdata object with the values od textfeild
    [self setDataFromTextFeild:textField];
}


#pragma mark - logics

/**
 *  Method to dsplay gender selector
 */
- (UIActionSheet *) getGenderSelector
{
    if (!genderActionSheet)
    {
        genderActionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Gender"
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:@"Male", @"Female", nil];
    }
    
    return genderActionSheet;
}


/**
 *  Method to dsplay language selector
 */
- (UIActionSheet *) getLanguageSelector
{
    if (!languageActionSheet)
    {
        languageActionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Preferred Language"
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:@"English", @"Spanish", @"French", nil];
    }
    
    return languageActionSheet;
}

/**
 *  retreives dta from textfeild and set to userdata
 *
 *  @param textfeild textfeild
 */
- (void) setDataFromTextFeild:(UITextField *)textfeild
{
    // check current textfeild tag
    switch (textfeild.tag)
    {
        case 100:
            // if textfeild is for first name
            user.firstName = textfeild.text;
            break;
        case 101:
            // if textfeild is for family name
            user.familyname = textfeild.text;
            break;
        case 104:
            // if textfeild is for email
            user.userEmail = textfeild.text;
            break;
        case 105:
            // if textfeild is for zip
            user.zip = textfeild.text;
            break;
        case 106:
            // if textfeild is for phone
            user.phoneNumber = textfeild.text;
            break;
            
        default:
            break;
    }
}

/**
 *  retrieve instance of mastercell content view
 *
 *  @return mastercell content view
 */
-(UIView *) getContentViewDetailCell
{
    // get master cell
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    return cell.contentView; // return cell content view
}

/**
 *  retrieve instance of language cell content view
 *
 *  @return language content view
 */
-(UIView *) getContentViewLanguageCell
{
    // get language cell
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
    return cell.contentView; // return cell content view
}

/**
 *  retrieve dob string
 *
 *  @return dob string
 */
- (NSString *) getDOB
{
    // check if dob is available
    if (user.dob)
    {
        // create date formatter
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        [formatter setDateFormat:@"M/d/yyyy"];
        
        // string for dob
        NSString *strDOB = [formatter stringFromDate:user.dob];
        
        return strDOB ? strDOB : @"";
    }
    
    return @"";
}

/**
 *  retruns gender of user
 */
- (NSString *) getuserGender
{
    if (user)
    {
        if (user.userGender == MALE)
        {
            // male
            return @"Male";
        }
        else if(user.userGender == FEMALE)
        {
            // female
            return @"Female";
        }
    }
    
    return @"";
}


/**
 *  returns users preferred language
 *
 *  @return user language
 */
- (NSString *) getUserlanguage
{
    if (user)
    {
        if ([user.userLanguage isEqualToString:@"sp"])
        {
            return SPANISH_LANGUAGE;
        }
        else if ([user.userLanguage isEqualToString:@"fr"])
        {
            return FRENCH_LANGUAGE;
        }
        else if ([user.userLanguage isEqualToString:@"en"])
        {
            return ENGLISH_LANGUAGE;
        }
    }
    
    return @"";
}

/**
 *  sets selected language
 *
 *  @param index index selected
 */
- (void) setSelectedLanguageAtIndex:(int)index
{
    NSString *strlanguage = @"";
    
    if (user)
    {
        if (index == 0)
        {
            // english
            user.userLanguage = @"en";
            strlanguage = @"English";
        }
        else if (index == 1)
        {
            // spanish
            user.userLanguage = @"sp";
            strlanguage = @"Spanish";
        }
        else if (index == 2)
        {
            // spanish
            user.userLanguage = @"fr";
            strlanguage = @"French";
        }
    }
    
    // set textfeild with language
    UIView *cell = [self getContentViewLanguageCell];
    UITextField *txt = (UITextField *)[cell viewWithTag:400];
    txt.text = strlanguage;
    [txt resignFirstResponder];
}

/**
 *  set selected language from given index
 *
 *  @param index index selected
 */
- (void) setSelectedGenderAtIndex:(int)index
{
    NSString *strGender = @"";
    
    if (user)
    {
        if (index == 0)
        {
            //male
            user.userGender = MALE;
            strGender = @"Male";
        }
        else if (index == 1)
        {
            //female
            user.userGender = FEMALE;
            strGender = @"Female";
        }
    }
    
    UIView *cell = [self getContentViewDetailCell];
    UITextField *txt = (UITextField *)[cell viewWithTag:103];
    txt.text = strGender;
    [txt resignFirstResponder];
    [((UITextField *)[cell viewWithTag:104]) becomeFirstResponder];
}


#pragma mark - ACTION SHEET

/**
 *  Sent to the delegate when the user clicks a button on an action sheet.
 *
 *  @param actionSheet The action sheet containing the button.
 *  @param buttonIndex The position of the clicked button. The button indices start at 0.
 */
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex)
    {
        if (actionSheet == languageActionSheet)
        {
            // gender action sheet
            [self setSelectedLanguageAtIndex:buttonIndex];
            
        }
        else if (actionSheet == genderActionSheet)
        {
            // language action sheet
            [self setSelectedGenderAtIndex:buttonIndex];
        }
    }
}


@end
