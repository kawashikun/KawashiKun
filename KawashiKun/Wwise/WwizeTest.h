//
//  WwizeTest.h
//  KawashiKun
//
//  Created by etsuji suzuki on 2015/10/07.
//  Copyright © 2015年 yamaguchi. All rights reserved.
//

#ifndef WwizeTest_h
#define WwizeTest_h

#include <stdio.h>

class CppWwise {
public:
    void InitSoundEngine();
    void tmpRenderAudio();
    void tmpGunFire(unsigned char bVal  );
    void tmpBomb(unsigned char bVal  );
    void tmpReject(unsigned char bVal  );
    
    void tmpFootStep();

};

#endif /* WwizeTest_h */
