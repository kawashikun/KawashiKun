//
//  WwiseTestObj.m ==>> WwiseTestObj.mm にすること。
//  KawashiKun
//
//  Created by etsuji suzuki on 2015/10/07.
//  Copyright © 2015年 yamaguchi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WwiseObj.h"
#import "WwizeTest.h"

@implementation ObjCppWwise {
    CppWwise *cpp;
}

-(id)init {
    self = [super init];
    cpp = new CppWwise();
    return self;
}


-(void)InitSoundEngine {
    cpp->InitSoundEngine();
}
-(void)tmpRenderAudio {
    cpp->tmpRenderAudio();
}

-(void)tmpGunFire {
    cpp->tmpGunFire();
}
-(void)tmpFootStep {
    cpp->tmpFootStep();
}

@end