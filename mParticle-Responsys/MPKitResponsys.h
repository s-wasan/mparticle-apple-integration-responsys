//
//  MPKitResponsys.h
//  
//
//  Created by Oracle 2018.
//

#import <Foundation/Foundation.h>
#if defined(__has_include) && __has_include(<mParticle_Apple_SDK/mParticle.h>)
#import <mParticle_Apple_SDK/mParticle.h>
#else
#import "mParticle.h"
#endif

FOUNDATION_EXPORT NSString * _Nonnull const ResponsysEventTypeIAMPremium;
FOUNDATION_EXPORT NSString * _Nonnull const ResponsysEventTypeIAMSocial;
FOUNDATION_EXPORT NSString * _Nonnull const ResponsysEventTypeIAMPurchase;
FOUNDATION_EXPORT NSString * _Nonnull const ResponsysEventTypeIAMOther;

FOUNDATION_EXPORT NSString * _Nonnull const ResponsysEventTypePreference;
FOUNDATION_EXPORT NSString * _Nonnull const ResponsysEvent;

@interface MPKitResponsys : NSObject <MPKitProtocol>

@property (nonatomic, strong, nonnull) NSDictionary *configuration;
@property (nonatomic, strong, nullable) NSDictionary *launchOptions;
@property (nonatomic, unsafe_unretained, readonly) BOOL started;


@end
