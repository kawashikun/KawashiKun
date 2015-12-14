//
//  WwiseObj.h
//  KawashiKun
//
//  Created by etsuji suzuki on 2015/10/07.
//  Copyright © 2015年 yamaguchi. All rights reserved.
//

#ifndef WwiseObj_h
#define WwiseObj_h

#import <Foundation/Foundation.h>

@interface ObjCppWwise : NSObject
-(void)InitSoundEngine;
-(void)tmpRenderAudio;
-(void)tmpGunFire : (UInt32) bVal;
-(void)tmpBomb : (UInt32) bVal;
-(void)tmpReject : (UInt32) bVal;
-(void)tmpFootStep;

@end

#endif /* WwiseObj_h */
