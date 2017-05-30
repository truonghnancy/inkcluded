//
//  inkcluded-405-Bridging-Header.h
//  inkcluded-405
//
//  Created by Min Woo Roh on 1/28/17.
//  Copyright © 2017 Boba. All rights reserved.
//

#ifndef inkluded_405_Bridging_Header_h
#define inkluded_405_Bridging_Header_h

#import <WILLCore/WILLCore.h>
#import <WILLCore/WacomInkSerialization.h>
#import <MicrosoftAzureMobile/MicrosoftAzureMobile.h>
#import "Stroke.h"
#import <WindowsAzureMessaging/SBNotificationHub.h>

#define HUBNAME @"penmessagepush1"
#define HUBLISTENACCESS @"Endpoint=sb://penmessageapp1.servicebus.windows.net/;SharedAccessKeyName=DefaultListenSharedAccessSignature;SharedAccessKey=WYEEmboI+dSZ12ExjcP89gmafDTHkAs2jqKd+uP1YLE="

#define API_VERSION @"?api-version=2015-01"
#define HUBFULLACCESS @"Endpoint=sb://penmessageapp1.servicebus.windows.net/;SharedAccessKeyName=DefaultFullSharedAccessSignature;SharedAccessKey=UJBwmpxNcUpGM5nmqSwcGyO6i2CXvuY/1ARJncX/foY="

#endif
