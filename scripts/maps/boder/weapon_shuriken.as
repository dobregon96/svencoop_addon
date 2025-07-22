/* 
 * Original Shuriken by Takkedeppo.50cal ..Ripper edit by Garompa
 */
#include "sns_effect"

namespace WEP_SHURIKEN {
    const int MAX_AMMO = 75;
    const int SUP_AMMO = 25;
    const string WEP_NAME  = "weapon_shuriken";
    const string AMMO_NAME = "ammo_shuriken";
    const string PROJ_NAME = "projectile_shuriken";
    
    enum motion_e {
        MOTION_IDLE = 0,
        MOTION_FIDGET,
        MOTION_THROW1,
        MOTION_THROW2,
        MOTION_THROW3,
        MOTION_HOLSTER,
        MOTION_DRAW
    };
    
}
class WeaponShuriken : ScriptBasePlayerWeaponEntity {
    private CBasePlayer@ m_pPlayer = null;
    
    private string vModel = "models/scmod/weapons/ut99/razor/v_shuriken.mdl";
    private string pModel = "models/scmod/weapons/ut99/razor/p_crossbow.mdl";
    private string wModel = "models/scmod/weapons/ut99/razor/w_crossbow.mdl";
    
    private string throwSoundFile = "scmod/weapons/ut99/razor_fire.ogg";
    private string throwSoundFile2 = "scmod/weapons/ut99/razor_fire2.ogg";
    
    void Spawn() {
        self.Precache();
        g_EntityFuncs.SetModel( self, self.GetW_Model( this.wModel) );
        //self.m_iDefaultAmmo = WEP_SHURIKEN::SUP_AMMO;
        self.m_iClip = -1;

        self.FallInit();// get ready to fall down.
    }

    void Precache() {
        self.PrecacheCustomModels();

        g_Game.PrecacheModel( this.vModel );
        g_Game.PrecacheModel( this.wModel );
        g_Game.PrecacheModel( this.pModel );

        g_SoundSystem.PrecacheSound( this.throwSoundFile );
        g_SoundSystem.PrecacheSound( this.throwSoundFile2 );

        // FOR THROWING
        g_Game.PrecacheModel( "models/scmod/weapons/ut99/crossbow_bolt.mdl" ); 
        g_Game.PrecacheModel("sprites/laserbeam.spr");
        g_SoundSystem.PrecacheSound("scmod/weapons/ut99/razor_hit.ogg");
        g_SoundSystem.PrecacheSound( "weapons/knife_hit_flesh2.wav");
        
        SnsEffect::Precache();
    }

    bool GetItemInfo( ItemInfo& out info ) {
        info.iMaxAmmo1      = WEP_SHURIKEN::MAX_AMMO;
        info.iMaxAmmo2      = -1;
        info.iMaxClip       = WEAPON_NOCLIP;
        info.iSlot          = 2;
        info.iPosition      = 6;
        info.iWeight        = 0;
        info.iFlags         = ITEM_FLAG_LIMITINWORLD | ITEM_FLAG_EXHAUSTIBLE;
        
        return true;
    }
    
    bool AddToPlayer( CBasePlayer@ pPlayer ) {
        if ( !BaseClass.AddToPlayer( pPlayer ) ) {
            return false;
        }
        @m_pPlayer = pPlayer;
        return true;
    }

    /** When the weapon is taken out or drawn out */
    bool Deploy() {
        return self.DefaultDeploy( self.GetV_Model( this.vModel ), self.GetP_Model( this.pModel ), WEP_SHURIKEN::MOTION_DRAW, "gauss" );
    }

    /** When holstered */
    void Holster( int skiplocal /* = 0 */ ) {
        self.m_fInReload = false;// cancel any reload in progress.

        m_pPlayer.m_flNextAttack = g_WeaponFuncs.WeaponTimeBase() + 0.5; 
        m_pPlayer.pev.viewmodel = "";
        
        // Ammoがなければ削除
        if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 ) {
            
            m_pPlayer.pev.weapons &= ~( 0 << g_ItemRegistry.GetIdForName(WEP_SHURIKEN::WEP_NAME) );
            SetThink( ThinkFunction( DestroyThink ) );
            self.pev.nextthink = g_Engine.time + 0.1;
        } else {
            SetThink( null );
        }
    }
    
    void DestroyThink() {
        self.DestroyItem();
    }
    
    
    /** reload */
    void Reload() {
        self.SendWeaponAnim( WEP_SHURIKEN::MOTION_DRAW );
        m_pPlayer.m_flNextAttack = g_WeaponFuncs.WeaponTimeBase() + 0.5; 
    }
    
    /** primary attack */
    void PrimaryAttack() {
        if (m_pPlayer.m_rgAmmo(self.m_iPrimaryAmmoType ) > 0) {
            m_pPlayer.pev.weaponmodel = this.pModel;
            ThrowCommon();
            SetThink(ThinkFunction(this.ThrowProj1));
        }
    }
    
    /** secondary attack */
    void SecondaryAttack() {
        if (m_pPlayer.m_rgAmmo(self.m_iPrimaryAmmoType ) > 0) {
            m_pPlayer.pev.weaponmodel = this.pModel;
            ThrowCommon2();
            SetThink(ThinkFunction(this.ThrowProj2));
        }
    }
    
    // Throw processing common
    private void ThrowCommon() {
        // random throwing motion
        int anim = Math.RandomLong(WEP_SHURIKEN::MOTION_THROW1, WEP_SHURIKEN::MOTION_THROW3);
        self.SendWeaponAnim(anim );
        
        m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
        self.pev.nextthink = g_WeaponFuncs.WeaponTimeBase() + 0.35;
        
        // buzzing sound
        g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "scmod/weapons/ut99/razor_fire.ogg", 1, ATTN_NORM, 0, 94 + Math.RandomLong( 0,0xF ) );
        
        m_pPlayer.m_flNextAttack = g_WeaponFuncs.WeaponTimeBase() + 0.35; 
        self.m_flTimeWeaponIdle = g_Engine.time + 0.35; 
    }
	
    private void ThrowCommon2() {
        // random throwing motion 2
        int anim = Math.RandomLong(WEP_SHURIKEN::MOTION_THROW1, WEP_SHURIKEN::MOTION_THROW3);
        self.SendWeaponAnim(anim );
        
        m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
        self.pev.nextthink = g_WeaponFuncs.WeaponTimeBase() + 0.8;
        
        // buzzing sound
        g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "scmod/weapons/ut99/razor_fire2.ogg", 1, ATTN_NORM, 0, 94 + Math.RandomLong( 0,0xF ) );
        
        m_pPlayer.m_flNextAttack = g_WeaponFuncs.WeaponTimeBase() + 0.9; 
        self.m_flTimeWeaponIdle = g_Engine.time + 0.9; 
    }
    
    // Ammo consumption
    private void ConsumeAmmo() {
        int ammoCnt = m_pPlayer.m_rgAmmo(self.m_iPrimaryAmmoType );
        
        ammoCnt = (ammoCnt -1 < 0) ? 0 : ammoCnt -1;
        m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, ammoCnt);
    }
    
    // Throwing
    private void ThrowProj1() {
        m_pPlayer.pev.weaponmodel = "";
        
		//Throwing sound is throwSoundFile
        g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, this.throwSoundFile, 1, ATTN_NORM, 0, PITCH_NORM);
        Math.MakeVectors( m_pPlayer.pev.v_angle + m_pPlayer.pev.punchangle);
        ShootBall(m_pPlayer.pev,
                  m_pPlayer.GetGunPosition() + g_Engine.v_forward * 32 + g_Engine.v_up * 2 + g_Engine.v_right * -2,
                  g_Engine.v_forward * 1200 + g_Engine.v_up * Math.RandomFloat(-20, 20) + g_Engine.v_right * Math.RandomFloat(-20, 20));        
        ConsumeAmmo();        
    }
    
    // Throwing 2
    private void ThrowProj2() {
        m_pPlayer.pev.weaponmodel = "";
        
		//Throwing sound is throwSoundFile2
        g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, this.throwSoundFile2, 1, ATTN_NORM, 0, PITCH_NORM);
        Math.MakeVectors( m_pPlayer.pev.v_angle + m_pPlayer.pev.punchangle);
        ShootBall(m_pPlayer.pev,
                  m_pPlayer.GetGunPosition() + g_Engine.v_forward * 32 + g_Engine.v_up * 2 + g_Engine.v_right * -2,
                  g_Engine.v_forward * 600 + g_Engine.v_up * Math.RandomFloat(-5, 5) + g_Engine.v_right * Math.RandomFloat(-5, 5));
        SetThink(null);
        
        ConsumeAmmo();
    }    
    
    // Throwing process
    private void ShootBall(entvars_t@ pevOwner, Vector vecStart, Vector vecVelocity) {
        
        CBaseEntity@ pEntity = g_EntityFuncs.CreateEntity( WEP_SHURIKEN::PROJ_NAME , null,  false);
        ShurikenProj@ pProj = cast<ShurikenProj@>(CastToScriptClass(pEntity));
        
        g_EntityFuncs.SetOrigin( pProj.self, vecStart );
        g_EntityFuncs.DispatchSpawn( pProj.self.edict() );
        
        pProj.pev.velocity = vecVelocity;
        @pProj.pev.owner = pevOwner.pContainingEntity;
        pProj.pev.angles = Math.VecToAngles( pProj.pev.velocity );
        pProj.SetThink( ThinkFunction( pProj.BulletThink ) );
        pProj.pev.nextthink = g_Engine.time + 0.1;
        pProj.SetTouch( TouchFunction( pProj.Touch ) );
        
        pProj.pev.angles.z = pProj.pev.angles.z + Math.RandomFloat(-30.0, 30.0);
        
        
        // Set player index
        pProj.pev.iuser4 = g_EngineFuncs.IndexOfEdict(m_pPlayer.edict()); 
        
    }
    
    /** At idle */
    void WeaponIdle() {
        self.ResetEmptySound();
        
        // Ammo If not, delete
        if (m_pPlayer.m_rgAmmo(self.m_iPrimaryAmmoType ) <= 0) {
            m_pPlayer.pev.weapons &= ~( 0 << g_ItemRegistry.GetIdForName(WEP_SHURIKEN::WEP_NAME) );
            SetThink( ThinkFunction( DestroyThink ) );
            self.pev.nextthink = g_Engine.time + 0.1;
            return;
        }

        if( self.m_flTimeWeaponIdle  > g_Engine.time) {
            return;
        }
        
        // Motion to take out the next item
        m_pPlayer.pev.weaponmodel = this.pModel;
        m_pPlayer.SetAnimation( PLAYER_DEPLOY );
        
        int anim = Math.RandomLong( WEP_SHURIKEN::MOTION_IDLE,  WEP_SHURIKEN::MOTION_FIDGET );
        self.SendWeaponAnim( anim );

        self.m_flTimeWeaponIdle = g_Engine.time + Math.RandomFloat(10.0, 15.0);
    }
    
}

// Registration
void RegisterShuriken() {
    g_CustomEntityFuncs.RegisterCustomEntity( "WeaponShuriken", WEP_SHURIKEN::WEP_NAME ); // クラス名, 定義名
    g_ItemRegistry.RegisterWeapon( WEP_SHURIKEN::WEP_NAME, "scmod/ut99", WEP_SHURIKEN::AMMO_NAME );
    
    // Ammo登録
    g_CustomEntityFuncs.RegisterCustomEntity( "ShurikenAmmo", WEP_SHURIKEN::AMMO_NAME );
    
    // Projectile登録
    g_CustomEntityFuncs.RegisterCustomEntity( "ShurikenProj", WEP_SHURIKEN::PROJ_NAME );
}

////////////////////////////////////////////////////////////////////////////////////////////

/** Ammo */
class ShurikenAmmo : ScriptBasePlayerAmmoEntity {
    private string modelFile = "models/scmod/weapons/ut99/crossbow_bolt.mdl";
    private string soundFile = "scmod/weapons/ut99/9mmclip1.wav";
    
    void Spawn() {
        g_Game.PrecacheModel( this.modelFile );
        g_SoundSystem.PrecacheSound( this.soundFile );
        
        g_EntityFuncs.SetModel( self, this.modelFile );
        BaseClass.Spawn();
    }

    bool AddAmmo( CBaseEntity@ pEnt ) {
        CBasePlayer@ pPlayer = cast<CBasePlayer>(pEnt);
        
        if ( pEnt.GiveAmmo( WEP_SHURIKEN::SUP_AMMO, WEP_SHURIKEN::AMMO_NAME, WEP_SHURIKEN::MAX_AMMO ) != -1 ) {
            // Add a weapon if you don't have one
            if (pPlayer.HasNamedPlayerItem(WEP_SHURIKEN::WEP_NAME) is null) {
                pPlayer.GiveNamedItem(WEP_SHURIKEN::WEP_NAME, 0, 0);
            }
            
            g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, this.soundFile, 1, ATTN_NORM );
            
            // Look at the flag and remove it if it's set
            if (pev.iuser4 == 1) {
                g_EntityFuncs.Remove( self );
            }
            return true;
        }
        
        return false;
    }
    
}

////////////////////////////////////////////////////////////////////////////////////////////

/** Projectile */
class ShurikenProj : ScriptBaseMonsterEntity {
    private float lifeTime;    // lifespan
    
    private string modelFile    = "models/scmod/weapons/ut99/crossbow_bolt.mdl";
    private string trailFile    = "sprites/laserbeam.spr";
    private string hitSoundFile = "scmod/weapons/ut99/razor_hit.ogg";
    private string dmgSoundFile = "weapons/knife_hit_flesh2.wav";
    private string picSoundFile = "scmod/weapons/ut99/9mmclip1.wav";
    
    void Spawn() {
        Precache();
        pev.solid = SOLID_SLIDEBOX;
        pev.movetype = MOVETYPE_FLY;
        pev.takedamage = DAMAGE_YES;
        pev.scale = 1;
        self.ResetSequenceInfo();
        
        pev.movetype = MOVETYPE_FLY;
        g_EntityFuncs.SetModel( self, this.modelFile);
        
        this.lifeTime = 0;
        
        SetThink( ThinkFunction( this.BulletThink ) );
    }

    private void Precache() {
        g_Game.PrecacheModel( this.modelFile ); 
        g_Game.PrecacheModel( this.trailFile );
        g_SoundSystem.PrecacheSound( this.hitSoundFile );
        g_SoundSystem.PrecacheSound( this.picSoundFile );
    }
    
    void Touch ( CBaseEntity@ pOther ) {
        const float HITDAMAGE = 60.0 + Math.RandomFloat(-20.0, 20.0);
        
        int cl = pOther.Classify();
        
        // When the speed decreases, it stops and disappears.
        if (pev.velocity.Length() < 30.0) {
            pev.solid = SOLID_NOT;
            pev.movetype = MOVETYPE_FLY;
            self.StopAnimation();
            
            this.lifeTime = g_Engine.time + 1.0;
        }
        
         // Damage to anything other than walls
        if ( ( pOther.TakeDamage ( pev, pev, 0, DMG_CLUB ) ) == 1 ) {
            g_WeaponFuncs.SpawnBlood(pev.origin, pOther.BloodColor(), HITDAMAGE);
            pOther.TakeDamage ( pev, pev.owner.vars, HITDAMAGE, DMG_CLUB );
            
            pev.angles = Math.VecToAngles( Vector(200.0 * Math.RandomFloat(-1.0, 1.0)
                                                 ,200.0 * Math.RandomFloat(-1.0, 1.0)
                                                 ,200.0 * Math.RandomFloat(-1.0, 1.0)) );
            
            g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, this.dmgSoundFile, 1, ATTN_NORM, 0, PITCH_NORM);
            
        // Wall
        } else {
            g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, this.hitSoundFile, 1, ATTN_NORM, 0, PITCH_NORM);
            g_Utility.Sparks( pev.origin );
        }
        
        if (this.lifeTime == 0) {
            // Negative evaluation if hit by an ally
            if ((cl == CLASS_PLAYER) || ( cl == CLASS_PLAYER_ALLY) || ( cl == CLASS_HUMAN_PASSIVE)) {
                
                CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(pev.iuser4);
                if ((pPlayer !is null) && (pPlayer.IsConnected()) ) {
                    SnsEffect::EffectBad(pPlayer);
                }
            }
        }
        
        // Since it was a hit, set the deletion time
        this.lifeTime = (this.lifeTime == 0) ? g_Engine.time + 1.0 : this.lifeTime;
        
       
    }
    
    // Add item to player
    private void AddWeaponToPlayer(CBaseEntity@ pEnt ) {
        CBasePlayer@ pPlayer = cast<CBasePlayer>(pEnt);
        
        // Add a weapon if you don't have one
        pEnt.GiveAmmo( 1, WEP_SHURIKEN::AMMO_NAME, WEP_SHURIKEN::MAX_AMMO );
        if (pPlayer.HasNamedPlayerItem(WEP_SHURIKEN::WEP_NAME) is null) {
            pPlayer.GiveNamedItem(WEP_SHURIKEN::WEP_NAME, 0, 0);
        }
        
        // Forced priority on weapons
        CBasePlayerItem@ pItem = pPlayer.HasNamedPlayerItem(WEP_SHURIKEN::WEP_NAME);
        if (pItem !is null) {
            pPlayer.SwitchWeapon(pItem);
        }
        g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, this.picSoundFile, 1, ATTN_NORM );
    }
    
    void BulletThink() {
        pev.nextthink = g_Engine.time + 0.1;
        pev.velocity = pev.velocity + g_Engine.v_up * -10;
        
        int tailId = g_EntityFuncs.EntIndex(self.edict());
        int sprId  = g_EngineFuncs.ModelIndex(this.trailFile);
        NetworkMessage nm(MSG_BROADCAST, NetworkMessages::SVC_TEMPENTITY, null);
        nm.WriteByte(TE_BEAMFOLLOW);
        nm.WriteShort(tailId);
        nm.WriteShort(sprId);
        nm.WriteByte(2);    // 描画時間
        nm.WriteByte(2);    // サイズ
        nm.WriteByte(128);  // R
        nm.WriteByte(128);  // G
        nm.WriteByte(128);  // B
        nm.WriteByte(64);   // A
        nm.End();
        
        // disappear with time
        if ((this.lifeTime > 0) && (g_Engine.time  >= this.lifeTime)) {
            g_EntityFuncs.Remove( self );
        }
    }

}
