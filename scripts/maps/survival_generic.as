#include "point_checkpoint"
#include "HLSPClassicMode"
#include "cubemath/trigger_once_mp"
#include "cubemath/trigger_mediaplayer"
#include "cubemath/item_airbubble"
//#include "ofnvision"
#include "crouch_spawn"

void MapInit()
{	
	RegisterPointCheckPointEntity();
	RegisterTriggerOnceMpEntity();
	RegisterTriggerMediaPlayerEntity();
	RegisterAirbubbleCustomEntity();
	//g_nv.MapInit();
	g_crspawn.Enable();  
	
	// Map support is enabled here by default.
	// So you don't have to add "mp_survival_supported 1" to the map config
	g_SurvivalMode.EnableMapSupport();
	ClassicModeMapInit();
}

void ActivateSurvival( CBaseEntity@ pActivator, CBaseEntity@ pCaller,
	USE_TYPE useType, float flValue )
{
	g_SurvivalMode.Activate();
}
