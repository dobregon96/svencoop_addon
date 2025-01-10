// TO-DO:
// - On GibMonster() use beargibs.mdl
// - bool if the bear is standing or not, for death animation
// - When standing, flinch

namespace HLWanted_Bear
{
const int BEAR_FLINCH_DELAY = 2;
const int BEAR_HEALTH = 400;
const int BEAR_DMG_CLAW_SLASH = 30;
const float BEAR_DMG_POUNCE = 35.0;

const int BEAR_AE_ATTACK_RIGHT = 0x01;
const int BEAR_AE_ATTACK_LEFT = 0x02;
const int BEAR_AE_JUMPATTACK = 0x03;

const int TASKSTATUS_RUNNING = 1;

array<ScriptSchedule@>@ custom_bear_schedules;

ScriptSchedule slBearRangeAttack
(
	bits_COND_ENEMY_OCCLUDED |
	bits_COND_NO_AMMO_LOADED,
	0,
	"BearRangeAttack1"
);

void InitSchedules()
{
	slBearRangeAttack.AddTask( ScriptTask(TASK_STOP_MOVING, 0) );
	slBearRangeAttack.AddTask( ScriptTask(TASK_FACE_IDEAL, 0) );
	slBearRangeAttack.AddTask( ScriptTask(TASK_RANGE_ATTACK1, 0) );
	slBearRangeAttack.AddTask( ScriptTask(TASK_SET_ACTIVITY, ACT_IDLE) );
	slBearRangeAttack.AddTask( ScriptTask(TASK_FACE_IDEAL, 0) );
	slBearRangeAttack.AddTask( ScriptTask(TASK_WAIT_RANDOM, 0.5f) );

	array<ScriptSchedule@> scheds = { slBearRangeAttack };
	
	@custom_bear_schedules = @scheds;
}

const array<string> pAttackHitSounds = 
{
	"zombie/claw_strike1.wav",
	"zombie/claw_strike2.wav",
	"zombie/claw_strike3.wav"
};

const array<string> pAttackMissSounds = 
{
	"wanted/grizzly/miss1.wav",
	"wanted/grizzly/miss2.wav"
};

const array<string> pAttackSounds = 
{
	"wanted/grizzly/attack1.wav",
	"wanted/grizzly/attack2.wav"
};

const array<string> pIdleSounds = 
{
	"wanted/grizzly/idle1.wav",
	"wanted/grizzly/idle2.wav",
	"wanted/grizzly/idle3.wav"
};

const array<string> pAlertSounds = 
{
	"wanted/grizzly/alert1.wav",
	"wanted/grizzly/alert2.wav",
	"wanted/grizzly/alert3.wav"
};

const array<string> pPainSounds = 
{
	"wanted/grizzly/pain1.wav",
	"wanted/grizzly/pain2.wav",
	"wanted/grizzly/pain3.wav"
};

const array<string> pDeathSounds = 
{
	"wanted/grizzly/die1.wav",
	"wanted/grizzly/die2.wav",
	"wanted/grizzly/die3.wav"
};

class monster_bear : CBaseCustomMonster
{
	float m_flNextFlinch;
	float m_flNextRangeAttack;
	private bool m_fStanding;

	void Spawn()
	{
		Precache();

		if( !self.SetupModel() )
			g_EntityFuncs.SetModel( self, "models/wanted/bear.mdl" );

		//g_EntityFuncs.SetSize( self.pev, VEC_HUMAN_HULL_MIN, VEC_HUMAN_HULL_MAX );
		g_EntityFuncs.SetSize( self.pev, Vector( -32, -32, 0 ), Vector( 32, 32, 72 ) );

		self.pev.solid			= SOLID_SLIDEBOX;
		self.pev.movetype		= MOVETYPE_STEP;
		self.m_bloodColor		= BLOOD_COLOR_RED;
		self.pev.health			= BEAR_HEALTH;
		self.pev.max_health		= BEAR_HEALTH;
		self.m_flFieldOfView		= 0.2;// indicates the width of this monster's forward view cone ( as a dotproduct result )
		self.m_MonsterState		= MONSTERSTATE_NONE;
		self.m_afCapability		= bits_CAP_DOORS_GROUP;
		g_EntityFuncs.DispatchKeyValue( self.edict(), "displayname", "Bear" );

		self.MonsterInit();

		self.pev.view_ofs		= Vector( 0, 0, 50 );// position of the eyes relative to monster's origin.
	}

	void Precache()
	{
		uint i;

		if( string( self.pev.model ).IsEmpty() )
		{
			g_Game.PrecacheModel( "models/wanted/bear.mdl" );
			g_Game.PrecacheModel( "models/wanted/beargibs.mdl" );
		}
		else
		{
			g_Game.PrecacheModel( self.pev.model );
		}

		for( i = 0; i < pAttackHitSounds.length(); i++ )
		{
			g_SoundSystem.PrecacheSound( pAttackHitSounds[i] );
			g_Game.PrecacheGeneric( "sound/" + pAttackHitSounds[i] );
		}

		for( i = 0; i < pAttackMissSounds.length(); i++ )
		{
			g_SoundSystem.PrecacheSound( pAttackMissSounds[i] );
			g_Game.PrecacheGeneric( "sound/" + pAttackMissSounds[i] );
		}

		for( i = 0; i < pAttackSounds.length(); i++ )
		{
			g_SoundSystem.PrecacheSound( pAttackSounds[i] );
			g_Game.PrecacheGeneric( "sound/" + pAttackSounds[i] );
		}

		for( i = 0; i < pIdleSounds.length(); i++ )
		{
			g_SoundSystem.PrecacheSound( pIdleSounds[i] );
			g_Game.PrecacheGeneric( "sound/" + pIdleSounds[i] );
		}

		for( i = 0; i < pAlertSounds.length(); i++ )
		{
			g_SoundSystem.PrecacheSound( pAlertSounds[i] );
			g_Game.PrecacheGeneric( "sound/" + pAlertSounds[i] );
		}

		for( i = 0; i < pPainSounds.length(); i++ )
		{
			g_SoundSystem.PrecacheSound( pPainSounds[i] );
			g_Game.PrecacheGeneric( "sound/" + pPainSounds[i] );
		}

		for( i = 0; i < pDeathSounds.length(); i++ )
		{
			g_SoundSystem.PrecacheSound( pDeathSounds[i] );
			g_Game.PrecacheGeneric( "sound/" + pDeathSounds[i] );
		}
	}

	int IRelationship( CBaseEntity@ pTarget )
	{
		if( pTarget.pev.classname == "monster_chicken" ||
			pTarget.pev.classname == "monster_snake" ||
			pTarget.pev.classname == "monster_puma" )
		{
			return R_DL;
		}

		return self.IRelationship( pTarget );
	}

	//=========================================================
	// SetYawSpeed - allows each sequence to have a different
	// turn rate associated with it.
	//=========================================================
	void SetYawSpeed()
	{
		int ys = 120;
		self.pev.yaw_speed = ys;
	}

	int Classify()
	{
		return CLASS_ALIEN_MONSTER;
	}

	
	//=========================================================
	// RunTask 
	//=========================================================
	void RunTask( Task@ pTask )
	{
		switch( pTask.iTask )
		{
		case TASK_RANGE_ATTACK1:
		case TASK_RANGE_ATTACK2:
			{
				if( self.m_fSequenceFinished )
				{
					self.TaskComplete();
					SetTouch( null );
					self.m_IdealActivity = ACT_IDLE;
				}
				break;
			}
		default: BaseClass.RunTask( pTask );
		}
	}

	//=========================================================
	// LeapTouch - this is the bear's touch function when it
	// is in the air
	//=========================================================
	void LeapTouch( CBaseEntity@ pOther )
	{
		if( pOther.pev.takedamage == DAMAGE_NO )
			return;

		if( pOther.Classify() == Classify() )
			return;

		// Don't hit if back on ground
		if( !self.pev.FlagBitSet( FL_ONGROUND ) )
		{
			pOther.TakeDamage( self.pev, self.pev, BEAR_DMG_POUNCE, DMG_SLASH );
		}

		SetTouch( null );
	}

	void StartTask( Task@ pTask )
	{
		self.m_iTaskStatus = TASKSTATUS_RUNNING;

		switch( pTask.iTask )
		{
		case TASK_RANGE_ATTACK1:
			{
				g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_WEAPON, pAttackSounds[0], 0.8f, ATTN_IDLE, 0, PITCH_NORM );
				self.m_IdealActivity = ACT_RANGE_ATTACK1;
				SetTouch( TouchFunction( this.LeapTouch ) );
				break;
			}
		case TASK_SOUND_DIE:
		case TASK_SOUND_DEATH:
			{
				DeathSound();
				self.TaskComplete();
				break;
			}
		default:
			BaseClass.StartTask( pTask );
		}
	}

	bool CheckMeleeAttack1( float flDot, float flDist )
	{
		if( self.pev.health >= (self.pev.max_health / 2) )
			return false;

		if( flDist <= 80 && flDot >= 0.7 && self.m_hEnemy.GetEntity() !is null && self.pev.FlagBitSet( FL_ONGROUND ) )
			return true;

		return false;
	}

	bool CheckMeleeAttack2( float flDot, float flDist )
	{
		if( flDist <= 80 && flDot >= 0.7 )
			return true;

		return false;
	}

	bool CheckRangeAttack1( float flDot, float flDist )
	{
		if( m_flNextRangeAttack > g_Engine.time )
			return false;

		if( self.m_hEnemy.GetEntity() !is null && self.m_hEnemy.GetEntity().pev.velocity != g_vecZero && self.pev.FlagBitSet( FL_ONGROUND ) && flDist > 80 && flDist <= 128 && flDot >= 0.65 )
			return true;

		return false;
	}

	bool CheckRangeAttack2( float flDot, float flDist )
	{
		return false;
	}

	//=========================================================
	// HandleAnimEvent - catches the monster-specific messages
	// that occur when tagged animation frames are played.
	//=========================================================
	void HandleAnimEvent( MonsterEvent@ pEvent )
	{
		switch( pEvent.event )
		{
			case BEAR_AE_ATTACK_RIGHT:
			{
				// do stuff for this event.
				CBaseEntity@ pHurt = CheckTraceHullAttack( self, 80, BEAR_DMG_CLAW_SLASH, DMG_SLASH );
				if( pHurt !is null )
				{
					if( (pHurt.pev.flags & (FL_MONSTER|FL_CLIENT)) == 1 )
					{
						pHurt.pev.punchangle.z = -18;
						pHurt.pev.punchangle.x = 5;
						pHurt.pev.velocity = pHurt.pev.velocity - g_Engine.v_right * 100;
					}
					// Play a random attack hit sound
					g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_WEAPON, pAttackHitSounds[Math.RandomLong(0,(pAttackHitSounds.length() - 1))], 1.0, ATTN_NORM, 0, 100 + Math.RandomLong(-5,5) );
				}
				else // Play a random attack miss sound
					g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_WEAPON, pAttackMissSounds[Math.RandomLong(0,(pAttackMissSounds.length() - 1))], 1.0, ATTN_NORM, 0, 100 + Math.RandomLong(-5,5) );

				if( Math.RandomLong(0,1) == 1 )
					AttackSound();
			}
			break;

			case BEAR_AE_ATTACK_LEFT:
			{
				// do stuff for this event.
				CBaseEntity@ pHurt = CheckTraceHullAttack( self, 80, BEAR_DMG_CLAW_SLASH, DMG_SLASH );
				if( pHurt !is null )
				{
					if( (pHurt.pev.flags & (FL_MONSTER|FL_CLIENT)) == 1 )
					{
						pHurt.pev.punchangle.z = 18;
						pHurt.pev.punchangle.x = 5;
						pHurt.pev.velocity = pHurt.pev.velocity + g_Engine.v_right * 100;
					}
					g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_WEAPON, pAttackHitSounds[Math.RandomLong(0,(pAttackHitSounds.length() - 1))], 1.0, ATTN_NORM, 0, 100 + Math.RandomLong(-5,5) );
				}
				else
					g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_WEAPON, pAttackMissSounds[Math.RandomLong(0,(pAttackMissSounds.length() - 1))], 1.0, ATTN_NORM, 0, 100 + Math.RandomLong(-5,5) );

				if( Math.RandomLong(0,1) == 1 )
					AttackSound();
			}
			break;

			case BEAR_AE_JUMPATTACK:
			{
				self.pev.flags &= ~FL_ONGROUND;

				g_EntityFuncs.SetOrigin( self, self.pev.origin + Vector( 0 , 0 , 1 ) );// take him off ground so engine doesn't instantly reset onground 
				Math.MakeVectors( self.pev.angles );

				Vector vecJumpDir;
				if( self.m_hEnemy.GetEntity() !is null )
				{
					float gravity = g_EngineFuncs.CVarGetFloat( "sv_gravity" );
					if( gravity <= 1 )
						gravity = 1;

					// How fast does the bear need to travel to reach that height given gravity?
					float height = ( self.m_hEnemy.GetEntity().pev.origin.z + self.m_hEnemy.GetEntity().pev.view_ofs.z - self.pev.origin.z );
					if( height < 16 )
						height = 16;
					else if( height > 16 )
						height = 16;
					float speed = sqrt( 2 * gravity * height );
					float time = speed / gravity;

					// Scale the sideways velocity to get there at the right time
					vecJumpDir = ( self.m_hEnemy.GetEntity().pev.origin + self.m_hEnemy.GetEntity().pev.view_ofs - self.pev.origin );
					vecJumpDir = vecJumpDir * ( 1.0 / time );

					// Speed to offset gravity at the desired height
					vecJumpDir.z = speed;

					// Don't jump too far/fast
					float distance = vecJumpDir.Length();
					
					if( distance > 650 )
					{
						vecJumpDir = vecJumpDir * ( 650.0 / distance );
					}
				}
				else
				{
					// jump hop, don't care where
					vecJumpDir = Vector( g_Engine.v_forward.x, g_Engine.v_forward.y, g_Engine.v_up.z ) * 350;
				}

				self.pev.velocity = vecJumpDir;
				self.m_flNextAttack = g_Engine.time + 2;

				m_flNextRangeAttack = g_Engine.time + Math.RandomFloat( 4.0, 8.0 );
			}
			break;

			default:
				BaseClass.HandleAnimEvent( pEvent );
				break;
		}
	}

	int TakeDamage( entvars_t@ pevInflictor, entvars_t@ pevAttacker, float flDamage, int bitsDamageType )
	{
		if( pevAttacker is null )
			return 0;

		CBaseEntity@ pAttacker = g_EntityFuncs.Instance( pevAttacker );

		if( self.CheckAttacker( pAttacker ) )
			return 0;

		if( self.IsAlive() )
		{
			PainSound();

			if( pevAttacker.classname == "player" )
			{
				float points = Math.min(flDamage, pev.health)*0.05f;
				pevAttacker.frags += points;
			}
		}

		return BaseClass.TakeDamage( pevInflictor, pevAttacker, flDamage, bitsDamageType );
	}

	void AlertSound()
	{
		g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, pAlertSounds[Math.RandomLong(0,(pAlertSounds.length() - 1))], 1.0, ATTN_NORM, 0, 100 + Math.RandomLong(-5,5) );
	}

	void IdleSound()
	{
		g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, pIdleSounds[Math.RandomLong(0,(pIdleSounds.length() - 1))], 1.0, ATTN_NORM, 0, 100 + Math.RandomLong(-5,5) );
	}

	void AttackSound()
	{
		g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, pAttackSounds[Math.RandomLong(0,(pAttackSounds.length() - 1))], 1.0, ATTN_NORM, 0, 100 + Math.RandomLong(-5,5) );
	}

	void PainSound()
	{
		int pitch = 95 + Math.RandomLong(0,9);

		if( Math.RandomLong(0,5) < 2 )
			g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, pPainSounds[Math.RandomLong(0,(pPainSounds.length() - 1))], 1.0, ATTN_NORM, 0, pitch );
	}

	void DeathSound()
	{
		g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, pDeathSounds[Math.RandomLong(0,(pDeathSounds.length() - 1))], 1.0, ATTN_NORM, 0, 100 + Math.RandomLong(-5,5) );
	}

	void RunAI( void )
	{
		if ( ( self.m_MonsterState == MONSTERSTATE_IDLE || self.m_MonsterState == MONSTERSTATE_ALERT ) && Math.RandomLong(0,99) == 0 && (pev.spawnflags & SF_MONSTER_GAG) == 0 )
			IdleSound();

		BaseClass.RunAI();
	}

	Schedule@ GetScheduleOfType( int Type )
	{
		switch( Type )
		{
			case SCHED_RANGE_ATTACK1:
			{
				return slBearRangeAttack;
			}
		}
		return BaseClass.GetScheduleOfType( Type );
	}

	//=========================================================
	// AI Schedules Specific to this monster
	//=========================================================
	/*int IgnoreConditions()
	{
		int iIgnore = BaseIgnoreConditions();

		if( (self.m_Activity == ACT_MELEE_ATTACK1) || (self.m_Activity == ACT_MELEE_ATTACK1) )
		{
			if( m_flNextFlinch >= g_Engine.time )
				iIgnore |= (bits_COND_LIGHT_DAMAGE|bits_COND_HEAVY_DAMAGE);
		}

		if( (self.m_Activity == ACT_SMALL_FLINCH) || (self.m_Activity == ACT_BIG_FLINCH) )
		{
			if( m_flNextFlinch < g_Engine.time )
				m_flNextFlinch = g_Engine.time + BEAR_FLINCH_DELAY;
		}

		return iIgnore;
	}

	int BaseIgnoreConditions()
	{
		int iIgnoreConditions = 0;

		if( !self.FShouldEat() )
		{
			// not hungry? Ignore food smell.
			iIgnoreConditions |= bits_COND_SMELL_FOOD;
		}

		if( self.m_MonsterState == MONSTERSTATE_SCRIPT && self.m_pCine !is null )
			iIgnoreConditions |= self.m_pCine.IgnoreConditions();

		return iIgnoreConditions;
	}*/

	CBaseEntity@ CheckTraceHullAttack( CBaseMonster@ pThis, float flDist, int iDamage, int iDmgType )
	{
		TraceResult tr;

		if( pThis.IsPlayer() )
			Math.MakeVectors( pThis.pev.angles );
		else
			Math.MakeAimVectors( pThis.pev.angles );

		Vector vecStart = self.pev.origin;
		//vecStart.z += self.pev.size.z * 0.5;
		vecStart.z += 64.0f;
		Vector vecEnd = vecStart + (g_Engine.v_forward * flDist ) - (g_Engine.v_up * flDist * 0.3);

		g_Utility.TraceHull( vecStart, vecEnd, dont_ignore_monsters, head_hull, pThis.edict(), tr );

		if( tr.pHit !is null )
		{
			CBaseEntity@ pEntity = g_EntityFuncs.Instance( tr.pHit );

			if( iDamage > 0 )
			{
				pEntity.TakeDamage( pThis.pev, pThis.pev, iDamage, iDmgType );
			}

			return pEntity;
		}

		return null;
	}
}

string GetBearName()
{
	return "monster_bear";
}

void Register()
{
	InitSchedules();
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Bear::monster_bear", GetBearName() );
}

} //namespace HLWanted_Bear END