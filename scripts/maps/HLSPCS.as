/*
* This script implements HLSP survival mode
*/

#include "point_checkpoint"
#include "cubemath/trigger_once_mp"
#include "hlsp/trigger_suitcheck"
//#include "HLSPClassicMode"
#include "cs16/cs16register"
#include "cubemath/trigger_mediaplayer"


void MapInit()
{
    RegisterCS16();
    CS16::CSMoneyMapInit();

    RegisterPointCheckPointEntity();
    RegisterTriggerOnceMpEntity();
    RegisterTriggerSuitcheckEntity();
    RegisterTriggerMediaPlayerEntity();
    
    g_EngineFuncs.CVarSetFloat( "mp_hevsuit_voice", 1 );
    
    //ClassicModeMapInit();
}

void MapActivate()
{
    CS16::CSMoneyMapActivate();
}