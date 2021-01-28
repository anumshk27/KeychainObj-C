//
//  ViewController.m
//  Keychain
//
//  Created by Haider Shahzad on 27/01/2021.
//

#import "ViewController.h"


@import Security;

@interface ViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField * username;
@property (nonatomic, weak) IBOutlet UITextField * password;
@property (nonatomic, weak) IBOutlet UITextView * textView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _username.delegate = self;
    _password.delegate = self;
    
}

#pragma mark -
#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [_username resignFirstResponder];
    [_password resignFirstResponder];
    return true;
}

#pragma mark -
#pragma mark - IB Actions
static NSString * identifer = @"com.appdomain.servicename";

-(IBAction)save:(id)sender {
    
    if (!([_username.text isEqualToString:@""] && [_password.text isEqualToString:@""])) {
        [self createKeychainUsername:self.username.text
                        withPassword:self.password.text
                       forIdentifier:identifer];
        
        self.textView.textColor = [UIColor greenColor];
        self.textView.text = @"Username and password is saved in Keychain";


    }else {
        self.textView.textColor = [UIColor redColor];
        self.textView.text = @"Username and password is empty";
    }
}


-(IBAction)get:(id)sender {
    [self getKeychainForIdentifier:identifer];
}


-(IBAction)clear:(id)sender {
    [self deleteKeychainForIdentifier:identifer];
    self.textView.text = @"";
    self.textView.textColor = [UIColor blackColor];
}


#pragma mark -
#pragma mark - Keychain Implementation
-(void)createKeychainUsername:(NSString*)user withPassword:(NSString*)pass forIdentifier:(NSString*)identifier {
    
    // Create dictionary of search parameters
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)(kSecClassInternetPassword),  kSecClass, identifier, kSecAttrServer, kCFBooleanTrue, kSecReturnAttributes, nil];
    
    // Remove any old values from the keychain
    OSStatus err = SecItemDelete((__bridge CFDictionaryRef) dict);
    NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil];
    if (error)NSLog(@"%@", error.localizedDescription);
    
    // Create dictionary of parameters to add
    NSData* passwordData = [pass dataUsingEncoding:NSUTF8StringEncoding];
    dict = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)(kSecClassInternetPassword), kSecClass, identifier, kSecAttrServer, passwordData, kSecValueData, user, kSecAttrAccount, nil];
    
    // Try to save to keychain
    err = SecItemAdd((__bridge CFDictionaryRef) dict, NULL);
}


-(void) getKeychainForIdentifier:(NSString*)identifier {
    
    // Create dictionary of search parameters
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)(kSecClassInternetPassword),  kSecClass, identifier, kSecAttrServer, kCFBooleanTrue, kSecReturnAttributes, kCFBooleanTrue, kSecReturnData, nil];
    
    // Look up server in the keychain
    NSDictionary* found = nil;
    CFDictionaryRef foundCF;
    OSStatus err = SecItemCopyMatching((__bridge CFDictionaryRef) dict, (CFTypeRef*)&foundCF);
    
    NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil];
    if (error) NSLog(@"%@", error.localizedDescription);
    
    found = (__bridge NSDictionary*)(foundCF);
    if (!found) return;
    
    // Found
    NSString* user = (NSString*) [found objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString* pass = [[NSString alloc] initWithData:[found objectForKey:(__bridge id)(kSecValueData)] encoding:NSUTF8StringEncoding];
    //NSLog(@"User Name :>>%@ and password %@",user,pass);

    self.textView.text = [NSString stringWithFormat:@"Username %@\n Password %@", user, pass];
    
}


-(BOOL) deleteKeychainForIdentifier:(NSString*)identifier {
    
    // Create dictionary of search parameters
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)(kSecClassInternetPassword),  kSecClass, identifier, kSecAttrServer, kCFBooleanTrue, kSecReturnAttributes, kCFBooleanTrue, kSecReturnData, nil];
    
    // Remove any old values from the keychain
    OSStatus err = SecItemDelete((__bridge CFDictionaryRef) dict);
    
    if (err == errSecSuccess) {
        return YES;
    }
    
    NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil];
    if (error)NSLog(@"%@", error.localizedDescription);
    
    return NO;
}

@end
