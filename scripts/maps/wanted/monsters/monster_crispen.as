namespace HLWanted_Crispen
{
class monster_crispen : ScriptBaseMonsterEntity
{
	array<string> g_Sounds =
	{
		"wanted/crispen/abandon.wav",
		"wanted/crispen/absolutlynot.wav",
		"wanted/crispen/allrightthen.wav",
		"wanted/crispen/amazongreen.wav",
		"wanted/crispen/askoldzeke.wav",
		"wanted/crispen/asksomeoneelse.wav",
		"wanted/crispen/barkingmad.wav",
		"wanted/crispen/beansinatin.wav",
		"wanted/crispen/bloodonshirt.wav",
		"wanted/crispen/breakrules.wav",
		"wanted/crispen/breath.wav",
		"wanted/crispen/brigands.wav",
		"wanted/crispen/butterflys.wav",
		"wanted/crispen/canihelpyou.wav",
		"wanted/crispen/cleanmess.wav",
		"wanted/crispen/cleanshoes.wav",
		"wanted/crispen/creatediversion.wav",
		"wanted/crispen/cstelegram.wav",
		"wanted/crispen/damagestuff.wav",
		"wanted/crispen/dawsontoday.wav",
		"wanted/crispen/deargod.wav",
		"wanted/crispen/dontgo.wav",
		"wanted/crispen/duster.wav",
		"wanted/crispen/frightfull.wav",
		"wanted/crispen/gazzette.wav",
		"wanted/crispen/gooddaytoyou.wav",
		"wanted/crispen/goodmorning.wav",
		"wanted/crispen/goodness.wav",
		"wanted/crispen/hearsomething.wav",
		"wanted/crispen/hellothere.wav",
		"wanted/crispen/help.wav",
		"wanted/crispen/helpothers.wav",
		"wanted/crispen/hogwash.wav",
		"wanted/crispen/ibegpardon.wav",
		"wanted/crispen/icantsay.wav",
		"wanted/crispen/idlechatter.wav",
		"wanted/crispen/idontknow.wav",
		"wanted/crispen/illstay.wav",
		"wanted/crispen/illwait.wav",
		"wanted/crispen/inonepiece.wav",
		"wanted/crispen/intherules.wav",
		"wanted/crispen/intollerable.wav",
		"wanted/crispen/isaywhat.wav",
		"wanted/crispen/knockbrd.wav",
		"wanted/crispen/letsgeton.wav",
		"wanted/crispen/listentoreason.wav",
		"wanted/crispen/makeapie.wav",
		"wanted/crispen/mrblack.wav",
		"wanted/crispen/mummmmy.wav",
		"wanted/crispen/mummy.wav",
		"wanted/crispen/mycollection.wav",
		"wanted/crispen/myglasses.wav",
		"wanted/crispen/needsomeofthis.wav",
		"wanted/crispen/notstep.wav",
		"wanted/crispen/ohdear.wav",
		"wanted/crispen/ohhh.wav",
		"wanted/crispen/ohmyword.wav",
		"wanted/crispen/pain1.wav",
		"wanted/crispen/pain2.wav",
		"wanted/crispen/pain3.wav",
		"wanted/crispen/pain4.wav",
		"wanted/crispen/pain5.wav",
		"wanted/crispen/pieceofmind.wav",
		"wanted/crispen/playingat.wav",
		"wanted/crispen/polishbrass.wav",
		"wanted/crispen/polishshoes.wav",
		"wanted/crispen/polishstove.wav",
		"wanted/crispen/postulate.wav",
		"wanted/crispen/pressing.wav",
		"wanted/crispen/prizebirds.wav",
		"wanted/crispen/redwing.wav",
		"wanted/crispen/ruffians.wav",
		"wanted/crispen/rule27b.wav",
		"wanted/crispen/rulost.wav",
		"wanted/crispen/saidyouweredead.wav",
		"wanted/crispen/scream0.wav",
		"wanted/crispen/scream1.wav",
		"wanted/crispen/scream3.wav",
		"wanted/crispen/scream4.wav",
		"wanted/crispen/section12.wav",
		"wanted/crispen/seendawson.wav",
		"wanted/crispen/seenpreacher.wav",
		"wanted/crispen/seentoday.wav",
		"wanted/crispen/sheriffthankgod.wav",
		"wanted/crispen/sipofthis.wav",
		"wanted/crispen/spoiledpie.wav",
		"wanted/crispen/spottedadmiral.wav",
		"wanted/crispen/stayhere.wav",
		"wanted/crispen/stoleduster.wav",
		"wanted/crispen/stopshouting.wav",
		"wanted/crispen/telegraphed.wav",
		"wanted/crispen/telnorp.wav",
		"wanted/crispen/thankyourback.wav",
		"wanted/crispen/vilesmell.wav",
		"wanted/crispen/whatrudoing.wav",
		"wanted/crispen/whatuse.wav",
		"wanted/crispen/whatwasthat.wav",
		"wanted/crispen/whydidimove.wav",
		"wanted/crispen/wipelips.wav",
		"wanted/crispen/writeletter.wav",
		"wanted/crispen/writeninbook.wav",
		"wanted/crispen/yesmaybeeno.wav",
		"wanted/crispen/youarecrazy.wav",
		"wanted/crispen/yourwounded.wav"
	};

	void Precache()
	{
		g_Game.PrecacheModel( "models/wanted/crispen.mdl" );

		for( uint uiIndex = 0; uiIndex < g_Sounds.length(); ++uiIndex )
		{
			g_SoundSystem.PrecacheSound( g_Sounds[uiIndex] ); // cache
			g_Game.PrecacheGeneric( "sound/" + g_Sounds[uiIndex] ); // client has to download
		}
	}

	void Spawn( void )
	{
		Precache();

		pev.solid = SOLID_NOT;

		dictionary keyvalues = {
			{ "model", "models/wanted/crispen.mdl" },
			{ "soundlist", "../wanted/crispen/crispen.txt" },
			{ "is_not_revivable", "1" },
			{ "displayname", "Crispen Smythe" }
		};
		CBaseEntity@ pEntity = g_EntityFuncs.CreateEntity( "monster_scientist", keyvalues, false );

		CBaseMonster@ pSci = pEntity.MyMonsterPointer();

		pSci.pev.origin = pev.origin;
		pSci.pev.angles = pev.angles;
		pSci.pev.health = pev.health;
		pSci.pev.targetname = pev.targetname;
		pSci.pev.netname = pev.netname;
		pSci.pev.weapons = pev.weapons;
		pSci.pev.body = pev.body;
		pSci.pev.skin = pev.skin;
		pSci.pev.mins = pev.mins;
		pSci.pev.maxs = pev.maxs;
		pSci.pev.scale = pev.scale;
		pSci.pev.rendermode = pev.rendermode;
		pSci.pev.renderamt = pev.renderamt;
		pSci.pev.rendercolor = pev.rendercolor;
		pSci.pev.renderfx = pev.renderfx;
		pSci.pev.spawnflags = pev.spawnflags;

		g_EntityFuncs.DispatchSpawn( pSci.edict() );

		pSci.m_iTriggerCondition = self.m_iTriggerCondition;
		pSci.m_iszTriggerTarget = self.m_iszTriggerTarget;

		g_EntityFuncs.Remove( self );
	}
}

class monster_crispen_dead : ScriptBaseMonsterEntity
{
	int m_iPose = 0;
	private array<string>m_szPoses = { "lying_on_back", "lying_on_stomach", "dead_sitting", "dead_hang", "dead_table1", "dead_table2", "dead_table3" };

	bool KeyValue( const string& in szKey, const string& in szValue )
	{
		if( szKey == "pose" )
		{
			m_iPose = atoi( szValue );
			return true;
		}
		else
			return BaseClass.KeyValue( szKey, szValue );
	}

	void Precache()
	{
		if( string( self.pev.model ).IsEmpty() )
			g_Game.PrecacheModel( self, "models/wanted/crispen.mdl" );
		else
			g_Game.PrecacheModel( self, self.pev.model );
	}

	void Spawn()
	{
		Precache();

		if( string( self.pev.model ).IsEmpty() )
			g_EntityFuncs.SetModel( self, "models/wanted/crispen.mdl" );
		else
			g_EntityFuncs.SetModel( self, self.pev.model );

		const float flHealth = self.pev.health;

		self.MonsterInitDead();

		self.pev.health = flHealth;

		if( self.pev.health == 0 )
			self.pev.health = 8;

		self.m_bloodColor 	= BLOOD_COLOR_RED;
		self.pev.solid 		= SOLID_SLIDEBOX;
		self.pev.movetype 	= MOVETYPE_STEP;
		self.pev.takedamage 	= DAMAGE_YES;

		self.SetClassification( CLASS_PLAYER_ALLY );

		self.m_FormattedName = "Dead Crispen";

		self.pev.sequence = self.LookupSequence( m_szPoses[m_iPose] );
		if ( self.pev.sequence == -1 )
		{
			g_Game.AlertMessage( at_console, "Dead crispen with bad pose\n" );
		}
	}
}

void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Crispen::monster_crispen", "monster_crispen" );
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_Crispen::monster_crispen_dead", "monster_crispen_dead" );
}

} // end of HLWanted_Crispen namespace