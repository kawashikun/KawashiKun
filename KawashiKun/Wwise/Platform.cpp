// Platform.cpp
// Copyright (C) 2010 Audiokinetic Inc
/// \file 
/// Contains definitions for functions declared in Platform.h

#include "stdafx.h"
#include "Platform.h"
//#include "UniversalInput.h"   //WwiseのDemoプロジェクトでは必要。
#include <AK/Tools/Common/AkPlatformFuncs.h>

// del 20151007 #include <AK/SoundEngine/Common/AkSoundEngine.h>                // Sound Engine




class RenderingEngine;
RenderingEngine*	g_renderingEngine = NULL;
//UGBtnState			g_btnState = 0;  これらの定義は、WwiseのDemoプロジェクトでは必要。
//UGStickState		g_sticksState[2];
char				g_szBasePath[AK_IOS_MAX_BANK_PATH];
unsigned int g_windowWidth;
unsigned int g_windowHeight;

UInt32 g_uSamplesPerFrame = 512;

// Custom alloc/free functions. These are declared as "extern" in AkMemoryMgr.h
// and MUST be defined by the game developer.
namespace AK
{
#ifdef AK_APPLE
    void * AllocHook( size_t in_size )
    {
        return malloc( in_size );
    }
    void FreeHook( void * in_ptr )
    {
        free( in_ptr );
    }
#endif
}

