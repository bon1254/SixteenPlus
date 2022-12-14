//
//  LCGoogleSignIn.m
//  LCUnityiOSPlugins
//
//  Created by Sourabh Verma on 14/06/17.
//  Copyright © 2017 Sourabh Verma. All rights reserved.
//

#import "LCGoogleSignIn.h"
#import <GoogleSignIn/GoogleSignIn.h>

#import "UnityInterface.h"

static NSString *kTrue = @"true";
static NSString *kFalse = @"false";

static LCGoogleSignIn *_instance = [LCGoogleSignIn sharedInstance];
static GIDGoogleUser *googleUserObj = nil;
static bool logEnabled = false;
static bool devLogEnabled = false;
static NSString *_clientID = nil;
static NSString *_webClientID = nil;
//OLDV1: static NSArray *_defaultScopes = [GIDSignIn sharedInstance].scopes;
static NSArray *_defaultScopes = [NSMutableArray array];

static char* StringCopyAdvSend (NSString* norString)
{
    if (norString == NULL)
        return NULL;
    
    const char *string  = [norString UTF8String];
    char* res = (char*)malloc(strlen(string) + 1);
    strcpy(res, string);
    return res;
}

static char* StringCopyForSend (const char* string)
{
    if (string == NULL)
        return NULL;
    
    char* res = (char*)malloc(strlen(string) + 1);
    strcpy(res, string);
    return res;
}

/// Returns a C string from a C array of UTF8-encoded bytes.
static const char **StringArrayCopyForSend(NSArray *array) {
    if (array == nil || array.count == 0) {
        return nil;
    }
    
    const char **strArray = (const char **) calloc(array.count, sizeof(char *));
    for (int i = 0; i < array.count; i++) {
        strArray[i] = StringCopyForSend([array[i] UTF8String]);
    }
    return strArray;
}

// OLDV1: @interface LCGoogleSignIn () <GIDSignInDelegate>
@interface LCGoogleSignIn ()
{
    NSString *currentPlayerID;
}

@property(nonatomic, readwrite) bool isLoggedIn;

@property(nonatomic, readwrite) const char * gameObjectName;
@end


@implementation LCGoogleSignIn


+ (LCGoogleSignIn *)sharedInstance
{
    if(_instance == nil) {
        [self LogDevMessage:@"Initialize Start"];
        _instance = [[LCGoogleSignIn alloc] init];
        _instance.gameObjectName = [@"LCGoogleLoginBridge" UTF8String];
        [self LogMessage:@"Initialize Success"];
    }
    return _instance;
}


+(void)LogMessage:(NSString*)message{
    if(logEnabled){
        NSLog(@"GoogleSignIn iOS Native > %@", message);
    }
}

+(void)LogDevMessage:(NSString*)message{
    if(devLogEnabled){
        NSLog(@"GoogleSignIn Dev iOS Native > %@", message);
    }
}

- (id)init
{
    if(_instance != nil) {
        return _instance;
    }
    
    if ((self = [super init])) {
        _instance = self;
        UnityRegisterAppDelegateListener(self);
    }
    return self;
}

-(UIViewController*) mainVC {
    return UnityGetGLViewController();
}

- (void)onOpenURL:(NSNotification*)notification{
    NSURL *url = notification.userInfo[@"url"];
    // NSString *sourceApplication = notification.userInfo[@"sourceApplication"];
    // NSString *annotation = notification.userInfo[@"annotation"];
    
    
    BOOL isHandledBySDK = [[GIDSignIn sharedInstance] handleURL:url];
    [LCGoogleSignIn LogDevMessage:[NSString stringWithFormat:@"LCGoogleSignIN: onOpenURL: %d", isHandledBySDK]];
}


//extern UIViewController* UnityGetGLViewController();

- (NSString*)findGoogleClientID{
    return _clientID;
    
    // Legacy code removed because file name could change now.
//    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"GoogleService-Info" ofType:@"plist"]];
//    NSString *clientID = [dictionary objectForKey:@"CLIENT_ID"];
//
//    if(clientID == nil || clientID.length == 0){
//        [LCGoogleSignIn LogMessage:[NSString stringWithFormat:@"Client ID being used > %@", clientID]];
//    } else{
//        [LCGoogleSignIn LogMessage:[NSString stringWithFormat:@"Client ID being used %@******%@",
//                                    [clientID substringToIndex:3], [clientID substringFromIndex:clientID.length - 4]]];
//    }
//    return clientID;
}

- (void)initilizeGoogleSignIn {
    
    // OLDV1: [GIDSignIn sharedInstance].clientID = [self findGoogleClientID];
    //[GIDSignIn sharedInstance].clientID = @"368078724074-ge710ii3qj0fgc627rhctv4nnaqoch54.apps.googleusercontent.com";
    // OLDV1: [GIDSignIn sharedInstance].delegate = self;
    // OLDV1: [GIDSignIn sharedInstance].presentingViewController = UnityGetGLViewController();
    
}

- (void)signIn:(GIDSignIn *)signIn presentViewController:(UIViewController *)viewController{
    [LCGoogleSignIn LogMessage:@"presentViewController"];
    UIViewController *rootViewController = UnityGetGLViewController();
    [rootViewController presentViewController:viewController animated:YES completion:^{
        //
    }];
}

-(void)signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController{
    [LCGoogleSignIn LogMessage:@"dismissViewController"];
    [viewController dismissViewControllerAnimated:true completion:^{
        //
    }];
}

// [START signin_handler]
//OLDV1
/*
- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    [LCGoogleSignIn LogMessage:[NSString stringWithFormat:@"didSignInForUser: Name:%@ Error: %@", user.profile.name, error]];
    if(error == nil){
        googleUserObj = user;
        
        if(user.userID != nil){
            _isLoggedIn = true;
            UnitySendMessage(_gameObjectName, [@"LCGoogleSignInSuccess" UTF8String], StringCopyForSend([kTrue UTF8String]));
        }
        else{
            _isLoggedIn = false;
            UnitySendMessage(_gameObjectName, [@"LCGoogleSignInFailed" UTF8String], StringCopyForSend([kTrue UTF8String]));
        }
    }
    else{
        UnitySendMessage(_gameObjectName, [@"LCGoogleSignInFailed" UTF8String], StringCopyForSend([kFalse UTF8String]));
    }
    
}
 */


// [END signin_handler]

// This callback is triggered after the disconnect call that revokes data
// access to the user's resources has completed.
// [START disconnect_handler]
- (void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error {
    [LCGoogleSignIn LogMessage:[NSString stringWithFormat:@"didDisconnectWithUser> %@", error]];
    //_isLoggedIn = false;
    
    //UnitySendMessage(_gameObjectName, [@"LCGoogleSignInDisconnected" UTF8String], StringCopyForSend([kTrue UTF8String]));
}

// [END disconnect_handler]

-(bool)userLogin:(bool)isSilent enableServerAuth:(bool)enableServerAuth forceCodeForeRefreshToken:(bool)forceCodeForeRefreshToken requestedScopes:(NSArray*) requestedScopes {
    [LCGoogleSignIn LogMessage:[NSString stringWithFormat:@"userLogin isSilent? %d enableServerAuth? %d forceCodeForeRefreshToken: %d requestedScopes: %lu", isSilent, enableServerAuth, forceCodeForeRefreshToken, (unsigned long)requestedScopes.count]];
    
    
    // OLDV1: Maybe we dont need serverClientID anymore
    GIDConfiguration *signInConfig = [[GIDConfiguration alloc] initWithClientID:[self findGoogleClientID] serverClientID:(enableServerAuth ? _webClientID : nil)];
    
    /*
    if(enableServerAuth){
        [LCGoogleSignIn LogMessage:[NSString stringWithFormat:@"Adding webclient ID for server auth: %lu", (unsigned long)_webClientID.length]];
        [GIDSignIn sharedInstance].serverClientID = _webClientID;
    } else{
        [GIDSignIn sharedInstance].serverClientID = nil;
    }
     */
//
//    OLDV1: Moves scopes
//    //Add Scopes
//    NSMutableArray *scopes = (_defaultScopes != nil) ? [_defaultScopes mutableCopy] : [NSMutableArray array];
//
//    if(requestedScopes != nil && requestedScopes.count > 0){
//        [LCGoogleSignIn LogMessage:@"Adding custom scopes"];
//        [scopes addObjectsFromArray:requestedScopes];
//    }
//    [GIDSignIn sharedInstance].scopes = scopes;
//
    
    //Perform silent or normal login
    if(isSilent){
        [LCGoogleSignIn LogMessage:@"Signing begins: Silent"];
        [GIDSignIn.sharedInstance restorePreviousSignInWithCallback:^(GIDGoogleUser * _Nullable user,
                                                                        NSError * _Nullable error) {
           
            if([self handleLoginCallback:user error:error]){
                // Refresh token for silent login
                [user.authentication doWithFreshTokens:^(GIDAuthentication * _Nullable authentication,
                                                         NSError * _Nullable error) {
                    if (error) { return; }
                    if (authentication == nil) { return; }

                    // TODO: See how to sue it and handle error
                    NSString *idToken = authentication.idToken;
                    // Send ID token to backend (example below).
                }];
            }
          }];
        
        //OLDV1: [[GIDSignIn sharedInstance] restorePreviousSignIn];
    }
    else{
        [LCGoogleSignIn LogMessage:@"Signing begins: Normal"];
        [GIDSignIn.sharedInstance signInWithConfiguration:signInConfig
                                 presentingViewController:UnityGetGLViewController()
                                                   
                                                 callback:^(GIDGoogleUser * _Nullable user,
                                                              NSError * _Nullable error) {
            

            
            if ([self handleLoginCallback:user error:error]) {
                // If sign in succeeded, display the app's main content View.
                
                [self requestAditionalScopes:requestedScopes];
            }
          }];
        
        //OLDV1: [[GIDSignIn sharedInstance] signIn];
    }
    return true;
}

-(bool)handleLoginCallback:(GIDGoogleUser* _Nullable)user error:(NSError* _Nullable)error {
    [LCGoogleSignIn LogMessage:[NSString stringWithFormat:@"didSignInForUser: Name:%@ Error: %@", user.profile.name, error]];
    
    if(error != nil){
        // Login Fail 1
        _isLoggedIn = false;
        UnitySendMessage(_gameObjectName, [@"LCGoogleSignInFailed" UTF8String], StringCopyForSend([kFalse UTF8String]));
        return false;
    }
    
    googleUserObj = user;
    if(user == nil || user.userID == nil){
        // Login Fail 2
        _isLoggedIn = false;
        UnitySendMessage(_gameObjectName, [@"LCGoogleSignInFailed" UTF8String], StringCopyForSend([kTrue UTF8String]));
        return false;
    }
    
    // Login Success
    _isLoggedIn = true;
    UnitySendMessage(_gameObjectName, [@"LCGoogleSignInSuccess" UTF8String], StringCopyForSend([kTrue UTF8String]));
    return true;
}

-(void)requestAditionalScopes:(NSArray*) requestedScopes {
    //Add Scopes
    
    if(requestedScopes == nil || requestedScopes.count == 0){
        [LCGoogleSignIn LogMessage:@"Custom scopes not required"];
        return;;
    }
    
    [LCGoogleSignIn LogMessage:@"Requesting custom scopes"];
    
    NSMutableArray *additionalScopes = (_defaultScopes != nil) ? [_defaultScopes mutableCopy] : [NSMutableArray array];
    [additionalScopes addObjectsFromArray:requestedScopes];

    // OLDV1: [GIDSignIn sharedInstance].scopes = additionalScopes;
    
    [GIDSignIn.sharedInstance addScopes:additionalScopes
               presentingViewController:UnityGetGLViewController()
                               callback:^(GIDGoogleUser * _Nullable user,
                                          NSError * _Nullable error) {
        if (error) {
            [LCGoogleSignIn LogMessage:[NSString stringWithFormat:@"Custom Scopes: Error1: Name:%@ Error: %@", user.profile.name, error]];
            return;
        }
        if (user == nil) {
            [LCGoogleSignIn LogMessage:@"Custom Scopes: Error2: No User"];
            return;
        }

        // Check if the user granted access to the scopes you requested.
        [LCGoogleSignIn LogMessage:@"Custom Scopes: Success"];
    }];
}

-(bool)userLogout {
    [LCGoogleSignIn LogMessage:@"userLogout: Initiated"];
    [GIDSignIn.sharedInstance disconnectWithCallback:^(NSError * _Nullable error) {
        if (error) { return; }
        
        _isLoggedIn = false;
        [LCGoogleSignIn LogMessage:@"userLogout: Success"];
        // Google Account disconnected from your app.
        // Perform clean-up actions, such as deleting data associated with the
        //   disconnected account.
    }];
    // OLDV1: [[GIDSignIn sharedInstance] signOut];
    return true;
}


extern "C" {
    static LCGoogleSignIn* sharedInstance(){
        return _instance;
    }
    
    void changeLogLevel(bool enabled){
        logEnabled = enabled;
    }
    
    void changeDevLogLevel(bool enabled){
        devLogEnabled = enabled;
    }
    
    void initiateWithClientID(const char* webClientID, const char* iOSClientID){
        _clientID = [[NSString alloc] initWithCString:iOSClientID encoding:NSUTF8StringEncoding];
        _webClientID = [[NSString alloc] initWithCString:webClientID encoding:NSUTF8StringEncoding];
        [sharedInstance() initilizeGoogleSignIn];
    }
    
    //http://answers.unity3d.com/questions/862219/pass-array-of-strings-to-ios-bridge.html
    bool userLogin(bool isSilent, bool enableServerAuth, bool forceCodeForeRefreshToken, const char* requestedScopes[], int noOfScopes) {
        //NSLog(@"userLogin 1");
        NSMutableArray *scopes = nil;
        if(requestedScopes != nil && noOfScopes > 0){
            //NSLog(@"userLogin 1.5: Size: %d", noOfScopes);
            scopes = [NSMutableArray array];
            for (int i = 0; i < noOfScopes; i++) {
                NSString* strObj = [[NSString alloc] initWithUTF8String:requestedScopes[i]];
                [scopes addObject:strObj];
            }
        }
        //NSLog(@"userLogin 2");
        return [sharedInstance() userLogin:isSilent enableServerAuth:enableServerAuth forceCodeForeRefreshToken:forceCodeForeRefreshToken requestedScopes:scopes];
    }
    
    bool userLogout(){
        return [sharedInstance() userLogout];
    }
    
    const char* userDisplayName(){
        if(googleUserObj == nil){
            return nil;
        }
        return StringCopyAdvSend([[googleUserObj profile] name]);
    }
    
    const char* userGivenName(){
        if(googleUserObj == nil){
            return nil;
        }
        return StringCopyAdvSend([[googleUserObj profile] givenName]);
    }
    
    const char* userFamilyName(){
        if(googleUserObj == nil){
            return nil;
        }
        return StringCopyAdvSend([[googleUserObj profile] familyName]);
    }
    
    
    const char* userEmail(){
        if(googleUserObj == nil){
            return nil;
        }
        return StringCopyAdvSend([[googleUserObj profile] email]);
    }
    
    const char* userAccessToken(){
        if(googleUserObj == nil){
            return nil;
        }
        return StringCopyAdvSend([[googleUserObj authentication] accessToken]);
    }
    
    const char* refreshToken(){
        if(googleUserObj == nil){
            return nil;
        }
        return StringCopyAdvSend([[googleUserObj authentication] refreshToken]);
    }
    
    const char* userIDToken(){
        if(googleUserObj == nil){
            return nil;
        }
        return StringCopyAdvSend([[googleUserObj authentication] idToken]);
    }
    
    
    const char* userActualID(){
        if(googleUserObj == nil){
            return nil;
        }
        return StringCopyAdvSend([googleUserObj userID]);
    }
    
    const char* serverAuthCode(){
        if(googleUserObj == nil){
            return nil;
        }
        return StringCopyAdvSend([googleUserObj serverAuthCode]);
    }
    
    int noOfAvalableScopes(){
        if(googleUserObj == nil){
            return 0;
        }
        
        return (int)[googleUserObj grantedScopes].count;
    }
    
    const char** avalableScopes(){
        if(googleUserObj == nil){
            return nil;
        }
        
        return StringArrayCopyForSend([googleUserObj grantedScopes]);
    }
    
    const char* isLoggedIn(){
        if(googleUserObj == nil){
            return nil;
        }
        return StringCopyAdvSend([[googleUserObj profile] name]);
    }
    
    const char* userPhotoUrl(){
        if(googleUserObj == nil){
            return nil;
        }
        
        if([[googleUserObj profile] hasImage] == true){
            NSURL *url = [[googleUserObj profile] imageURLWithDimension:128];
            return StringCopyAdvSend(url.absoluteString);
        }
        return nil;
    }
    
    
    
}
@end


