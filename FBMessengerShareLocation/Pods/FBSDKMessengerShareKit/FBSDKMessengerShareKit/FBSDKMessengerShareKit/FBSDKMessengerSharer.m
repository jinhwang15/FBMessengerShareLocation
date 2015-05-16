// Copyright (c) 2014-present, Facebook, Inc. All rights reserved.
//
// You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
// copy, modify, and distribute this software in source code or binary form for use
// in connection with the web services and APIs provided by Facebook.
//
// As with any software that integrates with the Facebook platform, your use of
// this software is subject to the Facebook Developer Principles and Policies
// [http://developers.facebook.com/policy/]. This copyright notice shall be
// included in all copies or substantial portions of the software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "FBSDKMessengerSharer.h"

#import "FBSDKMessengerApplicationStateManager.h"
#import "FBSDKMessengerContext+Internal.h"
#import "FBSDKMessengerInstallMessengerAlertPresenter.h"
#import "FBSDKMessengerShareOptions.h"
#import "FBSDKMessengerURLHandlerReplyContext.h"
#import "FBSDKMessengerUtils.h"

// This SDK version, which is synchronized with Messenger. This is incremented with every SDK release
static NSString *const kFBSDKMessengerShareKitSendVersion = @"20150218";
// URLs to talk to messenger
static NSString *const kMessengerPlatformPrefix = @"fb-messenger-platform";

// Messenger actions
static NSString *const kMessengerActionBroadcast = @"broadcast";

// Pasteboard types
static NSString *const kMessengerPasteboardTypeVideo = @"com.messenger.video";
static NSString *const kMessengerPasteboardTypeImage = @"com.messenger.image";
static NSString *const kMessengerPasteboardTypeAudio = @"com.messenger.audio";

static NSString *const kMessengerPlatformMetadataParamName = @"metadata";
static NSString *const kMessengerPlatformSourceURLParamName = @"sourceURL";

static NSString *const kMessengerPlatformQueryString = @"pasteboard_type=%@&app_id=%@&version=%@";

static NSString *URLSchemeForVersion(NSString *version)
{
  return [NSString stringWithFormat:@"%@-%@", kMessengerPlatformPrefix, version];
}

@implementation FBSDKMessengerSharer

// Returns string representing the version of messenger that's currently installed
+ (NSString *)currentlyInstalledMessengerVersion
{
  // Manually check every single version of the SDK that's been installed by trying
  // canOpenURL until we find one that matches
  NSDictionary *platformCapabilities = [FBSDKMessengerSharer messengerVersionCapabilities];

  NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:NO selector:@selector(localizedCompare:)];
  NSArray* sortedReleases = [[platformCapabilities allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];

  for (NSString *version in sortedReleases) {
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = URLSchemeForVersion(version);
    if ([[UIApplication sharedApplication] canOpenURL:components.URL]) {
      return version;
    }
  }

  return nil;
}

+ (NSDictionary *)messengerVersionCapabilities
{
  static NSDictionary *messengerShareKitVersionCapabilities = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    FBSDKMessengerPlatformCapability v2015_01_28 = (FBSDKMessengerPlatformCapabilityOpen |
                                                    FBSDKMessengerPlatformCapabilityImage |
                                                    FBSDKMessengerPlatformCapabilityVideo |
                                                    FBSDKMessengerPlatformCapabilityAnimatedGIF);

    FBSDKMessengerPlatformCapability v2015_02_18 = (v2015_01_28 | FBSDKMessengerPlatformCapabilityAudio);

    FBSDKMessengerPlatformCapability v2015_03_05 = (v2015_02_18 | FBSDKMessengerPlatformCapabilityAnimatedWebP);

    messengerShareKitVersionCapabilities = @{
                                             @"20150305": @(v2015_03_05),
                                             @"20150218": @(v2015_02_18),
                                             @"20150128": @(v2015_01_28)
                                             };
  });
  return messengerShareKitVersionCapabilities;
}

+ (void)_launchUrl:(NSString *)pasteboardType withOptions:(FBSDKMessengerShareOptions *)options
{
  NSURLComponents *components = [[NSURLComponents alloc] init];
  components.scheme = URLSchemeForVersion([FBSDKMessengerSharer currentlyInstalledMessengerVersion]);
  components.host = kMessengerActionBroadcast;

  NSString *queryString = [NSString stringWithFormat:kMessengerPlatformQueryString,
                           pasteboardType,
                           FBSDKMessengerDefaultAppID(),
                           kFBSDKMessengerShareKitSendVersion];

  if (options.metadata.length > 0) {
    NSString *metadataParam = [NSString stringWithFormat:@"&%@=%@", kMessengerPlatformMetadataParamName, options.metadata];
    queryString = [queryString stringByAppendingString:metadataParam];
  }

  FBSDKMessengerContext *context;
  if (options.contextOverride) {
    context = options.contextOverride;
  } else {
    context = [FBSDKMessengerApplicationStateManager sharedInstance].currentContext;
  }

  if (context.queryString.length > 0) {
    queryString = [queryString stringByAppendingString:context.queryString];
  }

  if (options.sourceURL.absoluteString.length > 0) {
    NSString *sourceURLParam = [NSString stringWithFormat:@"&%@=%@", kMessengerPlatformSourceURLParamName, options.sourceURL.absoluteString];
    queryString = [queryString stringByAppendingString:sourceURLParam];
  }

  components.query = queryString;

  [[UIApplication sharedApplication] openURL:components.URL];
  [FBSDKMessengerApplicationStateManager sharedInstance].currentContext = nil;
}

#pragma mark - Public

+ (FBSDKMessengerPlatformCapability)messengerPlatformCapabilities
{
  NSDictionary *allVersionCapabilites = [FBSDKMessengerSharer messengerVersionCapabilities];
  NSString *currentlyInstalledVersion = [FBSDKMessengerSharer currentlyInstalledMessengerVersion];
  return currentlyInstalledVersion ? [allVersionCapabilites[currentlyInstalledVersion] unsignedIntegerValue] : FBSDKMessengerPlatformCapabilityNone;
}

+ (void)openMessenger
{
  if (!([FBSDKMessengerSharer messengerPlatformCapabilities] & FBSDKMessengerPlatformCapabilityOpen)) {
    return;
  }

  NSURLComponents *components = [[NSURLComponents alloc] init];
  components.scheme = URLSchemeForVersion([FBSDKMessengerSharer currentlyInstalledMessengerVersion]);
  [[UIApplication sharedApplication] openURL:components.URL];
}

#pragma mark - Image

+ (void)shareImage:(UIImage *)image
      withMetadata:(NSString *)metadata
       withContext:(FBSDKMessengerContext *)context
{
  FBSDKMessengerShareOptions *options = [[FBSDKMessengerShareOptions alloc] init];
  options.metadata = metadata;

  [FBSDKMessengerSharer shareImage:image withOptions:options];
}

+ (void)shareImage:(UIImage *)image withOptions:(FBSDKMessengerShareOptions *)options
{
  if (!([FBSDKMessengerSharer messengerPlatformCapabilities] & FBSDKMessengerPlatformCapabilityImage)) {
    [[FBSDKMessengerInstallMessengerAlertPresenter sharedInstance] presentInstallMessengerAlert];
    return;
  }

  if (image == nil) {
    return;
  }

  NSData *data = UIImagePNGRepresentation(image);
  [[UIPasteboard generalPasteboard] setData:data
                          forPasteboardType:kMessengerPasteboardTypeImage];

  [FBSDKMessengerSharer _launchUrl:kMessengerPasteboardTypeImage withOptions:options];
}

#pragma mark - Animated GIF

+ (void)shareAnimatedGIF:(NSData *)animatedGIFData
            withMetadata:(NSString *)metadata
             withContext:(FBSDKMessengerContext *)context
{
  FBSDKMessengerShareOptions *options = [[FBSDKMessengerShareOptions alloc] init];
  options.metadata = metadata;

  [FBSDKMessengerSharer shareAnimatedGIF:animatedGIFData withOptions:options];
}

+ (void)shareAnimatedGIF:(NSData *)animatedGIFData withOptions:(FBSDKMessengerShareOptions *)options
{
  if (!([FBSDKMessengerSharer messengerPlatformCapabilities] & FBSDKMessengerPlatformCapabilityAnimatedGIF)) {
    [[FBSDKMessengerInstallMessengerAlertPresenter sharedInstance] presentInstallMessengerAlert];
    return;
  }

  if (animatedGIFData == nil) {
    return;
  }

  [[UIPasteboard generalPasteboard] setData:animatedGIFData
                          forPasteboardType:kMessengerPasteboardTypeImage];

  [FBSDKMessengerSharer _launchUrl:kMessengerPasteboardTypeImage withOptions:options];
}

#pragma mark - Animated WebP

+ (void)shareAnimatedWebP:(NSData *)animatedWebPData
             withMetadata:(NSString *)metadata
              withContext:(FBSDKMessengerContext *)context
{
  FBSDKMessengerShareOptions *options = [[FBSDKMessengerShareOptions alloc] init];
  options.metadata = metadata;

  [FBSDKMessengerSharer shareAnimatedWebP:animatedWebPData withOptions:options];
}

+ (void)shareAnimatedWebP:(NSData *)animatedWebPData withOptions:(FBSDKMessengerShareOptions *)options
{
  if (!([FBSDKMessengerSharer messengerPlatformCapabilities] & FBSDKMessengerPlatformCapabilityAnimatedWebP)) {
    [[FBSDKMessengerInstallMessengerAlertPresenter sharedInstance] presentInstallMessengerAlert];
    return;
  }

  if (animatedWebPData == nil) {
    return;
  }

  [[UIPasteboard generalPasteboard] setData:animatedWebPData
                          forPasteboardType:kMessengerPasteboardTypeImage];

  [FBSDKMessengerSharer _launchUrl:kMessengerPasteboardTypeImage withOptions:options];
}

#pragma mark - Video

+ (void)shareVideo:(NSData *)videoData
      withMetadata:(NSString *)metadata
       withContext:(FBSDKMessengerContext *)context
{
  FBSDKMessengerShareOptions *options = [[FBSDKMessengerShareOptions alloc] init];
  options.metadata = metadata;

  [FBSDKMessengerSharer shareVideo:videoData withOptions:options];
}

+ (void)shareVideo:(NSData *)videoData withOptions:(FBSDKMessengerShareOptions *)options
{
  if (!([FBSDKMessengerSharer messengerPlatformCapabilities] & FBSDKMessengerPlatformCapabilityVideo)) {
    [[FBSDKMessengerInstallMessengerAlertPresenter sharedInstance] presentInstallMessengerAlert];
    return;
  }

  if (videoData == nil) {
    return;
  }

  [[UIPasteboard generalPasteboard] setData:videoData
                          forPasteboardType:kMessengerPasteboardTypeVideo];

  [FBSDKMessengerSharer _launchUrl:kMessengerPasteboardTypeVideo withOptions:options];
}

#pragma mark - Audio

+ (void)shareAudio:(NSData *)audioData
      withMetadata:(NSString *)metadata
       withContext:(FBSDKMessengerContext *)context
{
  FBSDKMessengerShareOptions *options = [[FBSDKMessengerShareOptions alloc] init];
  options.metadata = metadata;

  [FBSDKMessengerSharer shareAudio:audioData withOptions:options];
}

+ (void)shareAudio:(NSData *)audioData withOptions:(FBSDKMessengerShareOptions *)options
{
  if (!([FBSDKMessengerSharer messengerPlatformCapabilities] & FBSDKMessengerPlatformCapabilityAudio)) {
    [[FBSDKMessengerInstallMessengerAlertPresenter sharedInstance] presentInstallMessengerAlert];
    return;
  }

  if (audioData == nil) {
    return;
  }

  [[UIPasteboard generalPasteboard] setData:audioData
                          forPasteboardType:kMessengerPasteboardTypeAudio];

  [FBSDKMessengerSharer _launchUrl:kMessengerPasteboardTypeAudio withOptions:options];
}

@end
