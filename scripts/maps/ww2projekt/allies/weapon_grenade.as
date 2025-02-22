enum MK2GRENADEAnimation_e
{
	MK2GRENADE_IDLE = 0,
	MK2GRENADE_DRAW,
	MK2GRENADE_PINPULL,
	MK2GRENADE_HOLSTER,
	MK2GRENADE_THROW,
	MK2GRENADE_E_IDLE,
	MK2GRENADE_E_DRAW,
	MK2GRENADE_E_PINPULL,
	MK2GRENADE_E_THROW
};

const int MK2GRENADE_DEFAULT_GIVE	= 5;
const int MK2GRENADE_MAX_CARRY		= 10;
const int MK2GRENADE_WEIGHT			= 30;
const int MK2GRENADE_DAMAGE			= 163;

class weapon_grenade : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	float m_flStartThrow;
	float m_flReleaseThrow;
	CBaseEntity@ pGrenade;
	
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/ww2projekt/grenade/w_grenade.mdl" );
		
		self.m_iDefaultAmmo = MK2GRENADE_DEFAULT_GIVE;
		m_flReleaseThrow = -1.0f;
		m_flStartThrow = 0;

		self.KeyValue( "m_flCustomRespawnTime", 1 ); //fgsfds
		
		self.FallInit();
	}
	
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheModel( "models/ww2projekt/grenade/w_grenade.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/grenade/v_grenade.mdl" );
		g_Game.PrecacheModel( "models/ww2projekt/grenade/p_grenade.mdl" );
		
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/rifleselect.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/grenpinpull.wav" );
		g_Game.PrecacheGeneric( "sound/" + "weapons/ww2projekt/grenthrow.wav" );
		
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/rifleselect.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/grenpinpull.wav" );
		g_SoundSystem.PrecacheSound( "weapons/ww2projekt/grenthrow.wav" );
		
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/americans_selection.spr" );
		g_Game.PrecacheGeneric( "sprites/" + "ww2projekt/weapon_grenade.txt" );
	}
	
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer( pPlayer ) )
		{
			@m_pPlayer = pPlayer;
			NetworkMessage allies10( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				allies10.WriteLong( g_ItemRegistry.GetIdForName("weapon_grenade") );
			allies10.End();
			return true;
		}
		return false;
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= MK2GRENADE_MAX_CARRY;
		info.iMaxAmmo2 	= -1;
		info.iMaxClip 	= WEAPON_NOCLIP;
		info.iSlot 		= 4;
		info.iPosition 	= 9;
		info.iWeight 	= MK2GRENADE_WEIGHT;
		info.iFlags 	= ITEM_FLAG_LIMITINWORLD | ITEM_FLAG_EXHAUSTIBLE | ITEM_FLAG_ESSENTIAL;

		return true;
	}

	CBasePlayerItem@ DropItem() // Doesn't let the player drop the weapon
	{
		return null;
	}

	//fgsfds
	void Materialize()
	{
		BaseClass.Materialize();
		SetTouch( TouchFunction( CustomTouch ) );
	}

	void CustomTouch( CBaseEntity@ pOther )
	{
		if( !pOther.IsPlayer() )
			return;

		CBasePlayer@ pPlayer = cast<CBasePlayer@>(pOther);

		if( pPlayer.HasNamedPlayerItem("weapon_grenade") !is null )
		{
			if( pPlayer.GiveAmmo( MK2GRENADE_DEFAULT_GIVE, "weapon_grenade", MK2GRENADE_MAX_CARRY ) != -1 )
			{
				self.CheckRespawn();
				g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, "items/9mmclip1.wav", 1, ATTN_NORM );
				g_EntityFuncs.Remove( self );
			}
			return;
		}
		else if( pPlayer.AddPlayerItem( self ) != APIR_NotAdded )
		{
			self.AttachToPlayer( pPlayer );
			g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, "items/gunpickup2.wav", 1, ATTN_NORM );
		}
	}
	//fgsfds

	float WeaponTimeBase()
	{
		return g_Engine.time;
	}
	
	bool Deploy()
	{
		bool bResult;
		{
			m_flReleaseThrow = -1;
			bResult = self.DefaultDeploy( self.GetV_Model( "models/ww2projekt/grenade/v_grenade.mdl" ), self.GetP_Model( "models/ww2projekt/grenade/p_grenade.mdl" ), MK2GRENADE_DRAW, "gren" );

			float deployTime = 0.87;
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + deployTime;
			return bResult;
		}
	}
	
	bool CanHolster()
	{
		// can only holster hand grenades when not primed!
		return ( m_flStartThrow == 0 );
	}
	
	bool CanDeploy()
	{
		return m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType) != 0;
	}
	
	void DestroyThink()
	{
		self.DestroyItem();
	}
	
	void Holster( int skiplocal )
	{
		self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.5f;
		self.m_flNextSecondaryAttack = WeaponTimeBase() + 0.5f;
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 0.5f;

		if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) == 0 )
		{
			m_pPlayer.pev.weapons &= ~( 0 << g_ItemRegistry.GetIdForName("weapon_grenade") );
			self.SendWeaponAnim( MK2GRENADE_HOLSTER );
			SetThink( ThinkFunction( DestroyThink ) ); //Fixes recursion
			self.pev.nextthink = g_Engine.time + 0.1;
		}
		m_flStartThrow = 0;
		m_flReleaseThrow = -1.0f;

		BaseClass.Holster( skiplocal );
	}
	
	void PrimaryAttack()
	{
		if( m_flStartThrow == 0 && m_pPlayer.m_rgAmmo ( self.m_iPrimaryAmmoType ) > 0 )
		{
			m_flReleaseThrow = 0;
			m_flStartThrow = g_Engine.time;
		
			self.SendWeaponAnim( MK2GRENADE_PINPULL );
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 1;
		}
	}
	
	void WeaponIdle()
	{
		if ( m_flReleaseThrow == 0 && m_flStartThrow > 0.0 )
			m_flReleaseThrow = g_Engine.time;

		if ( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;

		if ( m_flStartThrow > 0.0 )
		{
			Vector angThrow = m_pPlayer.pev.v_angle + m_pPlayer.pev.punchangle;

			if ( angThrow.x < 0 )
				angThrow.x = -10 + angThrow.x * ( ( 90 - 10 ) / 90.0 );
			else
				angThrow.x = -10 + angThrow.x * ( ( 90 + 10 ) / 90.0 );

			float flVel = ( 90.0f - angThrow.x ) * 6;

			if ( flVel > 750.0f )
				flVel = 750.0f;

			Math.MakeVectors ( angThrow );

			Vector vecSrc = m_pPlayer.pev.origin + m_pPlayer.pev.view_ofs + g_Engine.v_forward * 16;
			Vector vecThrow = g_Engine.v_forward * flVel + m_pPlayer.pev.velocity;

			// always explode 3 seconds after the pin was pulled
			float time = m_flStartThrow - g_Engine.time + 4.5;
			if( time < 0 )
				time = 0;

			@pGrenade = g_EntityFuncs.ShootTimed( m_pPlayer.pev, vecSrc, vecThrow, time );
			g_EntityFuncs.SetModel( pGrenade, "models/ww2projekt/grenade/w_grenade.mdl" );
			
			//te_trail( pGrenade );
			pGrenade.pev.dmg = MK2GRENADE_DAMAGE;

			if ( flVel < 500 )
			{
				self.SendWeaponAnim ( MK2GRENADE_THROW );
			}
			else if ( flVel < 1000 )
			{
				self.SendWeaponAnim ( MK2GRENADE_THROW );
			}
			else
			{
				self.SendWeaponAnim ( MK2GRENADE_THROW );
			}

			// player "shoot" animation
			m_pPlayer.SetAnimation( PLAYER_ATTACK1 );

			m_flReleaseThrow = g_Engine.time;
			m_flStartThrow = 0;
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.5;
			self.m_flTimeWeaponIdle = WeaponTimeBase() + 0.4;

			m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) - 1 );

			if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) == 0 )
			{
				// just threw last grenade
				// set attack times in the future, and weapon idle in the future so we can see the whole throw
				// animation, weapon idle will automatically retire the weapon for us.
				self.m_flTimeWeaponIdle = self.m_flNextSecondaryAttack = self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.4;
			}
			return;
		}
		else if( m_flReleaseThrow > 0 )
		{
			m_flStartThrow = 0;

			if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) > 0 )
			{
				self.SendWeaponAnim( MK2GRENADE_DRAW );
			}
			else
			{
				self.RetireWeapon();
				return;
			}

			self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 10, 15 );
			m_flReleaseThrow = -1;
			return;
		}

		if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) > 0 )
		{
			int iAnim;
			float flRand = g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 0, 1 );
			if( flRand <= 1.0 )
			{
				self.SendWeaponAnim( MK2GRENADE_IDLE );
				self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed, 10, 15 );
			}
		}
	}
}

string GetMK2GRENADEName()
{
	return "weapon_grenade";
}

void RegisterMK2GRENADE()
{
	g_CustomEntityFuncs.RegisterCustomEntity( GetMK2GRENADEName(), GetMK2GRENADEName() );
	g_ItemRegistry.RegisterWeapon( GetMK2GRENADEName(), "ww2projekt", "weapon_grenade" );
}