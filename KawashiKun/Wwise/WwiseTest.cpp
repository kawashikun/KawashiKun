//
//  WwiseTest.cpp
//  KawashiKun
//
//  Created by etsuji suzuki on 2015/10/07.
//  Copyright © 2015年 yamaguchi. All rights reserved.
//

#include <stdio.h>
#include "WwizeTest.h"
//#include "Wwise_IDs.h"    // Wwiseの呼び出し方法を ID で行う場合に必要。現在は名称で行っているため、このファイルを参照する必要はない。

#include <AK/SoundEngine/Common/AkMemoryMgr.h>                  // Memory Manager
#include <AK/SoundEngine/Common/AkModule.h>                     // Default memory and stream managers

#include <AK/SoundEngine/Common/IAkStreamMgr.h>                 // Streaming Manager
#include <AK/Tools/Common/AkPlatformFuncs.h>                    // Thread defines
#include <AkFilePackageLowLevelIOBlocking.h>                    // Sample low-level I/O implementation


#include <AK/SoundEngine/Common/AkSoundEngine.h>                // Sound Engine
#include <AK/SoundEngine/Common/AkStreamMgrModule.h>            // Sound Engine

#import <UIKit/UIKit.h>//20151017
#include "Platform.h"

/// Game Object ID ( UNQとなるように数値を定義すれば良いようだ。ためしに、適当にわりふってみるか! )
static const AkGameObjectID GAME_OBJECT_INIT = 100;//暫定
static const AkGameObjectID GAME_OBJECT_CAR = 10;//暫定
static const AkGameObjectID GAME_OBJECT_HUMAN = 20;//暫定
static const AkGameObjectID GAME_OBJECT_RECORDABLE = 30;//暫定
static const AkGameObjectID GAME_OBJECT_MOTION = 40;//暫定
static const AkGameObjectID GAME_OBJECT_GRAVEL = 50;//暫定
static const AkGameObjectID GAME_OBJECT_TITLE = 60;//暫定
static const AkGameObjectID GAME_OBJECT_MUSICCALL = 70;//暫定


// Bank file names ( Wwiseにて指定したバンクファイル名を定義 )
#define BANKNAME_INIT L"Init.bnk"
#define BANKNAME_CAR L"Car.bnk"
#define BANKNAME_HUMAN L"Human.bnk"
#define BANKNAME_BGM L"BGM.bnk"
#define BANKNAME_GRAVEL L"Gravel.bnk"
#define BANKNAME_MOTION L"Motion.bnk"
#define BANKNAME_TITLE L"New_SoundBank.bnk"
#define BANKNAME_MUSICCALL L"MusicCallbacks.bnk"


extern char g_szBasePath[AK_IOS_MAX_BANK_PATH];



// We're using the default Low-Level I/O implementation that's part
// of the SDK's sample code, with the file package extension
CAkFilePackageLowLevelIOBlocking g_lowLevelIO;

//-------------------------------------//
// Wwiseサウンドエンジンの初期化           //
//-------------------------------------//
void CppWwise::InitSoundEngine() {

    Boolean oResult = true;
  
    //-------------------------------------//
    // メモリマネージャの初期化
    //-------------------------------------//
    //
    // Create and initialize an instance of the default memory manager. Note
    // that you can override the default memory manager with your own. Refer
    // to the SDK documentation for more information.
    //
    
    AkMemSettings memSettings;
    memSettings.uMaxNumPools = 20;
    
    if ( AK::MemoryMgr::Init( &memSettings ) != AK_Success )
    {
        assert( ! "Could not create the memory manager." );
        oResult = false;
    }
    
    //-------------------------------------//
    // ストリームマネージャの初期化
    //-------------------------------------//
    //
    // Create and initialize an instance of the default streaming manager. Note
    // that you can override the default streaming manager with your own. Refer
    // to the SDK documentation for more information.
    //
    
    AkStreamMgrSettings stmSettings;
    AK::StreamMgr::GetDefaultSettings( stmSettings );
    
    // Customize the Stream Manager settings here.
    
    if ( !AK::StreamMgr::Create( stmSettings ) )
    {
        assert( ! "Could not create the Streaming Manager" );
        oResult = false;
    }
    
    //-------------------------------------//
    // I/O ハンドシェイクの初期化
    //-------------------------------------//
    //
    // Create a streaming device with blocking low-level I/O handshaking.
    // Note that you can override the default low-level I/O module with your own. Refer
    // to the SDK documentation for more information.
    //
    AkDeviceSettings deviceSettings;
    AK::StreamMgr::GetDefaultDeviceSettings( deviceSettings );
    
    // Customize the streaming device settings here.
    
    // CAkFilePackageLowLevelIOBlocking::Init() creates a streaming device
    // in the Stream Manager, and registers itself as the File Location Resolver.
    if ( g_lowLevelIO.Init( deviceSettings ) != AK_Success )
    {
        assert( ! "Could not create the streaming device and Low-Level I/O system" );
        oResult = false;
    }
 
    
    //-------------------------------------//
    // サウンドエンジンの初期化
    //    バッファサイズ等はサンプルコードをそのまま流用中
    //-------------------------------------//
    AkInitSettings          initSettings;
    AkPlatformInitSettings  platformInitSettings;
        
    AK::SoundEngine::GetDefaultInitSettings( initSettings );
    AK::SoundEngine::GetDefaultPlatformInitSettings( platformInitSettings );
        
    initSettings.uDefaultPoolSize           = 4 * 1024 * 1024;  // 4 MB
    initSettings.uMaxNumPaths               = 16;
    initSettings.uMaxNumTransitions         = 128;
        
    platformInitSettings.uLEngineDefaultPoolSize    = 4 * 1024 * 1024;  // 4 MB
        
    if ( AK::SoundEngine::Init( &initSettings, &platformInitSettings ) != AK_Success )
    {
        oResult = false;
    }else{
        oResult = true;
    }
    
    //-------------------------------------//
    // バンクファイルのディレクトリを指定
    // ※ ローカルのある /banks/ フォルダーのパスを指定してください。・・・ちょっと面倒そうなので、いまんとこハードコーディングでよろしくです
    //   直しました！
    //-------------------------------------//
    NSString *path = [[NSBundle mainBundle] bundlePath];
    path = [path stringByAppendingString: @"/"];
    strncpy(g_szBasePath, [path UTF8String], AK_IOS_MAX_BANK_PATH);
    g_lowLevelIO.SetBasePath( AKTEXT(&g_szBasePath[0]) );
    // ※パスの末尾に/を入れ忘れて、ひどい目にあった。20151009 etsuji

    AK::StreamMgr::SetCurrentLanguage( AKTEXT("English(US)") );

    
    //-------------------------------------//
    //必要なbankをメモリにロードしておく
    //-------------------------------------//
    AkBankID bankID; // Not used. These banks can be unloaded with their file name.
    AKRESULT eResult = AK_Success;
    
    eResult = AK::SoundEngine::LoadBank( BANKNAME_INIT, AK_DEFAULT_POOL_ID, bankID );
    if (eResult != AK_Success) {
        abort();
    }

    eResult = AK::SoundEngine::LoadBank( BANKNAME_CAR, AK_DEFAULT_POOL_ID, bankID );
    if (eResult != AK_Success) {
        abort();
    }
    eResult = AK::SoundEngine::LoadBank( BANKNAME_HUMAN, AK_DEFAULT_POOL_ID, bankID );
    if (eResult != AK_Success) {
        abort();
    }
    eResult = AK::SoundEngine::LoadBank( BANKNAME_BGM, AK_DEFAULT_POOL_ID, bankID );
    if (eResult != AK_Success) {
        abort();
    }
    eResult = AK::SoundEngine::LoadBank( BANKNAME_GRAVEL, AK_DEFAULT_POOL_ID, bankID );
    if (eResult != AK_Success) {
        abort();
    }
    eResult = AK::SoundEngine::LoadBank( BANKNAME_MOTION, AK_DEFAULT_POOL_ID, bankID );
    if (eResult != AK_Success) {
        abort();
    }
    eResult = AK::SoundEngine::LoadBank( BANKNAME_TITLE, AK_DEFAULT_POOL_ID, bankID );
    if (eResult != AK_Success) {
        abort();
    }
    eResult = AK::SoundEngine::LoadBank( BANKNAME_MUSICCALL, AK_DEFAULT_POOL_ID, bankID );
    if (eResult != AK_Success) {
        abort();
    }
    
    //-------------------------------------//
    // Wwise内のSoundBank 名称と、プログラム内部で定義したIDを関連づけする
    //-------------------------------------//
    AK::SoundEngine::RegisterGameObj( GAME_OBJECT_INIT, *(const wchar_t*)BANKNAME_INIT );
    AK::SoundEngine::RegisterGameObj( GAME_OBJECT_CAR, *(const wchar_t*)BANKNAME_CAR );
    AK::SoundEngine::RegisterGameObj( GAME_OBJECT_HUMAN, *(const wchar_t*)BANKNAME_HUMAN );
    AK::SoundEngine::RegisterGameObj( GAME_OBJECT_GRAVEL, *(const wchar_t*)BANKNAME_GRAVEL );
    AK::SoundEngine::RegisterGameObj( GAME_OBJECT_MOTION, *(const wchar_t*)BANKNAME_MOTION );
    AK::SoundEngine::RegisterGameObj( GAME_OBJECT_TITLE, *(const wchar_t*)BANKNAME_TITLE );
    AK::SoundEngine::RegisterGameObj( GAME_OBJECT_MUSICCALL, *(const wchar_t*)BANKNAME_MUSICCALL );

    
    //-------------------------------------//
    // Bankがグループ化されているものは、どのグループを使うのか指定しておく
    //-------------------------------------//
    AK::SoundEngine::SetSwitch( L"Surface", L"Gravel", GAME_OBJECT_GRAVEL); //Surface - Gravel を利用する
    AK::SoundEngine::SetRTPCValue(L"Footstep_Speed", 1, GAME_OBJECT_GRAVEL);
    AK::SoundEngine::SetRTPCValue(L"Footstep_Weight", 50 / 2.0f, GAME_OBJECT_GRAVEL);

    
    //-------------------------------------//
    // 再生したいイベント(曲)を指定する
    //  ゲーム開始のとき、一度だけ再生する音を指定する。例えばステージの開始の時に鳴らす音。
    //-------------------------------------//
    //   AK::SoundEngine::PostEvent( L"Play_RecordableMusic", GAME_OBJECT_HUMAN );
    ///  AK::SoundEngine::PostEvent( L"DoorSliding", GAME_OBJECT_MOTION); // ドアが開くような音
    //   AK::SoundEngine::PostEvent( L"Play_Hello", GAME_OBJECT_HUMAN );
    //AK::SoundEngine::PostEvent( L"PlayTITLE", GAME_OBJECT_MUSICCALL); // TEST
   AK::SoundEngine::PostEvent( L"Play_RecordableMusic", GAME_OBJECT_TITLE ); // BGMとして利用している音だが、ID指定が適当でも発音するのはなぜ???

    
    //-------------------------------------//
    // 音を再生する指示を発行( 別途、frame毎に RenderAudio を呼び出すのでこの場所では必須ではないかもしれない )
    //-------------------------------------//
    AK::SoundEngine::RenderAudio();
    
}

//-------------------------------------//
// 鉄砲音
//-------------------------------------//
void CppWwise::tmpGunFire() {
    AK::SoundEngine::PostEvent( L"GunFire", GAME_OBJECT_MOTION);
}

//-------------------------------------//
// 足音
//-------------------------------------//
void CppWwise::tmpFootStep() {
      AK::SoundEngine::PostEvent( L"Play_Footsteps", GAME_OBJECT_GRAVEL);
}

//-------------------------------------//
// frame毎に呼び出す処理( キューのイベントを取り出して再生する )
//-------------------------------------//
void CppWwise::tmpRenderAudio() {
    AK::SoundEngine::RenderAudio();
}
