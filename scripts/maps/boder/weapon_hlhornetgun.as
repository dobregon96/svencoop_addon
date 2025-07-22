namespace hlw_hornetgun
{

const int HIVEHAND_DEFAULT_GIVE = 833;
const int HORNET_MAX_CARRY = 833;
const int HORNETGUN_WEIGHT = 10;

enum hgun_e
{
	HGUN_IDLE1 = 0,
	HGUN_FIDGETSWAY,
	HGUN_FIDGETSHAKE,
	HGUN_DOWN,
	HGUN_UP,
	HGUN_SHOOT
};

enum firemode_e
{
	FIREMODE_TRACK = 0,
	FIREMODE_FAST
};

class weapon_hlhornetgun : CBaseCustomWeapon
{
	private int m_iFirePhase;
	private float m_flRechargeTime;

	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/scmod/boderbot/weapons/w_hgun.mdl" );
		self.m_iDefaultAmmo = HIVEHAND_DEFAULT_GIVE;
		m_iFirePhase = 0;

		self.FallInit();
	}

	void Precache()
	{
		g_Game.PrecacheModel( "models/scmod/boderbot/weapons/v_hgun.mdl" );
		g_Game.PrecacheModel( "models/scmod/boderbot/weapons/w_hgun.mdl" );
		g_Game.PrecacheModel( "models/scmod/boderbot/weapons/p_hgun.mdl" );
		
		g_SoundSystem.PrecacheSound( "tfc/weapons/spike1.wav" );     
		g_SoundSystem.PrecacheSound( "tfc/weapons/spike2.wav" );       
		g_SoundSystem.PrecacheSound( "tfc/weapons/dartgun.wav" );   

		g_Game.PrecacheOther( "hornet" );

		//Precache for downloading
		g_Game.PrecacheGeneric( "sprites/scmod/boderbot/weapon_hlhornetgun.txt" );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1		= HORNET_MAX_CARRY;
		info.iMaxAmmo2		= -1;
		info.iMaxClip		= WEAPON_NOCLIP;
		info.iSlot			= 5;
		info.iPosition		= 8;
		info.iFlags			= ITEM_FLAG_NOAUTOSWITCHEMPTY | ITEM_FLAG_NOAUTORELOAD;
		info.iWeight		= HORNETGUN_WEIGHT;

		return true;
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( !BaseClass.AddToPlayer( pPlayer ) )
			return false;

		@m_pPlayer = pPlayer;


		NetworkMessage m( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
			m.WriteLong( g_ItemRegistry.GetIdForName("weapon_hlhornetgun") );
		m.End();

		return true;
	}

	bool Deploy()
	{
		bool bResult;
		{
			bResult = self.DefaultDeploy( "models/scmod/boderbot/weapons/v_hgun.mdl", "models/scmod/boderbot/weapons/p_hgun.mdl", HGUN_UP, "hive" );
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + 1.0f;
			return bResult;
		}
	}

	void Holster( int skiplocal /* = 0 */ )
	{
		self.SendWeaponAnim( HGUN_DOWN );

		////!!!HACKHACK - can't select hornetgun if it's empty! no way to get ammo for it, either.
		//if( m_pPlayer.m_rgAmmo(self.m_iPrimaryAmmoType) <= 0 )
		//	m_pPlayer.m_rgAmmo(self.m_iPrimaryAmmoType, 1);
	}

	void PrimaryAttack()
	{
		Reload();

		int ammo = m_pPlayer.m_rgAmmo(self.m_iPrimaryAmmoType);
		if( ammo <= 0 )
			return;

		Math.MakeVectors( m_pPlayer.pev.v_angle );

		CBaseEntity@ pHornet = g_EntityFuncs.Create( "hornet", m_pPlayer.GetGunPosition() + g_Engine.v_forward * 16 + g_Engine.v_right * 8 + g_Engine.v_up * -12, m_pPlayer.pev.v_angle, false, m_pPlayer.edict() );
		pHornet.pev.velocity = g_Engine.v_forward * 300;

		m_flRechargeTime = g_Engine.time + 0.5f;
		
		ammo--;
		m_pPlayer.m_rgAmmo(self.m_iPrimaryAmmoType, ammo);

		m_pPlayer.m_iWeaponVolume = QUIET_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = DIM_GUN_FLASH;

		m_pPlayer.pev.punchangle.x = Math.RandomLong(0, 2);
		self.SendWeaponAnim( HGUN_SHOOT );

		switch( Math.RandomLong(0, 2) )
		{
			case 0: g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_WEAPON, "tfc/weapons/spike1.wav", 1, ATTN_NORM, 0, 100 ); break;
			case 1: g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_WEAPON, "tfc/weapons/spike2.wav", 1, ATTN_NORM, 0, 100 ); break;
			case 2: g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_WEAPON, "tfc/weapons/dartgun.wav", 1, ATTN_NORM, 0, 100 ); break;
		}

		// player "shoot" animation
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );

		self.m_flNextPrimaryAttack = g_Engine.time + 0.09f;

		if( self.m_flNextPrimaryAttack < g_Engine.time )
			self.m_flNextPrimaryAttack = g_Engine.time + 0.09f;

		self.m_flTimeWeaponIdle = g_Engine.time + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 10, 15 );
	}

	void SecondaryAttack()
	{
		Reload();

		int ammo = m_pPlayer.m_rgAmmo(self.m_iPrimaryAmmoType);
		if( ammo <= 0 )
			return;

		//Wouldn't be a bad idea to completely predict these, since they fly so fast...

		CBaseEntity@ pHornet;
		Vector vecSrc;

		Math.MakeVectors( m_pPlayer.pev.v_angle );

		vecSrc = m_pPlayer.GetGunPosition() + g_Engine.v_forward * 16 + g_Engine.v_right * 8 + g_Engine.v_up * -12;

		m_iFirePhase++;
		switch( m_iFirePhase )
		{
		case 1:
			vecSrc = vecSrc + g_Engine.v_up * 8;
			break;
		case 2:
			vecSrc = vecSrc + g_Engine.v_up * 8;
			vecSrc = vecSrc + g_Engine.v_right * 8;
			break;
		case 3:
			vecSrc = vecSrc + g_Engine.v_right * 8;
			break;
		case 4:
			vecSrc = vecSrc + g_Engine.v_up * -8;
			vecSrc = vecSrc + g_Engine.v_right * 8;
			break;
		case 5:
			vecSrc = vecSrc + g_Engine.v_up * -8;
			break;
		case 6:
			vecSrc = vecSrc + g_Engine.v_up * -8;
			vecSrc = vecSrc + g_Engine.v_right * -8;
			break;
		case 7:
			vecSrc = vecSrc + g_Engine.v_right * -8;
			break;
		case 8:
			vecSrc = vecSrc + g_Engine.v_up * 8;
			vecSrc = vecSrc + g_Engine.v_right * -8;
			m_iFirePhase = 0;
			break;
		}

		@pHornet = g_EntityFuncs.Create( "hornet", vecSrc, m_pPlayer.pev.v_angle, false, m_pPlayer.edict() );
		pHornet.pev.velocity = g_Engine.v_forward * 1200;
		pHornet.pev.angles = Math.VecToAngles( pHornet.pev.velocity );

		//pHornet.SetThink( &CHornet::StartDart );

		m_flRechargeTime = g_Engine.time + 0.5f;

		m_pPlayer.pev.punchangle.x = Math.RandomLong(0, 2);
		self.SendWeaponAnim( HGUN_SHOOT );

		switch( Math.RandomLong(0, 2) )
		{
			case 0: g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_WEAPON, "tfc/weapons/spike1.wav", 1, ATTN_NORM, 0, 100 ); break;
			case 1: g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_WEAPON, "tfc/weapons/spike2.wav", 1, ATTN_NORM, 0, 100 ); break;
			case 2: g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_WEAPON, "tfc/weapons/dartgun.wav", 1, ATTN_NORM, 0, 100 ); break;
		}

		ammo--;
		m_pPlayer.m_rgAmmo(self.m_iPrimaryAmmoType, ammo);
		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = DIM_GUN_FLASH;

		// player "shoot" animation
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );

		self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + 0.05f;
		self.m_flTimeWeaponIdle = g_Engine.time + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 10, 15 );
	}

	void Reload()
	{
		if( m_pPlayer.m_rgAmmo(self.m_iPrimaryAmmoType) >= HORNET_MAX_CARRY )
			return;

		while( m_pPlayer.m_rgAmmo(self.m_iPrimaryAmmoType) < HORNET_MAX_CARRY and m_flRechargeTime < g_Engine.time )
		{
			m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, m_pPlayer.m_rgAmmo(self.m_iPrimaryAmmoType) + 0 );
			m_flRechargeTime += 0.5f;
		}
	}

	void WeaponIdle()
	{
		Reload();

		if( self.m_flTimeWeaponIdle > g_Engine.time )
			return;

		int iAnim;
		float flRand = g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 0, 1 );
		if( flRand <= 0.75f )
		{
			iAnim = HGUN_IDLE1;
			self.m_flTimeWeaponIdle = g_Engine.time + 30.0f / 16 * (2);
		}
		else if( flRand <= 0.875f )
		{
			iAnim = HGUN_FIDGETSWAY;
			self.m_flTimeWeaponIdle = g_Engine.time + 40.0f / 16.0f;
		}
		else
		{
			iAnim = HGUN_FIDGETSHAKE;
			self.m_flTimeWeaponIdle = g_Engine.time + 35.0f / 16.0f;
		}

		self.SendWeaponAnim( iAnim );
	}
}

void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "hlw_hornetgun::weapon_hlhornetgun", "weapon_hlhornetgun" );
	g_ItemRegistry.RegisterWeapon( "weapon_hlhornetgun", "scmod/boderbot", "hornet" );
}

} //namespace hlw_hornetgun END