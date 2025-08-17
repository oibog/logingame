#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface cylight : NSObject
@end

@implementation cylight

static NSString *const kSavedUsernameKey = @"savedUsername";
static NSString *const kSavedPasswordKey = @"savedPassword";

+ (void)load {
    %init;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self checkSavedCredentials];
    });
}

+ (void)checkSavedCredentials {
    NSString *savedUsername = [[NSUserDefaults standardUserDefaults] objectForKey:kSavedUsernameKey];
    NSString *savedPassword = [[NSUserDefaults standardUserDefaults] objectForKey:kSavedPasswordKey];

    if (savedUsername && savedPassword) {
        [self loginWithUsername:savedUsername password:savedPassword];
    } else {
        [self presentLoginAlert];
    }
}

+ (void)presentLoginAlert {
    UIAlertController *loginAlert = [UIAlertController alertControllerWithTitle:@"Đăng Nhập Game" message:@"Vui lòng đăng nhập" preferredStyle:UIAlertControllerStyleAlert];

    [loginAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Username";
    }];

    [loginAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Password";
        textField.secureTextEntry = YES;
    }];

    UIAlertAction *loginAction = [UIAlertAction actionWithTitle:@"Login" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *usernameField = loginAlert.textFields.firstObject;
        UITextField *passwordField = loginAlert.textFields.lastObject;

        NSString *username = usernameField.text;
        NSString *password = passwordField.text;

        [self loginWithUsername:username password:password];
    }];

    [loginAlert addAction:loginAction];

    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootViewController presentViewController:loginAlert animated:YES completion:nil];
}

+ (void)loginWithUsername:(NSString *)username password:(NSString *)password {
    if ([username isEqualToString:@"cylightteamapi"] && [password isEqualToString:@"1234"]) {
        // Save credentials only if login is successful
        [[NSUserDefaults standardUserDefaults] setObject:username forKey:kSavedUsernameKey];
        [[NSUserDefaults standardUserDefaults] setObject:password forKey:kSavedPasswordKey];
        [[NSUserDefaults standardUserDefaults] synchronize];

        [self showAlertWithTitle:@"Login Successful" message:@"Welcome back!" shouldExit:NO];
    } else {
        [self showAlertWithTitle:@"Login Failed" message:@"Invalid username or password. Please try again." shouldExit:YES];

        // Clear saved credentials if login fails
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSavedUsernameKey];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSavedPasswordKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message shouldExit:(BOOL)shouldExit {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];

    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootViewController presentViewController:alert animated:YES completion:nil];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alert dismissViewControllerAnimated:YES completion:^{
            if (shouldExit) {
                exit(0);
            }
        }];
    });
}

@end
