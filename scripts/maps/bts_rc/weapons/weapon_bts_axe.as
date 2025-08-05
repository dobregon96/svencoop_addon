/*
* Emergency Fire Axe
*/
// Rewrited by Rizulix for bts_rc (january 2025)

namespace weapon_bts_axe
{
    enum axe_e
    {
        IDLE = 0,
        DRAW,
        HOLSTER,
        ATTACK1HIT,
        ATTACK1MISS,
        ATTACK2MISS,
        ATTACK2HIT,
        ATTACK3MISS,
        ATTACK3HIT
    };

    class weapon_bts_axe : ScriptBasePlayerWeaponEntity, bts_rc_base_weapon, bts_rc_base_melee
    {
        private CBasePlayer@ m_pPlayer { get const { return get_player(); } }

        bool Deploy() {
            return bts_deploy( "models/bts_rc/weapons/v_axe.mdl", "models/bts_rc/weapons/p_axe.mdl", DRAW, "crowbar", 1 );
        }

        void Spawn()
        {
            g_EntityFuncs.SetModel( self, self.GetW_Model( "models/bts_rc/weapons/w_axe.mdl" ) );
            self.FallInit();
        }

        bool GetItemInfo( ItemInfo& out info )
        {
            info.iMaxAmmo1 = -1;
            info.iAmmo1Drop = WEAPON_NOCLIP;
            info.iMaxAmmo2 = -1;
            info.iAmmo2Drop = -1;
            info.iMaxClip = WEAPON_NOCLIP;
            info.iSlot = 0;
            info.iPosition = 9;
            info.iId = g_ItemRegistry.GetIdForName( pev.classname );
            info.iFlags = m_flags;
            info.iWeight = 10;
            return true;
        }

        void Holster( int skiplocal = 0 )
        {
            SetThink( null );
            BaseClass.Holster( skiplocal );
        }

        private bool Swing( bool fFirst )
        {
            bool fDidHit = false;

            TraceResult tr;

            Math.MakeVectors( m_pPlayer.pev.v_angle );
            Vector vecSrc   = m_pPlayer.GetGunPosition();
            Vector vecEnd   = vecSrc + g_Engine.v_forward * 32.0f;

            g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, m_pPlayer.edict(), tr );

            if( tr.flFraction >= 1.0f )
            {
                g_Utility.TraceHull( vecSrc, vecEnd, dont_ignore_monsters, head_hull, m_pPlayer.edict(), tr );
                if( tr.flFraction < 1.0f )
                {
                    // Calculate the point of intersection of the line (or hull) and the object we hit
                    // This is and approximation of the "best" intersection
                    CBaseEntity@ pHit = g_EntityFuncs.Instance( tr.pHit );
                    if( pHit is null || pHit.IsBSPModel() )
                        g_Utility.FindHullIntersection( vecSrc, tr, tr, VEC_DUCK_HULL_MIN, VEC_DUCK_HULL_MAX, m_pPlayer.edict() );
                    vecEnd = tr.vecEndPos; // This is the point on the actual surface (the hull could have hit space)
                }
            }

            bool is_trained_personal = g_PlayerClass.is_trained_personal(m_pPlayer);

            if( tr.flFraction >= 1.0f )
            {
                if( fFirst )
                {
                    // miss
                    switch( ( m_iSwing++ ) % 3 )
                    {
                        case 0: self.SendWeaponAnim( ATTACK1MISS, 0, pev.body ); break;
                        case 1: self.SendWeaponAnim( ATTACK2MISS, 0, pev.body ); break;
                        case 2: self.SendWeaponAnim( ATTACK3MISS, 0, pev.body ); break;
                    }
                    self.m_flNextPrimaryAttack = g_Engine.time + ( is_trained_personal ? 0.90f : 1.25f );
                    self.m_flTimeWeaponIdle = g_Engine.time + 2.0f;

                    // play wiff or swish sound
                    g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "bts_rc/weapons/axe_miss1.wav", 1.0f, ATTN_NORM, 0, 94 + Math.RandomLong( 0, 0xF ) );

                    // player "shoot" animation
                    m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
                }
            }
            else
            {
                // hit
                fDidHit = true;

                CBaseEntity@ pEntity = g_EntityFuncs.Instance( tr.pHit );

                switch( ( ( m_iSwing++ ) % 2 ) + 1 )
                {
                    case 0: self.SendWeaponAnim( ATTACK1HIT, 0, pev.body ); break;
                    case 1: self.SendWeaponAnim( ATTACK2HIT, 0, pev.body ); break;
                    case 2: self.SendWeaponAnim( ATTACK3HIT, 0, pev.body ); break;
                }

                self.m_flNextPrimaryAttack = g_Engine.time + ( is_trained_personal ? 0.25f : 0.5f );
                self.m_flTimeWeaponIdle = g_Engine.time + 2.0f;

                // player "shoot" animation
                m_pPlayer.SetAnimation( PLAYER_ATTACK1 );

                g_WeaponFuncs.ClearMultiDamage();

                if( self.m_flNextPrimaryAttack + 1.0f < g_Engine.time )
                    pEntity.TraceAttack( m_pPlayer.pev, 20.0f, g_Engine.v_forward, tr, DMG_CLUB ); // first swing does full damage
                else
                    pEntity.TraceAttack( m_pPlayer.pev, 20.0f * 0.5f, g_Engine.v_forward, tr, DMG_CLUB ); // subsequent swings do 50% (Changed -Sniper) (Half)

                g_WeaponFuncs.ApplyMultiDamage( m_pPlayer.pev, m_pPlayer.pev );

                // play thwack, smack, or dong sound
                float flVol = 1.0f;
                bool fHitWorld = true;

                // for monsters or breakable entity smacking speed function
                if( pEntity !is null )
                {
                    if( pEntity.Classify() != CLASS_NONE && pEntity.Classify() != CLASS_MACHINE && pEntity.BloodColor() != DONT_BLEED )
                    {
                        // aone
                        if( pEntity.IsPlayer() ) // lets pull them
                            pEntity.pev.velocity = pEntity.pev.velocity + ( pev.origin - pEntity.pev.origin ).Normalize() * 120.0f;
                        // end aone

                        // play thwack or smack sound
                        switch( Math.RandomLong( 1, 3 ) )
                        {
                            case 3:
                                g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, "bts_rc/weapons/axe_hitbod3.wav", 1.0f, ATTN_NORM );
                            break;
                            case 2:
                                g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, "bts_rc/weapons/axe_hitbod2.wav", 1.0f, ATTN_NORM );
                            break;
                            default:
                                g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, "bts_rc/weapons/axe_hitbod1.wav", 1.0f, ATTN_NORM );
                            break;
                        }

                        m_pPlayer.m_iWeaponVolume = 128;

                        if( !pEntity.IsAlive() )
                            return true;
                        else
                            flVol = 0.1f;

                        fHitWorld = false;
                    }
                }

                // play texture hit sound
                // UNDONE: Calculate the correct point of intersection when we hit with the hull instead of the line

                if( fHitWorld )
                {
                    g_SoundSystem.PlayHitSound( tr, vecSrc, vecSrc + ( vecEnd - vecSrc ) * 2.0f, BULLET_PLAYER_CROWBAR );

                    // also play crowbar strike
                    switch( Math.RandomLong( 1, 2 ) )
                    {
                        case 2:
                            g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "bts_rc/weapons/axe_hit2.wav", 1.0f, ATTN_NORM, 0, 98 + Math.RandomLong( 0, 3 ) );
                        break;
                        default:
                            g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "bts_rc/weapons/axe_hit1.wav", 1.0f, ATTN_NORM, 0, 98 + Math.RandomLong( 0, 3 ) );
                        break;
                    }
                }

                // delay the decal a bit
                m_trHit = tr;
                bts_post_attack(tr);
                SetThink( ThinkFunction( this.Smack ) );
                pev.nextthink = g_Engine.time + 0.2f;

                m_pPlayer.m_iWeaponVolume = int( flVol * 512 );
            }
            return fDidHit;
        }
    }
}
