enum COLTAnimation_e
{
	COLT_IDLE = 0,
	COLT_SHOOT1,
	COLT_SHOOT2,
	COLT_RELOAD,
	COLT_RELOAD_NOSHOOT,
	COLT_DRAW,
	COLT_SHOOT_EMPTY,
	COLT_IDLE_EMPTY
};

const int COLT_MAX_CARRY 	= 250;
const int COLT_DEFAULT_GIVE	= 7 * 2;
const int COLT_MAX_CLIP  	= 7;
const int COLT_WEIGHT    	= 25;

class weapon_m1911 : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	int m_iShell;
	int m_iShotsFired;

	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/ww2projekt/m1911/w_colt.mdl" );
		
		self.m_iDefaultAmmo = COLT_DEFAULT_GIVE;
		m_iShotsFired = 0;
		
		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/ww2projekt/m1911/w_colt.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/m1911/p_colt.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/m1911/v_colt.mdl" );
		m_iShell = g_Game.PrecacheModel ( "models/ww2projekt/shell_small.mdl" );
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/m1911_shoot.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/m1911_reload_clipout.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/m1911_reload_clipin.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/m1911_reload_boltforward.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/m1911_hammerback.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/rifleselect.wav" ); 
		
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/m1911_shoot.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/m1911_reload_clipout.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/m1911_reload_clipin.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/m1911_reload_boltforward.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/m1911_hammerback.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/rifleselect.wav" );
		g_SoundSystem.PrecacheSound( "weapons/357_cock1.wav" );
		
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/americans_selection.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/weapon_m1911.txt" );
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= COLT_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= COLT_MAX_CLIP;
		info.iSlot		= 1;
		info.iPosition	= 6;
		info.iFlags		= 0;
		info.iWeight	= COLT_WEIGHT;
		
		return true;
	}
	
	bool PlayEmptySound()
	{
		if( self.m_bPlayEmptySound )
		{
			self.m_bPlayEmptySound = false;
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_AUTO, "weapons/357_cock1.wav", 0.8, ATTN_NORM, 0, PITCH_NORM );
		}
		return false;
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer( pPlayer ) )
		{
			@m_pPlayer = pPlayer;
			NetworkMessage allies2( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				allies2.WriteLong( g_ItemRegistry.GetIdForName("weapon_m1911") );
			allies2.End();
			return true;
		}
		
		return false;
	}
	
	float WeaponTimeBase()
	{
		return g_Engine.time;
	}
	
	bool Deploy()
	{
		bool bResult;
		{
			bResult = self.DefaultDeploy( self.GetV_Model( "models/ww2projekt/m1911/v_colt.mdl" ), self.GetP_Model( "models/ww2projekt/m1911/p_colt.mdl" ), COLT_DRAW, "onehanded" );
			
			float deployTime = 0.704f;
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + deployTime;
			return bResult;
		}
	}

	void Holster( int skipLocal = 0 ) 
	{
		self.m_fInReload = false;
		BaseClass.Holster( skipLocal );
	}
	
	void PrimaryAttack()
	{
		if( m_pPlayer.pev.waterlevel == WATERLEVEL_HEAD || self.m_iClip <= 0 )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;
			return;
		}

		m_iShotsFired++;
		if( m_iShotsFired > 1 )
		{
			return;
		}
		
		self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.11;
		
		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		
		--self.m_iClip;
		
		m_pPlayer.pev.effects |= EF_MUZZLEFLASH;
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
		if( self.m_iClip == 0 )
		{
			self.SendWeaponAnim( COLT_SHOOT_EMPTY, 0, 0 );
		}
		else
		{
			switch( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 1 ) )
			{
				case 0: self.SendWeaponAnim( COLT_SHOOT1 ); break;
				case 1: self.SendWeaponAnim( COLT_SHOOT2 );	break;
			}
		}
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/ww2projekt/m1911_shoot.wav", 1.0, ATTN_NORM, 0, PITCH_NORM );
		
		Vector vecSrc	 = m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
		
		int m_iBulletDamage = 18;
		
		m_pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_2DEGREES, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 2, m_iBulletDamage );

		if( self.m_iClip == 0 && m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			m_pPlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );

		m_pPlayer.pev.punchangle.x = Math.RandomFloat( -2.2, -1.7 );

		if( self.m_flNextPrimaryAttack < WeaponTimeBase() )
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;

		self.m_flTimeWeaponIdle = WeaponTimeBase() + Math.RandomFloat( 10, 15 );
		
		TraceResult tr;
		
		float x, y;
		
		g_Utility.GetCircularGaussianSpread( x, y );
		
		Vector vecDir = vecAiming + x * VECTOR_CONE_2DEGREES.x * g_Engine.v_right + y * VECTOR_CONE_2DEGREES.y * g_Engine.v_up;
		Vector vecEnd = vecSrc + vecDir * 4096;

		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );
		
		//Get's the barrel attachment
		Vector vecAttachOrigin;
		Vector vecAttachAngles;
		g_EngineFuncs.GetAttachment( m_pPlayer.edict(), 0, vecAttachOrigin, vecAttachAngles );
		
		WW2DynamicLight( m_pPlayer.pev.origin, 8, 240, 180, 0, 8, 50 );
		
		if( tr.flFraction < 1.0 )
		{
			if( tr.pHit !is null )
			{
				CBaseEntity@ pHit = g_EntityFuncs.Instance( tr.pHit );
				
				if( pHit is null || pHit.IsBSPModel() == true )
					g_WeaponFuncs.DecalGunshot( tr, BULLET_PLAYER_MP5 );
			}
		}
		
		Vector vecShellVelocity, vecShellOrigin;
		GetDefaultShellInfo( m_pPlayer, vecShellVelocity, vecShellOrigin, 13, 6, -10, false, false );
		vecShellVelocity.y *= 1;
		g_EntityFuncs.EjectBrass( vecShellOrigin, vecShellVelocity, m_pPlayer.pev.angles[ 1 ], m_iShell, TE_BOUNCE_SHELL );
	}
	
	void Reload()
	{
		if( self.m_iClip == COLT_MAX_CLIP || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			return;

		self.DefaultReload( COLT_MAX_CLIP, COLT_RELOAD_NOSHOOT, 2.79, 0 );
		BaseClass.Reload();
	}
	
	void WeaponIdle()
	{
		// Can we fire?
		if ( self.m_flNextPrimaryAttack < WeaponTimeBase() )
		{
		// If the player is still holding the attack button, m_iShotsFired won't reset to 0
		// Preventing the automatic firing of the weapon
			if ( !( ( m_pPlayer.pev.button & IN_ATTACK ) != 0 ) )
			{
				// Player released the button, reset now
				m_iShotsFired = 0;
			}
		}
		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );
		
		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
	
		self.SendWeaponAnim( (self.m_iClip <= 0) ? COLT_IDLE_EMPTY : COLT_IDLE );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 10, 15 );
	}
}

string GetM1911Name()
{
	return "weapon_m1911";
}

void RegisterM1911()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetM1911Name(), GetM1911Name() );
	g_ItemRegistry.RegisterWeapon( GetM1911Name(), "ww2projekt", "9mm" );
}