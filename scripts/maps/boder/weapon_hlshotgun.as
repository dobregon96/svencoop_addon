/* 
* The original Half-Life version of the shotgun
*/

// special deathmatch shotgun spreads
const Vector VECTOR_CONE_DM_SHOTGUN( 0.08716, 0.04362, 0.00  );		// 10 degrees by 5 degrees
const Vector VECTOR_CONE_DM_DOUBLESHOTGUN( 0.17365, 0.04362, 0.00 ); 	// 20 degrees by 5 degrees

const int SHOTGUN_DEFAULT_AMMO 	= 10;
const int SHOTGUN_MAX_CARRY 	= 50;
const int SHOTGUN_MAX_CLIP 		= WEAPON_NOCLIP;
const int SHOTGUN_WEIGHT 		= 15;

const uint SHOTGUN_SINGLE_PELLETCOUNT = 13;
const uint SHOTGUN_DOUBLE_PELLETCOUNT = SHOTGUN_SINGLE_PELLETCOUNT * 3;

enum ShotgunAnimation
{
	SHOTGUN_IDLE = 0,
	SHOTGUN_DRAW,
	SHOTGUN_FIRE
};

class weapon_hlshotgun : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	
	int m_iShell;
	float m_flPumpTime;
	bool m_fPlayPumpSound;

	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/scmod/weapons/ut99/flak/w_flak.mdl" );
		
		self.m_iDefaultAmmo = SHOTGUN_DEFAULT_AMMO;

		self.FallInit();// get ready to fall
	}

	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/scmod/weapons/ut99/flak/v_flak.mdl" );
		g_Game.PrecacheModel( "models/scmod/weapons/ut99/flak/w_flak.mdl" );
		g_Game.PrecacheModel( "models/scmod/weapons/ut99/flak/p_flak.mdl" );

		m_iShell = g_Game.PrecacheModel( "models/scmod/weapons/ut99/flak/flakshell.mdl" );// shotgun shell

		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav" );              

		g_SoundSystem.PrecacheSound( "scmod/weapons/ut99/sbarrel2.ogg" );//shotgun
		g_SoundSystem.PrecacheSound( "scmod/weapons/ut99/sbarrel1.ogg" );//shotgun

		g_SoundSystem.PrecacheSound( "hl/weapons/reload1.wav" );	// shotgun reload
		g_SoundSystem.PrecacheSound( "hl/weapons/reload3.wav" );	// shotgun reload

		g_SoundSystem.PrecacheSound( "scmod/weapons/ut99/gunpickup2.wav" ); // Shotgun deploy sound
		g_SoundSystem.PrecacheSound( "xad/oldriflepickup.wav" ); // Shotgun deploy sound
		
		g_SoundSystem.PrecacheSound("weapons/sshell1.wav");	// shotgun reload
		g_SoundSystem.PrecacheSound("weapons/sshell3.wav");	// shotgun reload
		
		g_SoundSystem.PrecacheSound( "hl/weapons/357_cock1.wav" ); // gun empty sound
		g_SoundSystem.PrecacheSound( "scmod/weapons/ut99/scock2.ogg" ); // Shotgun deploy sound
	}

	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if ( !BaseClass.AddToPlayer( pPlayer ) )
			return false;
			
		@m_pPlayer = pPlayer;
		
		NetworkMessage message( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
			message.WriteLong( self.m_iId );
		message.End();
		
		return true;
	}
	
	bool PlayEmptySound()
	{
		if( self.m_bPlayEmptySound )
		{
			self.m_bPlayEmptySound = false;
			
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "hl/weapons/357_cock1.wav", 0.8, ATTN_NORM, 0, PITCH_NORM );
		}
		
		return false;
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= SHOTGUN_MAX_CARRY;
		info.iMaxAmmo2 	= -1;
		info.iMaxClip 	= SHOTGUN_MAX_CLIP;
		info.iSlot 		= 3;
		info.iPosition 	= 8;
		info.iFlags 	= 0;
		info.iWeight 	= SHOTGUN_WEIGHT;

		return true;
	}

	bool Deploy()
	{
		return self.DefaultDeploy( self.GetV_Model( "models/scmod/weapons/ut99/flak/v_flak.mdl" ), self.GetP_Model( "models/scmod/weapons/ut99/flak/p_flak.mdl" ), SHOTGUN_DRAW, "shotgun" );
	}

	float WeaponTimeBase()
	{
		return g_Engine.time;
	}
	
	void Holster( int skipLocal = 0 )
	{
		
		BaseClass.Holster( skipLocal );
	}

	void ItemPostFrame()
	{
		if( m_flPumpTime != 0 && m_flPumpTime < g_Engine.time && m_fPlayPumpSound )
		{
			// play pumping sound
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_ITEM, "scmod/weapons/ut99/scock2.ogg", 1, ATTN_NORM, 0, 95 + Math.RandomLong( 0,0x1f ) );

			m_fPlayPumpSound = false;
		}

		BaseClass.ItemPostFrame();
	}
	
	void CreatePelletDecals( const Vector& in vecSrc, const Vector& in vecAiming, const Vector& in vecSpread, const uint uiPelletCount )
	{
		TraceResult tr;
		
		float x, y;
		
		for( uint uiPellet = 0; uiPellet < uiPelletCount; ++uiPellet )
		{
			g_Utility.GetCircularGaussianSpread( x, y );
			
			Vector vecDir = vecAiming 
							+ x * vecSpread.x * g_Engine.v_right 
							+ y * vecSpread.y * g_Engine.v_up;

			Vector vecEnd	= vecSrc + vecDir * 2048;
			
			g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );
			
			if( tr.flFraction < 1.0 )
			{
				if( tr.pHit !is null )
				{
					CBaseEntity@ pHit = g_EntityFuncs.Instance( tr.pHit );
					
					if( pHit is null || pHit.IsBSPModel() )
						g_WeaponFuncs.DecalGunshot( tr, BULLET_PLAYER_BUCKSHOT );
				}
			}
		}
	}

	void PrimaryAttack()
	{
		
		// don't fire underwater
		if( m_pPlayer.pev.waterlevel == WATERLEVEL_HEAD )
		{
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = g_Engine.time + 0.15;
			return;
		}
		
		if( self.pev.iuser1 == 1)
        {
		    Deploy();
			return;
        }

		if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
		{
			self.PlayEmptySound();
			return;
		}
		
		self.SendWeaponAnim( SHOTGUN_FIRE, 0, 0 );
		
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "scmod/weapons/ut99/sbarrel1.ogg", Math.RandomFloat( 0.98, 1.0 ), ATTN_NORM, 0, 85 + Math.RandomLong( 0, 0x1f ) );

		m_pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = NORMAL_GUN_FLASH;

		m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) - 1 );

		// player "shoot" animation
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );

		Vector vecSrc	 = m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
		
		m_pPlayer.FireBullets( 20, vecSrc, vecAiming, VECTOR_CONE_DM_DOUBLESHOTGUN, 2048, BULLET_PLAYER_BUCKSHOT, 0 );
		m_pPlayer.pev.punchangle.x = -10.0;
				
		if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			// HEV suit - indicate out of ammo condition
			m_pPlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );
			

		if (m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) != 0)
//			m_flPumpTime = g_Engine.time + 0.95;

		self.m_flNextPrimaryAttack = g_Engine.time + 1.5;
		self.m_flNextSecondaryAttack = g_Engine.time + 1.5;
		
		if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) != 0 )
			self.m_flTimeWeaponIdle = g_Engine.time + 6.0;
		else
			self.m_flTimeWeaponIdle = g_Engine.time + 1.5;
					
		CreatePelletDecals( vecSrc, vecAiming, VECTOR_CONE_DM_DOUBLESHOTGUN, SHOTGUN_DOUBLE_PELLETCOUNT );

	}
	
	void SecondaryAttack()
	{
		
		if( self.pev.iuser1 == 1)
        {
		    Deploy();
			return;
        }

		if ( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
		{
			self.PlayEmptySound();
			return;
		}

        m_pPlayer.m_iWeaponVolume = LOUD_GUN_VOLUME;
        m_pPlayer.m_iWeaponFlash = NORMAL_GUN_FLASH;

        // player "shoot" animation
        m_pPlayer.SetAnimation( PLAYER_ATTACK1 );

		self.SendWeaponAnim( SHOTGUN_FIRE );

		m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) - 1 );

		g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, "scmod/weapons/ut99/sbarrel2.ogg", 1, ATTN_NORM );

        Math.MakeVectors( m_pPlayer.pev.v_angle + m_pPlayer.pev.punchangle );

		// we don't add in player velocity anymore.
		if( ( m_pPlayer.pev.button & IN_DUCK ) != 0 )
		{
			g_EntityFuncs.ShootContact( m_pPlayer.pev, 
								m_pPlayer.pev.origin + g_Engine.v_forward * 16 + g_Engine.v_right * 6, 
								g_Engine.v_forward * 900 ); //800
		}
		else
		{
			g_EntityFuncs.ShootContact( m_pPlayer.pev, 
								m_pPlayer.pev.origin + m_pPlayer.pev.view_ofs * 0.5 + g_Engine.v_forward * 16 + g_Engine.v_right * 6, 
								g_Engine.v_forward * 900 ); //800
		}

        g_EngineFuncs.MakeVectors( m_pPlayer.pev.v_angle );

        self.m_flNextPrimaryAttack =  g_Engine.time + 1.5;
        self.m_flNextSecondaryAttack =  g_Engine.time + 1.5;
	}
	
	void WeaponIdle()
	{
		m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
			
	}
}

string GetHLShotgunName()
{
	return "weapon_hlshotgun";
}

void RegisterHLShotgun()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "weapon_hlshotgun", GetHLShotgunName() );
	g_ItemRegistry.RegisterWeapon( GetHLShotgunName(), "scmod/ut99", "ARgrenades" );
}
