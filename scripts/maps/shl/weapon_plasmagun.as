#include "ph_shot"
#include "p_entity"

const int HREPEATER_DEFAULT_GIVE			= 100;
const int HREPEATER_MAX_CARRY			= 360;
const int HREPEATER_MAX_CLIP				= -1;
const int HREPEATER_WEIGHT				= 110;
const int HREPEATER_DAMAGE				= 6;

const string HREPEATER_SOUND_DRAW		= "portalhouse/selectRifleBlaster.wav";
const string HREPEATER_SOUND_FIRE		= "portalhouse/plasma2.wav";
const string HREPEATER_SOUND_EXPLODE		= "portalhouse/latchunlocked2.wav";
const string HREPEATER_SOUND_FIREALT		= "portalhouse/particle_suck1.wav";
const string HREPEATER_SOUND_EXPLODEALT		= "portalhouse/mortarhit.wav";
const string HREPEATER_SOUND_DRYFIRE		= "portalhouse/dryfire.wav";

const string HREPEATER_MODEL_NULL		= "models/not_precached2.mdl";
const string HREPEATER_MODEL_VIEW		= "models/portalhouse/v_plasmagun.mdl";
const string HREPEATER_MODEL_PLAYER		= "models/portalhouse/p_plasmagun.mdl";
const string HREPEATER_MODEL_GROUND		= "models/portalhouse/w_plasmagun.mdl";
const string HREPEATER_MODEL_CLIP		= "models/portal_house/w_plasmaclip.mdl";
const string HREPEATER_MODEL_PROJECTILE	= "models/portalhouse/FlechetteShoot.mdl";

const Vector VECTOR_CONE_HR( 0.25, 0.25, 0.00  );		// 10 degrees by 5 degrees

enum plasmagun_e
{
	HREPEATER_DRAW,
	HREPEATER_HOLSTER,
	HREPEATER_IDLE,
	HREPEATER_FIRE1,
	HREPEATER_FIRE2,
	HREPEATER_FIRE3,
};

class weapon_plasmagun : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	float ATTN_LOW = 0.5;
	float coolDownNum = 0.0;
	CPEntityController@ pController = null;
	
	void Spawn()
	{
		self.Precache();
		g_EntityFuncs.SetModel( self, HREPEATER_MODEL_GROUND );
		self.m_iDefaultAmmo = HREPEATER_DEFAULT_GIVE;
		self.pev.sequence = 1;
		self.FallInit();
	}

	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( HREPEATER_MODEL_NULL );
		g_Game.PrecacheModel( HREPEATER_MODEL_VIEW );
		g_Game.PrecacheModel( HREPEATER_MODEL_PLAYER );
		g_Game.PrecacheModel( HREPEATER_MODEL_GROUND );
		g_Game.PrecacheModel( HREPEATER_MODEL_PROJECTILE );
		g_Game.PrecacheModel( "sprites/portalhouse/cshoot.spr" );	
		g_Game.PrecacheModel( "sprites/portalhouse/plasma.spr" );
		
		g_Game.PrecacheGeneric( "sound/" + HREPEATER_SOUND_DRAW );
		g_Game.PrecacheGeneric( "sound/" + HREPEATER_SOUND_FIRE );
		g_Game.PrecacheGeneric( "sound/" + HREPEATER_SOUND_EXPLODE );
		g_Game.PrecacheGeneric( "sound/" + HREPEATER_SOUND_FIREALT );
		g_Game.PrecacheGeneric( "sound/" + HREPEATER_SOUND_EXPLODEALT );
		g_Game.PrecacheGeneric( "sound/" + HREPEATER_SOUND_DRYFIRE );
		g_SoundSystem.PrecacheSound( HREPEATER_SOUND_DRAW );
		g_SoundSystem.PrecacheSound( HREPEATER_SOUND_FIRE );
		g_SoundSystem.PrecacheSound( HREPEATER_SOUND_EXPLODE );
		g_SoundSystem.PrecacheSound( HREPEATER_SOUND_FIREALT );
		g_SoundSystem.PrecacheSound( HREPEATER_SOUND_EXPLODEALT );
		g_SoundSystem.PrecacheSound( HREPEATER_SOUND_DRYFIRE );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= HREPEATER_MAX_CARRY;
		info.iMaxAmmo2 	= -1;
		info.iMaxClip 	= HREPEATER_MAX_CLIP;
		info.iSlot 		= 3;
		info.iPosition 	= 9;
		info.iFlags 	= ITEM_FLAG_NOAUTORELOAD;
		info.iWeight 	= HREPEATER_WEIGHT;

		return true;
	}

	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer( pPlayer ) )
		{
			@m_pPlayer = pPlayer;
			NetworkMessage message( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
			message.WriteLong( self.m_iId );
			message.End();
			return true;
		}
		
		return false;
	}
	
	bool Deploy()
	{
		if (@pController == null){
		@pController = SpawnWeaponControllerInPlayer( m_pPlayer, HREPEATER_MODEL_PLAYER );
		}
		return self.DefaultDeploy( self.GetV_Model( HREPEATER_MODEL_VIEW ), self.GetP_Model( HREPEATER_MODEL_NULL ), HREPEATER_DRAW, "bow" );
	}


	void Holster( int skipLocal = 0 )
	{
		m_pPlayer.m_flNextAttack = WeaponTimeBase() + 0.7;
		pController.DeletePEntity();
		@pController = null;
	}
	
	float WeaponTimeBase()
	{
		return g_Engine.time;
	}
	
	void PrimaryAttack()
	{

		if( m_pPlayer.pev.waterlevel == WATERLEVEL_HEAD || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = g_Engine.time + 0.5;
			self.m_flNextSecondaryAttack = g_Engine.time + 0.5;
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, HREPEATER_SOUND_DRYFIRE, 1.0, ATTN_LOW, 0, PITCH_NORM );
			return;
		}
		
		if (@pController != null){
		pController.SetAnimAttack();
		}
		
		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
		ShootBlasterCrossbow1( m_pPlayer.pev, m_pPlayer.GetGunPosition() + g_Engine.v_forward * 32 + g_Engine.v_up * -4 + g_Engine.v_right * 4, g_Engine.v_forward * 2000);
		
		int iAnim;
		switch( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed,  0, 1 ) )
		{
			case 0:	iAnim = HREPEATER_FIRE1;
			break;
			
			case 1: iAnim = HREPEATER_FIRE2;
			break;
		}
		self.SendWeaponAnim( iAnim );
		
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, HREPEATER_SOUND_FIRE, 1.0, ATTN_LOW, 0, 94 + Math.RandomLong( 0,0xF ) );
		
		
		//__MP5HL
		
		
		Vector vecSrc	 = m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
		
		// optimized multiplayer. Widened to make it easier to hit a moving player
		m_pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_4DEGREES, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 4, HREPEATER_DAMAGE);

		self.m_flNextPrimaryAttack = self.m_flNextPrimaryAttack + 0.1;
		if( self.m_flNextPrimaryAttack < WeaponTimeBase() )
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.1;

		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed,  10, 15 );
		
		TraceResult tr;
		
		float x, y;
		
		g_Utility.GetCircularGaussianSpread( x, y );
		
		Vector vecDir = vecAiming 
						+ x * VECTOR_CONE_4DEGREES.x * g_Engine.v_right 
						+ y * VECTOR_CONE_4DEGREES.y * g_Engine.v_up;

		Vector vecEnd	= vecSrc + vecDir * 4096;

		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );
		
		if( tr.flFraction < 1.0 )
		{
			if( tr.pHit !is null )
			{
				CBaseEntity@ pHit = g_EntityFuncs.Instance( tr.pHit );
				
				if( pHit is null || pHit.IsBSPModel() )
					g_WeaponFuncs.DecalGunshot( tr, BULLET_PLAYER_9MM );
			}
		}
		
		//_______	
			
		Vector vecTemp;
		vecTemp = m_pPlayer.pev.v_angle;

		vecTemp.x -= 0.8f - (coolDownNum * 0.25f);
		vecTemp.y -= 0.15f;
		m_pPlayer.pev.angles = vecTemp;
		m_pPlayer.pev.fixangle = FAM_FORCEVIEWANGLES;
		
		m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) - 1 );
		self.m_flNextPrimaryAttack = g_Engine.time + 0.08;
		self.m_flNextSecondaryAttack = g_Engine.time + 0.12;
		self.m_flTimeWeaponIdle = g_Engine.time + 1.0;
				
		if (coolDownNum < 1.4){
		coolDownNum += 0.05f;
		}
		
		SetThink( ThinkFunction( this.CoolDownFire ) );
		self.pev.nextthink = g_Engine.time + 0.2;
		
	}
	
	void CoolDownFire(){
		
		if (coolDownNum > 0.0){
		coolDownNum -= 0.7;
		}
		
		if (coolDownNum < 0.0){
		coolDownNum = 0.0;
		}
		
		SetThink( ThinkFunction( this.CoolDownFire ) );
		self.pev.nextthink = g_Engine.time + 0.2;
	}
	
	void SecondaryAttack()
	{

		if( m_pPlayer.pev.waterlevel == WATERLEVEL_HEAD || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 29 )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = g_Engine.time + 0.5;
			self.m_flNextSecondaryAttack = g_Engine.time + 0.5;
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, HREPEATER_SOUND_DRYFIRE, 1.0, ATTN_LOW, 0, PITCH_NORM );
			return;
		}
		
		if (@pController != null){
		pController.SetAnimAttackAlt();
		}
		
		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		self.SendWeaponAnim( HREPEATER_FIRE3 );
		
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, HREPEATER_SOUND_FIREALT, 1.0, ATTN_LOW, 0, 94 + Math.RandomLong( 0,0xF ) );
		
		Math.MakeVectors( m_pPlayer.pev.v_angle + m_pPlayer.pev.punchangle);
		
		ShootCShoot( m_pPlayer.pev, m_pPlayer.GetGunPosition() + g_Engine.v_forward * 32 + g_Engine.v_up * -4 + g_Engine.v_right * 3, g_Engine.v_forward * 1000);
		
		m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) - 30 );
		self.m_flNextPrimaryAttack = g_Engine.time + 1.0;
		self.m_flNextSecondaryAttack = g_Engine.time + 1.0;
		self.m_flTimeWeaponIdle = g_Engine.time + 1.0;
		m_pPlayer.pev.punchangle.x -= 4;
		
	}
	
	
	

	void WeaponIdle()
	{
		
		if( self.m_flTimeWeaponIdle > g_Engine.time )
			return;

		self.SendWeaponAnim( HREPEATER_IDLE );
		self.m_flTimeWeaponIdle = g_Engine.time + 10.0;
	}

}

class FlechetteAmmoBox : ScriptBasePlayerAmmoEntity
{	
	void Spawn()
	{ 
		Precache();
		g_EntityFuncs.SetModel( self, HREPEATER_MODEL_CLIP );
		self.pev.body = 15;
		BaseClass.Spawn();
	}
	
	void Precache()
	{
		g_Game.PrecacheModel( HREPEATER_MODEL_CLIP );
		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav" );
	}
	
	bool AddAmmo( CBaseEntity@ pOther )
	{ 
		int iGive;

		iGive = HREPEATER_DEFAULT_GIVE;

		if( pOther.GiveAmmo( iGive, "flechette", HREPEATER_MAX_CARRY ) != -1)
		{
			g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, "items/9mmclip1.wav", 1, ATTN_NORM );
			return true;
		}
		return false;
	}
}

void RegisterHREPEATER()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "weapon_plasmagun", "weapon_plasmagun" );
	g_ItemRegistry.RegisterWeapon( "weapon_plasmagun", "portalhouse", "flechette" );
}

void RegisterFlechetteAmmoBox()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "FlechetteAmmoBox", "ammo_flechette" );
}
