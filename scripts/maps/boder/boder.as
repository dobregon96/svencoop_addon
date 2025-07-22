/*
* Richard Boderbot
* Main script file
*
* Scripts modified by Garompa
* Gluongun, Ethereal, Plasmagun, redeemer, biorifle, beamsword, elites and quad barrel shotgun weapons scripts by Nero/Neyami
* cursed e11 blaster (instagib) by Cubemath
* devastator by Gaftherman from Half Nuked port
* c96 from INS2 weapon pack by KernCore and co.
* monster electro (boderbot) script by Takedeppo 50 cal
* Gunman Chronicles weapons and enemies by anggaranothing
* Sentry MK2 by Giegue
* Hornet gun remake by Nero
* Healthbot and HEVbot by _RC
*/


#include "csobaseweapon"
#include "csocommon"
#include "weapon_ethereal"
#include "weapon_plasmagun"
#include "weapon_beamsword"
#include "weapon_qbarrel"
#include "weapon_redeemer"
#include "weapon_biorifle"
#include "weapon_elites"
#include "weapon_hlmp5"
#include "weapon_teslagun"
#include "weapon_cursed_e11_blaster"
#include "weapon_gluongun"
#include "weapon_shuriken"
#include "weapon_hkmp5"
#include "weapon_dualkriss"
#include "handg/weapon_ins2c96"
#include "carbn/weapon_ins2c96carb"
#include "weapon_hlhornetgun"
#include "hl_nuked/base"
#include "hl_nuked/weapon_hlnuked_rpg"
#include "weapon_ofeagle"
#include "weapon_csocrossbow"
#include "weapon_hlshotgun" 
#include "weapon_clgauss"
#include "weapon_ofshockrifle"

#include "monster_electro"

#include "AMMO/ammo_gcgaussclip"
#include "AMMO/ammo_gcminigunclip"

#include "WEAPON/weapon_gausspistol"
#include "WEAPON/cust_2GaussPistolSniper"
#include "WEAPON/weapon_gcminigun"

#include "MONSTER/monster_human_demoman"
#include "MONSTER/monster_human_bandit"

#include "sentryMK2" 

#include "monster_healthbot"
#include "monster_hevbot"

const bool g_WeaponMode = false;	
	
void MapInit()
{
    cso::CSOCommonSpritesPrecache();
	g_Game.PrecacheGeneric( "sound/rc_labyrinth/intro1.wav" );
	g_Game.PrecacheGeneric( "sound/rc/bite.wav" );
	g_Game.PrecacheGeneric( "sound/weapons/grenade_hit1.wav" );
	g_Game.PrecacheGeneric( "sound/weapons/displacer_fire.wav" );
	g_Game.PrecacheGeneric( "sound/weapons/displacer_impact.wav" );
	g_Game.PrecacheGeneric( "sound/turret/tu_die.wav" );
	g_Game.PrecacheGeneric( "sound/items/medshot4.wav" );
	g_Game.PrecacheGeneric( "sound/items/suitchargeok1.wav" );
	g_Game.PrecacheGeneric( "sound/rc/robo_idle.wav" );
	g_Game.PrecacheGeneric( "sound/rc/robo_idle2.wav" );
	
	g_SoundSystem.PrecacheSound( "rc_labyrinth/intro1.wav" );
	g_SoundSystem.PrecacheSound( "rc/bite.wav" );
	g_SoundSystem.PrecacheSound( "weapons/grenade_hit1.wav" );
	g_SoundSystem.PrecacheSound( "weapons/displacer_fire.wav" );
	g_SoundSystem.PrecacheSound( "weapons/displacer_impact.wav" );
	g_SoundSystem.PrecacheSound( "turret/tu_die.wav" );
	g_SoundSystem.PrecacheSound( "items/medshot4.wav" );
	g_SoundSystem.PrecacheSound( "items/suitchargeok1.wav" );
	g_SoundSystem.PrecacheSound( "rc/robo_idle.wav" );
	g_SoundSystem.PrecacheSound( "rc/robo_idle2.wav" );
	
	g_Game.PrecacheModel( "sprites/rc/rc_explosion2.spr" );

	// Register custom weapons
	cso_plasmagun::Register();
	cso_ethereal::Register();
	cso_beamsword::Register();
	cso_qbarrel::Register();
	hlwe_redeemer::Register();
	hlwe_biorifle::Register();
	cso_elites::Register();
	RegisterHLMP5();
	THWeaponTeslagun::Register();
	RegisterHLE11();
	RegisterGluonGun();
	RegisterGluon();
	RegisterGluonAmmo();
    RegisterShuriken();
	RegisterWeapon_HMP5();
	RegisterWeapon_DKS();
	INS2_C96::Register();
	INS2_C96CARBINE::Register();
	hlw_hornetgun::Register();
	RegisterHLNukedRpg();
	OF_EAGLE::Register();
	cso_crossbow::Register();
	RegisterHLShotgun();
	CLGAUSS::Register();
	RegisterOPSHOCK();	
	
	
	// Register Richard Boderbot
    RegisterElectro();
	
	// Register Gunman weapons
	RegisterEntity_WeaponGaussPistol();
	RegisterEntity_WeaponGaussSniper();
    RegisterEntity_WeaponGCMinigun();
	
	// Register Gunman ammo
	RegisterEntity_AmmoGCGaussClip();
    RegisterEntity_AmmoGCMinigunClip();
	
	// Register Gunman npcs
    MonsterHumanDemoman::Register();
    MonsterHumanBandit::Register();
	
	// Precache Gunman weapons
	g_Game.PrecacheOther("weapon_gausspistol");
	g_Game.PrecacheOther("cust_2GaussPistolSniper");
    g_Game.PrecacheOther("weapon_gcminigun");
	
	// Precache Gunman ammo
	g_Game.PrecacheOther("ammo_gcgaussclip");
    g_Game.PrecacheOther("ammo_gcminigunclip");
	
	// Precache Gunman npcs
    g_Game.PrecacheOther("monster_human_demoman");
    g_Game.PrecacheOther("monster_human_bandit");	

	// Register Flagship Turrets
	RegisterSentryMK2(); 
	
	// Register Healthbot and HEVbot
	RegisterHealthbot();
	RegisterHevbot();

}