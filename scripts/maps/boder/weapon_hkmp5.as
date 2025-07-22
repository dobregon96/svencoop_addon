enum HMP5Animation
{
	HMP5_IDLE = 0,
	HMP5_IDLE_EMPTY,
	HMP5_SHOOTL1,
	HMP5_SHOOTL2,
	HMP5_SHOOTLL,
	HMP5_SHOOTR1,
	HMP5_SHOOTR2,
	HMP5_SHOOTRL,
	HMP5_RELOAD,
	HMP5_DRAW
};

const int HMP5_DEFAULT_GIVE 	= 100;
const int HMP5_MAX_AMMO		= 600;
const int HMP5_MAX_CLIP 	= 65;
const int HMP5_WEIGHT 		= 8;

class weapon_hkmp5 : ScriptBasePlayerWeaponEntity
{
	float m_flNextAnimTime;
	int m_iShell;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/CSOZBS/z4/weapons/w_hkmp5.mdl" );

		self.m_iDefaultAmmo = HMP5_DEFAULT_GIVE;

		self.FallInit();
	}

	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/CSOZBS/z4/weapons/schands/v_hkmp5.mdl" );
		g_Game.PrecacheModel( "models/CSOZBS/z4/weapons/w_hkmp5.mdl" );
		g_Game.PrecacheModel( "models/CSOZBS/z4/weapons/p_hkmp5.mdl" );

		m_iShell = g_Game.PrecacheModel( "models/shell.mdl" );

		g_Game.PrecacheModel( "models/w_9mmarclip.mdl" );
		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav" );              

		//These are played by the model, needs changing there
		g_SoundSystem.PrecacheSound( "weapons/hk_mp5-1.wav" );

		g_SoundSystem.PrecacheSound( "weapons/hk_mp5_clipout1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/hk_mp5_clipout2.wav" );
		g_SoundSystem.PrecacheSound( "weapons/hk_mp5_draw.wav" );

		g_SoundSystem.PrecacheSound( "hl/weapons/357_cock1.wav" );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= HMP5_MAX_AMMO;
		info.iMaxAmmo2 	= -1;
		info.iMaxClip 	= HMP5_MAX_CLIP;
		info.iSlot 		= 1;
		info.iPosition 	= 6;
		info.iFlags 	= 0;
		info.iWeight 	= HMP5_WEIGHT;

		return true;
	}

	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer( pPlayer ) == true )
		{
			NetworkMessage message( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				message.WriteLong( self.m_iId );
			message.End();
			return true;
		}
		
		return false;
	}
	
	CBasePlayer@ getPlayer()
	{
		CBaseEntity@ e_plr = self.m_hPlayer;
		return cast<CBasePlayer@>(e_plr);
	}
	
	bool PlayEmptySound()
	{
		if( self.m_bPlayEmptySound )
		{
			self.m_bPlayEmptySound = false;
			
			g_SoundSystem.EmitSoundDyn( getPlayer().edict(), CHAN_WEAPON, "hl/weapons/357_cock1.wav", 0.8, ATTN_NORM, 0, PITCH_NORM );
		}
		
		return false;
	}

	bool Deploy()
	{
		return self.DefaultDeploy( self.GetV_Model( "models/CSOZBS/z4/weapons/schands/v_hkmp5.mdl" ), self.GetP_Model( "models/CSOZBS/z4/weapons/p_hkmp5.mdl" ), HMP5_DRAW, "uzis" );
	}
	
	float WeaponTimeBase()
	{
		return g_Engine.time; //g_WeaponFuncs.WeaponTimeBase();
	}

	void PrimaryAttack()
	{
		// don't fire underwater
		if( getPlayer().pev.waterlevel == WATERLEVEL_HEAD )
		{
			self.PlayEmptySound( );
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.08;
			return;
		}

		if( self.m_iClip <= 0 )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.08;
			return;
		}

		getPlayer().m_szAnimExtension = "uzis";

		getPlayer().m_iWeaponVolume = NORMAL_GUN_VOLUME;
		getPlayer().m_iWeaponFlash = NORMAL_GUN_FLASH;

		--self.m_iClip;
		
		switch ( g_PlayerFuncs.SharedRandomLong( getPlayer().random_seed, 0, 1 ) )
		{
			case 0: self.SendWeaponAnim( HMP5_SHOOTL1, 0, 0 ); break;
			case 1: self.SendWeaponAnim( HMP5_SHOOTR1, 0, 0 ); break;
		}
		
		g_SoundSystem.EmitSoundDyn( getPlayer().edict(), CHAN_WEAPON, "weapons/hk_mp5-1.wav", 1.0, ATTN_NORM, 0, 95 + Math.RandomLong( 0, 10 ) );

		Vector vecSrc	 = getPlayer().GetGunPosition();
		Vector vecAiming = getPlayer().GetAutoaimVector( AUTOAIM_5DEGREES );
		
		// JonnyBoy0719: Added custom bullet damage.
		int m_iBulletDamage = 15;
		// JonnyBoy0719: End
		
		// optimized multiplayer. Widened to make it easier to hit a moving player
		getPlayer().FireBullets( 4, vecSrc, vecAiming, VECTOR_CONE_6DEGREES, 8192, BULLET_PLAYER_CUSTOMDAMAGE, 2, m_iBulletDamage );

		if( self.m_iClip == 0 && getPlayer().m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			// HEV suit - indicate out of ammo condition
			getPlayer().SetSuitUpdate( "!HEV_AMO0", false, 0 );
			
		getPlayer().pev.punchangle.x = Math.RandomLong( -3, 2 );

		self.m_flNextPrimaryAttack = self.m_flNextPrimaryAttack + 0.08;
		if( self.m_flNextPrimaryAttack < WeaponTimeBase() )
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.08;

		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( getPlayer().random_seed,  10, 15 );
		
		TraceResult tr;
		
		float x, y;
		
		g_Utility.GetCircularGaussianSpread( x, y );
		
		Vector vecDir = vecAiming 
						+ x * VECTOR_CONE_6DEGREES.x * g_Engine.v_right 
						+ y * VECTOR_CONE_6DEGREES.y * g_Engine.v_up;

		Vector vecEnd	= vecSrc + vecDir * 4096;

		g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, getPlayer().edict(), tr );
		
		if( tr.flFraction < 1.0 )
		{
			if( tr.pHit !is null )
			{
				CBaseEntity@ pHit = g_EntityFuncs.Instance( tr.pHit );
				
				if( pHit is null || pHit.IsBSPModel() == true )
					g_WeaponFuncs.DecalGunshot( tr, BULLET_PLAYER_MP5 );
			}
		}
	}

	void Reload()
	{
		self.DefaultReload( HMP5_MAX_CLIP, HMP5_RELOAD, 3.15, 0 );

		//Set 3rd person reloading animation -Sniper
		BaseClass.Reload();
	}

	void WeaponIdle()
	{
		self.ResetEmptySound();

		getPlayer().GetAutoaimVector( AUTOAIM_5DEGREES );

		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;

		self.SendWeaponAnim( HMP5_IDLE );

		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( getPlayer().random_seed,  10, 15 );// how long till we do this again.
	}
}

string GetWeaponName_HMP5()
{
	return "weapon_hkmp5";
}

void RegisterWeapon_HMP5()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "weapon_hkmp5", GetWeaponName_HMP5() );
	g_ItemRegistry.RegisterWeapon( GetWeaponName_HMP5(), "wpn", "9mm" );
}
