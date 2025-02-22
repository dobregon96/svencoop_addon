enum PanzerschreckAnimation_e
{
	PANZERS_IDLE = 0,
	PANZERS_DRAW,
	PANZERS_AIMED,
	PANZERS_LAUNCH,
	PANZERS_DOWNTOUP,
	PANZERS_UPTODOWN,
	PANZERS_RELOAD_AIMED,
	PANZERS_RELOAD_IDLE
};

const int PANZERS_DEFAULT_GIVE		= 2;
const int PANZERS_MAX_CARRY			= 5;
const int PANZERS_MAX_CLIP			= 1;
const int PANZERS_WEIGHT			= 50;

class weapon_panzerschreck : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	int g_iCurrentMode;
	CBaseEntity@ pRocket;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/ww2projekt/panzerschreck/w_pschreck.mdl" );
		
		self.m_iDefaultAmmo = PANZERS_DEFAULT_GIVE;
		
		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/ww2projekt/panzerschreck/w_pschreck.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/panzerschreck/w_pschreck_rocket.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/panzerschreck/v_panzerschreck.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/panzerschreck/p_pschreck.mdl" );
		
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/rocket1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/bazookadeploy.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/bazookareloadgetrocket.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/bazookareloadrocketin.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/bazookareloadshovehome.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/bazookapickup.wav" );
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/rocket1.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/bazookadeploy.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/bazookareloadgetrocket.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/bazookareloadrocketin.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/bazookareloadshovehome.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/bazookapickup.wav" );
		g_SoundSystem.PrecacheSound( "weapons/357_cock1.wav" );
		
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/germans_selection.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/weapon_panzerschreck.txt" );
	}
	
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1	= PANZERS_MAX_CARRY;
		info.iMaxAmmo2	= -1;
		info.iMaxClip	= PANZERS_MAX_CLIP;
		info.iSlot		= 4;
		info.iPosition	= 6;
		info.iFlags		= ITEM_FLAG_NOAUTORELOAD;
		info.iWeight	= PANZERS_WEIGHT;
		
		return true;
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer( pPlayer ) )
		{
			@m_pPlayer = pPlayer;
			NetworkMessage axis12( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				axis12.WriteLong( g_ItemRegistry.GetIdForName("weapon_panzerschreck") );
			axis12.End();
			return true;
		}
		
		return false;
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

	float WeaponTimeBase()
	{
		return g_Engine.time;
	}

	bool Deploy()
	{
		bool bResult;
		{
			bResult = self.DefaultDeploy( self.GetV_Model( "models/ww2projekt/panzerschreck/v_panzerschreck.mdl" ), self.GetP_Model( "models/ww2projekt/panzerschreck/p_pschreck.mdl" ), PANZERS_DRAW, "rpg" );

			float deployTime = 1.17f;
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + deployTime;
			return bResult;
		}
	}

	void Holster( int skipLocal = 0 ) 
	{
		self.m_fInReload = false;

		g_iCurrentMode = NotInShoulder;
		m_pPlayer.pev.maxspeed = 0;

		BaseClass.Holster( skipLocal );
	}

	void PrimaryAttack()
	{
		if( g_iCurrentMode == InShoulder )
		{
			if( m_pPlayer.pev.waterlevel == WATERLEVEL_HEAD )
			{
				self.PlayEmptySound();
				self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;
				return;
			}
		
			if( self.m_iClip <= 0 )
			{
				self.PlayEmptySound();
				self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15f;
				return;
			}
		
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.2;
		
			m_pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
			m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		
			--self.m_iClip;
		
			m_pPlayer.pev.effects |= EF_MUZZLEFLASH;
			m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		
			self.SendWeaponAnim( PANZERS_LAUNCH );

			m_pPlayer.pev.punchangle.x -= 4;
		
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "weapons/ww2projekt/rocket1.wav", 0.85, ATTN_NORM, 0, PITCH_NORM );
		
			Math.MakeVectors( m_pPlayer.pev.v_angle + m_pPlayer.pev.punchangle );
		
			@pRocket = g_EntityFuncs.CreateRPGRocket( m_pPlayer.GetGunPosition() + g_Engine.v_forward * 16 + g_Engine.v_right * 8 + g_Engine.v_up * -8, m_pPlayer.pev.v_angle, m_pPlayer.edict() );
			g_EntityFuncs.SetModel( pRocket, "models/ww2projekt/panzerschreck/w_pschreck_rocket.mdl" );
			
			pRocket.pev.dmg = 190; //projectile damage
			
			if( self.m_iClip == 0 && m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
				m_pPlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );
		}
		else if( g_iCurrentMode == NotInShoulder )
		{
			g_EngineFuncs.ClientPrintf( m_pPlayer, print_center, ROCKETDeploy );
		}
	}
	
	void SecondaryAttack()
	{
		self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.75;
		switch( g_iCurrentMode )
		{
			case NotInShoulder:
			{
				g_iCurrentMode = InShoulder;
				self.SendWeaponAnim( PANZERS_DOWNTOUP );
				m_pPlayer.pev.maxspeed = 160; //will lower your speed
				self.m_flTimeWeaponIdle = WeaponTimeBase() + 0.83f;
				break;
			}
			
			case InShoulder:
			{
				g_iCurrentMode = NotInShoulder;
				self.SendWeaponAnim( PANZERS_UPTODOWN );
				m_pPlayer.pev.maxspeed = 0;
				self.m_flTimeWeaponIdle = WeaponTimeBase() + 1.03f;
				break;
			}
		}
	}
	
	void Reload()
	{
		if( self.m_iClip == PANZERS_MAX_CLIP || m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			return;
		
		if( g_iCurrentMode == NotInShoulder )
		{
			self.DefaultReload( PANZERS_MAX_CLIP, PANZERS_RELOAD_IDLE, 3.55, 0 );
		}
		else if( g_iCurrentMode == InShoulder )
		{
			self.DefaultReload( PANZERS_MAX_CLIP, PANZERS_RELOAD_AIMED, 3.07, 0 );
		}
		BaseClass.Reload();
	}
	
	void WeaponIdle()
	{
		self.ResetEmptySound();

		m_pPlayer.GetAutoaimVector( AUTOAIM_10DEGREES );

		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;

		self.SendWeaponAnim( (g_iCurrentMode == InShoulder) ? PANZERS_AIMED : PANZERS_IDLE );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 10, 15 );
	}
}

string GetPANZERSName()
{
	return "weapon_panzerschreck";
}

void RegisterPANZERS()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetPANZERSName(), GetPANZERSName() );
	g_ItemRegistry.RegisterWeapon( GetPANZERSName(), "ww2projekt", "rockets" );
}