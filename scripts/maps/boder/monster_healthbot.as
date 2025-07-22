const int healthbot_heal_other = 1;
const int healthbot_heal_self = 2;
const int healthbot_die = 3;


class monster_healthbot : ScriptBaseMonsterEntity
{

	int g_sModelIndexSmoke;
	int m_iBodyGibs;
	string TURRET_SMOKE = "sprites/steam1.spr";
	int ammo = 1;
	CBaseEntity@ pHealthkit;

	void Spawn()
	{
		Precache(); 
		g_EntityFuncs.SetModel( self, "models/ns/healthbot.mdl" );
		g_EntityFuncs.SetSize( pev, Vector(-8, -8, -64), Vector(8, 8, 32) ); 
		pev.solid = SOLID_SLIDEBOX; 
		pev.movetype = MOVETYPE_STEP; 
		self.m_bloodColor = DONT_BLEED;
		pev.health = 2000;
		pev.view_ofs = Vector ( 0, 0, 32 );
		self.m_flFieldOfView = 0.75; 
		self.m_MonsterState = MONSTERSTATE_NONE; 
		g_EntityFuncs.DispatchKeyValue( self.edict(), "displayname", "healthbot" );

		self.MonsterInit(); 
		
	}

	void Precache()
	{
		g_Game.PrecacheModel( "models/ns/healthbot.mdl" );
		m_iBodyGibs = g_Game.PrecacheModel( "models/computergibs.mdl" );	
		g_sModelIndexSmoke = g_Game.PrecacheModel( TURRET_SMOKE );
	}

	int	Classify ( void )
	{
		return	CLASS_MACHINE; 
	}

	void SetYawSpeed( void )
	{
		pev.yaw_speed = 90; 
	}
			
	
	void ReloadAmmo()
	{	
		ammo = 1;
	}
		
	
	void HandleAnimEvent( MonsterEvent@ pEvent )
	{
		switch ( pEvent.event ) 
		{
			case healthbot_heal_other:
			{	
				if(ammo >= 1)
				{
					ammo = 0;
					g_Scheduler.SetTimeout( @this, "ReloadAmmo", 1.0);
					CBaseEntity@ pTarget = self.m_hEnemy;
					g_SoundSystem.EmitSoundDyn( self.edict(), CHAN_VOICE, "items/medshot4.wav", 1.0, ATTN_NORM, 0, 95 + Math.RandomLong( 0, 10 ) );
					
					te_beamentpointg(pTarget, self.pev.origin);
										
					pTarget.pev.health += 5;
					if(pTarget.pev.health >= 100){ pTarget.pev.health = 100; }
					
				}
			}
			break;
			case healthbot_die:
			{	
				self.pev.dmgtime = g_Engine.time;
				SetThink( ThinkFunction( this.Death ) );
				self.pev.nextthink = g_Engine.time + 0.1;				
			}
			break;
			case healthbot_heal_self:
			{	
				if(self.pev.health > 2000){ self.pev.health = 2000; }
				else{ self.pev.health += 200; }
			}
			break;
			default:
				BaseClass.HandleAnimEvent( pEvent );
				break; 
		}
	}
	
	Schedule@ GetSchedule( void )
	{	
		CBaseEntity@ pTarget = self.m_hEnemy;
		
		switch	(self.m_MonsterState)
		{
			case MONSTERSTATE_COMBAT:
			{	
				if(self.HasConditions(bits_COND_ENEMY_DEAD))
				{
					return BaseClass.GetSchedule();	
				}
			
				float distToEnemy = ( pev.origin - pTarget.pev.origin).Length();
			
				if ( distToEnemy < 80 && ammo >= 1){ 	return BaseClass.GetScheduleOfType ( SCHED_MELEE_ATTACK1 ); }
				else {									return BaseClass.GetSchedule();	}

			}			
		}

		return BaseClass.GetSchedule();	
	}
	
	
	void Death ( void )
	{
		
		bool iActive = false;
		self.StudioFrameAdvance( );
		
		g_EntityFuncs.CreateExplosion(self.pev.origin, self.pev.angles, self.pev.owner, 50, true);
		RoboGibs(100);	
		self.pev.framerate = 0;
		g_EntityFuncs.Remove( self );
	
	}

	
	void RoboGibs(int vel)
	{

		uint8 shards = 10;
		uint8 durationshard = 5;
		Vector vecSpot = self.pev.origin + (self.pev.mins + self.pev.maxs) * 0.5;

		//Gibs
		NetworkMessage gibs( MSG_PVS, NetworkMessages::SVC_TEMPENTITY, vecSpot );
		gibs.WriteByte( TE_BREAKMODEL );
				
		//Position
		gibs.WriteCoord( vecSpot.x );
		gibs.WriteCoord( vecSpot.y );
		gibs.WriteCoord( vecSpot.z );
				
		//Size
		gibs.WriteCoord( self.pev.size.x );
		gibs.WriteCoord( self.pev.size.y );
		gibs.WriteCoord( self.pev.size.z );
				
		//Velocity
		gibs.WriteCoord( 0 );
		gibs.WriteCoord( 0 );
		gibs.WriteCoord( 2 * vel);
				
		//Randomization
		gibs.WriteByte( 20 );
				
		//Model
		gibs.WriteShort( m_iBodyGibs );
				
		//Number of gibs
		gibs.WriteByte( shards );
				
		//Duration
		gibs.WriteByte( durationshard );
				
		//Flags
		gibs.WriteByte( BREAK_METAL + 16 );
		gibs.End();
		
	}
	
	
	void te_beamentpointg(CBaseEntity@ target, Vector end, 
    string sprite="sprites/laserbeam.spr", int frameStart=0, 
    int frameRate=100, int life=10, int width=32, int noise=100, 
    Color c=RED, int scroll=32,
    NetworkMessageDest msgType=MSG_BROADCAST, edict_t@ dest=null)
	{
		NetworkMessage m(msgType, NetworkMessages::SVC_TEMPENTITY, dest);
		m.WriteByte(TE_BEAMENTPOINT);
		m.WriteShort(target.entindex());
		m.WriteCoord(end.x);
		m.WriteCoord(end.y);
		m.WriteCoord(end.z);
		m.WriteShort(g_EngineFuncs.ModelIndex(sprite));
		m.WriteByte(frameStart);
		m.WriteByte(frameRate);
		m.WriteByte(life);
		m.WriteByte(width);
		m.WriteByte(noise);
		m.WriteByte(c.r);
		m.WriteByte(c.g);
		m.WriteByte(c.b);
		m.WriteByte(c.a); // actually brightness
		m.WriteByte(scroll);
		m.End();
	}
	
}




string GetHealthbotName()
{
	return "monster_healthbot";
}

void RegisterHealthbot()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "monster_healthbot", GetHealthbotName() );
}

