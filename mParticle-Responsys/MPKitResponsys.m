//
//  MPKitResponsys.m
//  
//
//  Created by Upendra Tripathi on 9/17/18.
//

#import "MPKitResponsys.h"
#import "MPEvent.h"
#import "MPProduct.h"
#import "MPProduct+Dictionary.h"
#import "MPCommerceEvent.h"
#import "MPCommerceEvent+Dictionary.h"
#import "MPCommerceEventInstruction.h"
#import "MPTransactionAttributes.h"
#import "MPTransactionAttributes+Dictionary.h"
#import "MPIHasher.h"
#import "mParticle.h"
#import "MPKitRegister.h"
#import "NSDictionary+MPCaseInsensitive.h"
#import "MPDateFormatter.h"
#import "MPEnums.h"
#import <PushIOManager/PushIOManager.h>

#if TARGET_OS_IOS == 1 && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#import <UserNotifications/UNUserNotificationCenter.h>
#endif

NSString * const PIOConfigurationAPIKey = @"apiKey";
NSString * const PIOConfigurationAccountToken = @"accountToken";

@implementation MPKitResponsys

+(void) load{
    MPKitRegister *pioKitRegister = [[MPKitRegister alloc] initWithName:@"Oracle PushIO" className: @"MPKitResponsys"];
    [MParticle registerExtension:pioKitRegister];
}

- (instancetype)initWithConfiguration:(nonnull NSDictionary *)configuration startImmediately:(BOOL)startImmediately{
    self = [super init];
    NSString *apiKey = nil;
    NSString *accountToken = nil;
    if (self) {
        apiKey = configuration[PIOConfigurationAPIKey];
        accountToken = configuration[PIOConfigurationAccountToken];
    }
    
    if ((NSNull *)apiKey == [NSNull null] || (NSNull *)accountToken == [NSNull null])
    {
        return nil;
    } else {
        return self;
    }
}

- (MPKitExecStatus *)didFinishLaunchingWithConfiguration:(NSDictionary *)configuration {
    MPKitExecStatus *execStatus = nil;
    self.configuration = configuration;
    [self start];
    execStatus = [[MPKitExecStatus alloc] initWithSDKCode:[MPKitResponsys kitCode] returnCode:MPKitReturnCodeSuccess];
    [self start];
    return execStatus;
}

-(void) start{
    static dispatch_once_t kitPredicate;
    
    dispatch_once(&kitPredicate, ^{
        self->_started = YES;
        NSString *apiKey = self.configuration[PIOConfigurationAPIKey];
        NSString *accountToken = self.configuration[PIOConfigurationAccountToken];
        NSError *error = nil;
        BOOL configured = [[PushIOManager sharedInstance] configureWithAPIKey:apiKey accountToken:accountToken error:&error];
        if (configured) {
            NSLog(@"PushIO SDK configured successfully!");
        }else{
            NSLog(@"Unable to configure the PushIO SDK, check the APIKey and Account token and try again");
        }
    });
}

+ (nonnull NSNumber *)kitCode {
    return @102;
}

- (id const)kitInstance {
    return self.started ? [PushIOManager sharedInstance] : nil;
}


#pragma mark - MPKitInstanceProtocol Lifecycle Methods

- (instancetype _Nonnull) init {
    self = [super init];
    self.configuration = @{};
    self.launchOptions = @{};
    return self;
}



#pragma mark - MPKitInstanceProtocol Methods

- (MPKitExecStatus*_Nonnull)setKitAttribute:(nonnull NSString *)key value:(nullable id)value {
    [self.kitApi logError:@"Unrecognized key attibute '%@'.", key];
    return [self execStatus:MPKitReturnCodeUnavailable];
}

- (MPKitExecStatus*_Nonnull)setOptOut:(BOOL)optOut {
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)setUserIdentity:(NSString *)identityString
                        identityType:(MPUserIdentity)identityType {
    if (identityType == MPUserIdentityCustomerId && identityString.length > 0) {
        return [self execStatus:MPKitReturnCodeSuccess];
    } else {
        return [self execStatus:MPKitReturnCodeRequirementsNotMet];
    }
}

- (MPKitExecStatus*_Nonnull)logout {
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)logEvent:(MPEvent *)mpEvent {
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (nonnull MPKitExecStatus *)logCommerceEvent:(nonnull MPCommerceEvent *)commerceEvent {
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)logScreen:(MPEvent *)mpEvent {
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus*) execStatus:(MPKitReturnCode)returnCode {
    return [[MPKitExecStatus alloc] initWithSDKCode:self.class.kitCode returnCode:returnCode];
}

- (nonnull MPKitExecStatus *)continueUserActivity:(nonnull NSUserActivity *)userActivity restorationHandler:(void(^ _Nonnull)(NSArray * _Nullable restorableObjects))restorationHandler{
    [[PushIOManager sharedInstance] continueUserActivity:userActivity restorationHandler:restorationHandler];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (nonnull MPKitExecStatus *)didUpdateUserActivity:(nonnull NSUserActivity *)userActivity{
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (nonnull MPKitExecStatus *)didBecomeActive{
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (nonnull MPKitExecStatus *)failedToRegisterForUserNotifications:(nullable NSError *)error{
    [[PushIOManager sharedInstance] didFailToRegisterForRemoteNotificationsWithError:error];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (nonnull MPKitExecStatus *)handleActionWithIdentifier:(nonnull NSString *)identifier forRemoteNotification:(nonnull NSDictionary *)userInfo{
    [[PushIOManager sharedInstance] handleActionWithIdentifier:identifier forRemoteNotification:userInfo completionHandler:nil];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (nonnull MPKitExecStatus *)handleActionWithIdentifier:(nullable NSString *)identifier forRemoteNotification:(nonnull NSDictionary *)userInfo withResponseInfo:(nonnull NSDictionary *)responseInfo{
    [[PushIOManager sharedInstance] handleActionWithIdentifier:identifier forRemoteNotification:userInfo withResponseInfo:responseInfo completionHandler:nil];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (nonnull MPKitExecStatus *)openURL:(nonnull NSURL *)url options:(nullable NSDictionary<NSString *, id> *)options{
    [[PushIOManager sharedInstance] openURL:url sourceApplication:nil annotation:nil];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (nonnull MPKitExecStatus *)openURL:(nonnull NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(nullable id)annotation{
    [[PushIOManager sharedInstance] openURL:url sourceApplication:sourceApplication annotation:annotation];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (nonnull MPKitExecStatus *)receivedUserNotification:(nonnull NSDictionary *)userInfo{
    [[PushIOManager sharedInstance] didReceiveRemoteNotification:userInfo];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (nonnull MPKitExecStatus *)setDeviceToken:(nonnull NSData *)deviceToken{
    [[PushIOManager sharedInstance] didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    return [self execStatus:MPKitReturnCodeSuccess];
}

@end
