//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import <PTDBeanManager.h>

/**
 * The following method is defined in the cocoapod and is exposed here so that this
 * class can conform to the BrickBotRobot protocol
 */
@interface PTDBean (BrickBot)

@property (readonly) BOOL connected;

@end