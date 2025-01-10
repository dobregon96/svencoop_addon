namespace HLWanted_TownWes
{
enum BodyGroup
{
	BODYGROUP_BODY = 0,
	BODYGROUP_HEAD,
	BODYGROUP_BOTTLE
}

enum HeadSubModel
{
	HEAD_1 = 0,
	HEAD_2,
	HEAD_3,
	HEAD_4
}

enum BottleSubModel
{
	NONE = 0,
	BOTTLE
}

array<string> g_Sounds =
{
	"wanted/twnwest/absolutely.wav",
	"wanted/twnwest/aintserious.wav",
	"wanted/twnwest/allright.wav",
	"wanted/twnwest/alwayswanted.wav",
	"wanted/twnwest/areyouthinkin.wav",
	"wanted/twnwest/armyleftfort.wav",
	"wanted/twnwest/askyouthat.wav",
	"wanted/twnwest/backeast.wav",
	"wanted/twnwest/backofhorse.wav",
	"wanted/twnwest/beansinatin.wav",
	"wanted/twnwest/braypass.wav",
	"wanted/twnwest/breifboys.wav",
	"wanted/twnwest/cantgetworse.wav",
	"wanted/twnwest/cantgofurther.wav",
	"wanted/twnwest/cantsayiknow.wav",
	"wanted/twnwest/carveontomb.wav",
	"wanted/twnwest/catchmeone.wav",
	"wanted/twnwest/catfish.wav",
	"wanted/twnwest/cavelryrescue.wav",
	"wanted/twnwest/chickenfeed.wav",
	"wanted/twnwest/cleanthrough.wav",
	"wanted/twnwest/couldbe.wav",
	"wanted/twnwest/couldbezeke.wav",
	"wanted/twnwest/cyotees.wav",
	"wanted/twnwest/damnboxes.wav",
	"wanted/twnwest/dangwhatnext.wav",
	"wanted/twnwest/didyouhearthat.wav",
	"wanted/twnwest/diejustyet.wav",
	"wanted/twnwest/digholes.wav",
	"wanted/twnwest/dontknowsure.wav",
	"wanted/twnwest/dontwhy.wav",
	"wanted/twnwest/dumbquestions.wav",
	"wanted/twnwest/eatsnake.wav",
	"wanted/twnwest/eggs.wav",
	"wanted/twnwest/erryousure.wav",
	"wanted/twnwest/fear0.wav",
	"wanted/twnwest/fear6.wav",
	"wanted/twnwest/feedchickens.wav",
	"wanted/twnwest/fineday.wav",
	"wanted/twnwest/fleshwound.wav",
	"wanted/twnwest/forgotwhatsaying.wav",
	"wanted/twnwest/gangresponsible.wav",
	"wanted/twnwest/gitaway.wav",
	"wanted/twnwest/givenyouup.wav",
	"wanted/twnwest/goodday.wav",
	"wanted/twnwest/goodtoseeyou.wav",
	"wanted/twnwest/gooncatchup.wav",
	"wanted/twnwest/goongit.wav",
	"wanted/twnwest/greasyhair.wav",
	"wanted/twnwest/grizzlybear.wav",
	"wanted/twnwest/gunbeltlikethat.wav",
	"wanted/twnwest/gurdengulch.wav",
	"wanted/twnwest/hangedbandits.wav",
	"wanted/twnwest/harmonica.wav",
	"wanted/twnwest/hearmovin.wav",
	"wanted/twnwest/hearsomethin.wav",
	"wanted/twnwest/hello.wav",
	"wanted/twnwest/hello2.wav",
	"wanted/twnwest/hellothere.wav",
	"wanted/twnwest/heytheresherrif.wav",
	"wanted/twnwest/horse.wav",
	"wanted/twnwest/horseshoe.wav",
	"wanted/twnwest/hossbank.wav",
	"wanted/twnwest/Howdy.wav",
	"wanted/twnwest/howdypardner.wav",
	"wanted/twnwest/howdysheriff.wav",
	"wanted/twnwest/idontthinkso.wav",
	"wanted/twnwest/iguess.wav",
	"wanted/twnwest/ihavenoidea.wav",
	"wanted/twnwest/ihearddifferent.wav",
	"wanted/twnwest/ihearsomethin.wav",
	"wanted/twnwest/ihopeyoukno.wav",
	"wanted/twnwest/illberightb.wav",
	"wanted/twnwest/illfireashot.wav",
	"wanted/twnwest/imagonner.wav",
	"wanted/twnwest/imhurtbad.wav",
	"wanted/twnwest/imnotsure.wav",
	"wanted/twnwest/injuntrick.wav",
	"wanted/twnwest/ireckonso.wav",
	"wanted/twnwest/ithinkilljust.wav",
	"wanted/twnwest/justplaincrazy.wav",
	"wanted/twnwest/juststayaspell.wav",
	"wanted/twnwest/keystothebank.wav",
	"wanted/twnwest/kindabusy.wav",
	"wanted/twnwest/leftmyhorse.wav",
	"wanted/twnwest/letssaddleup.wav",
	"wanted/twnwest/liftdead.wav",
	"wanted/twnwest/liketrouble.wav",
	"wanted/twnwest/luckchange.wav",
	"wanted/twnwest/mabelshen.wav",
	"wanted/twnwest/maddernsnake.wav",
	"wanted/twnwest/makebetter.wav",
	"wanted/twnwest/makeoutalive.wav",
	"wanted/twnwest/maybee.wav",
	"wanted/twnwest/medicinal.wav",
	"wanted/twnwest/mexicanfellers.wav",
	"wanted/twnwest/mornin.wav",
	"wanted/twnwest/mouthfull.wav",
	"wanted/twnwest/movingpictures.wav",
	"wanted/twnwest/myshotgun.wav",
	"wanted/twnwest/newplow.wav",
	"wanted/twnwest/newsmen.wav",
	"wanted/twnwest/no.wav",
	"wanted/twnwest/nodenyinit.wav",
	"wanted/twnwest/nodoubtinit.wav",
	"wanted/twnwest/nogo.wav",
	"wanted/twnwest/noo.wav",
	"wanted/twnwest/nope.wav",
	"wanted/twnwest/nothinasbad.wav",
	"wanted/twnwest/notwithoutarifle.wav",
	"wanted/twnwest/ofcourse.wav",
	"wanted/twnwest/ofcourseitaint.wav",
	"wanted/twnwest/ohdarn.wav",
	"wanted/twnwest/ohdarnit.wav",
	"wanted/twnwest/ohhell.wav",
	"wanted/twnwest/ohno.wav",
	"wanted/twnwest/ohno2.wav",
	"wanted/twnwest/ohnoo.wav",
	"wanted/twnwest/ohnooo.wav",
	"wanted/twnwest/oillamps.wav",
	"wanted/twnwest/okletsgo.wav",
	"wanted/twnwest/oksheriff.wav",
	"wanted/twnwest/olddays.wav",
	"wanted/twnwest/oldman.wav",
	"wanted/twnwest/oldsheriff.wav",
	"wanted/twnwest/oldzeke.wav",
	"wanted/twnwest/onlywayout.wav",
	"wanted/twnwest/outaherealive.wav",
	"wanted/twnwest/outlawskillus.wav",
	"wanted/twnwest/overheard.wav",
	"wanted/twnwest/overhere.wav",
	"wanted/twnwest/pain1.wav",
	"wanted/twnwest/pain2.wav",
	"wanted/twnwest/pain3.wav",
	"wanted/twnwest/pain4.wav",
	"wanted/twnwest/pain5.wav",
	"wanted/twnwest/pearlhandledcolts.wav",
	"wanted/twnwest/pinebox.wav",
	"wanted/twnwest/plainmadness.wav",
	"wanted/twnwest/pleaseno.wav",
	"wanted/twnwest/poker.wav",
	"wanted/twnwest/pokergame.wav",
	"wanted/twnwest/possie.wav",
	"wanted/twnwest/preacher.wav",
	"wanted/twnwest/prizechicken.wav",
	"wanted/twnwest/pushit.wav",
	"wanted/twnwest/railroad.wav",
	"wanted/twnwest/rainthisyear.wav",
	"wanted/twnwest/readnwrite.wav",
	"wanted/twnwest/right.wav",
	"wanted/twnwest/rogan.wav",
	"wanted/twnwest/roswell.wav",
	"wanted/twnwest/saloonopen.wav",
	"wanted/twnwest/scream0.wav",
	"wanted/twnwest/scream1.wav",
	"wanted/twnwest/scream2.wav",
	"wanted/twnwest/scream3.wav",
	"wanted/twnwest/scream4.wav",
	"wanted/twnwest/scream6.wav",
	"wanted/twnwest/scream7.wav",
	"wanted/twnwest/scream8.wav",
	"wanted/twnwest/scream9.wav",
	"wanted/twnwest/seenanything.wav",
	"wanted/twnwest/seeyoualive.wav",
	"wanted/twnwest/shotofthis.wav",
	"wanted/twnwest/shutup.wav",
	"wanted/twnwest/smellsmoke.wav",
	"wanted/twnwest/smellsomethin.wav",
	"wanted/twnwest/smellsouthouse.wav",
	"wanted/twnwest/somefolksayso.wav",
	"wanted/twnwest/sortthismess.wav",
	"wanted/twnwest/spurs.wav",
	"wanted/twnwest/stagelate.wav",
	"wanted/twnwest/stichmeup.wav",
	"wanted/twnwest/stoneinmyboot.wav",
	"wanted/twnwest/stopattacking.wav",
	"wanted/twnwest/stopyellin.wav",
	"wanted/twnwest/supplies.wav",
	"wanted/twnwest/sureboutthat.wav",
	"wanted/twnwest/swigofthis.wav",
	"wanted/twnwest/takemuchmore.wav",
	"wanted/twnwest/tellwheresherrif.wav",
	"wanted/twnwest/thatsjustfine.wav",
	"wanted/twnwest/thereaintnoway.wav",
	"wanted/twnwest/toodangerous.wav",
	"wanted/twnwest/tryashot.wav",
	"wanted/twnwest/tumbleweed.wav",
	"wanted/twnwest/twoheadedchicken.wav",
	"wanted/twnwest/undertaker.wav",
	"wanted/twnwest/useadrink.wav",
	"wanted/twnwest/useashot.wav",
	"wanted/twnwest/useshuteye.wav",
	"wanted/twnwest/waistcoat.wav",
	"wanted/twnwest/waithere.wav",
	"wanted/twnwest/waiting.wav",
	"wanted/twnwest/waytosaftey.wav",
	"wanted/twnwest/whatareyoudoin.wav",
	"wanted/twnwest/whatisit.wav",
	"wanted/twnwest/whatisnoise.wav",
	"wanted/twnwest/whatsthatsmell.wav",
	"wanted/twnwest/whatthe.wav",
	"wanted/twnwest/whatthehell.wav",
	"wanted/twnwest/whisky.wav",
	"wanted/twnwest/whiskyforpain.wav",
	"wanted/twnwest/whosside.wav",
	"wanted/twnwest/whyareyouaskin.wav",
	"wanted/twnwest/women.wav",
	"wanted/twnwest/wonderaboutdyin.wav",
	"wanted/twnwest/woundbad.wav",
	"wanted/twnwest/yep.wav",
	"wanted/twnwest/yeraintgoin.wav",
	"wanted/twnwest/yerwounded.wav",
	"wanted/twnwest/yessiree.wav",
	"wanted/twnwest/yougoonslow.wav",
	"wanted/twnwest/yourguess.wav",
	"wanted/twnwest/youthinkin.wav",
	"wanted/twnwest/yup.wav",
	"wanted/twnwest/zekeslongjons.wav",
	"wanted/twnwest/zekesnore.wav",
	"wanted/twnwest/_comma.wav"
};

class monster_twnwesta : ScriptBaseMonsterEntity
{
	void Precache()
	{
		g_Game.PrecacheModel( "models/wanted/twnwesta.mdl" );

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

		if( pev.body == -1 )
			self.SetBodygroup( BODYGROUP_HEAD, Math.RandomLong(HEAD_1, HEAD_4) );

		dictionary keyvalues = {
			{ "model", "models/wanted/twnwesta.mdl" },
			{ "soundlist", "../wanted/twnwest/townwest.txt" },
			{ "is_not_revivable", "1" },
			{ "displayname", "Townie" }
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

class monster_twnwesta_dead : ScriptBaseMonsterEntity
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
			g_Game.PrecacheModel( self, "models/wanted/twnwesta.mdl" );
		else
			g_Game.PrecacheModel( self, self.pev.model );
	}

	void Spawn()
	{
		Precache();

		if( string( self.pev.model ).IsEmpty() )
			g_EntityFuncs.SetModel( self, "models/wanted/twnwesta.mdl" );
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

		self.m_FormattedName = "Dead Townie";

		if( pev.body == -1 )
			self.SetBodygroup( BODYGROUP_HEAD, Math.RandomLong(HEAD_1, HEAD_4) );

		self.pev.sequence = self.LookupSequence( m_szPoses[m_iPose] );
		if ( self.pev.sequence == -1 )
		{
			g_Game.AlertMessage( at_console, "Dead townie with bad pose\n" );
		}
	}
}

class monster_twnwestb : ScriptBaseMonsterEntity
{
	void Precache()
	{
		g_Game.PrecacheModel( "models/wanted/twn2west.mdl" );

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

		if( pev.body == -1 )
			self.SetBodygroup( BODYGROUP_HEAD, Math.RandomLong(HEAD_1, HEAD_4) );

		dictionary keyvalues = {
			{ "model", "models/wanted/twn2west.mdl" },
			{ "soundlist", "../wanted/twnwest/townwest.txt" },
			{ "is_not_revivable", "1" },
			{ "displayname", "Townie" }
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

		g_EntityFuncs.DispatchKeyValue( pSci.edict(), "UnUseSentence", "+" + "wanted/twnwest/ithinkilljust.wav" );
		g_EntityFuncs.DispatchKeyValue( pSci.edict(), "UseSentence", "+" + "wanted/twnwest/ithinkilljust.wav" );

		pSci.m_iTriggerCondition = self.m_iTriggerCondition;
		pSci.m_iszTriggerTarget = self.m_iszTriggerTarget;

		g_EntityFuncs.Remove( self );
	}
}

class monster_twnwestb_dead : ScriptBaseMonsterEntity
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
			g_Game.PrecacheModel( self, "models/wanted/twn2west.mdl" );
		else
			g_Game.PrecacheModel( self, self.pev.model );
	}

	void Spawn()
	{
		Precache();

		if( string( self.pev.model ).IsEmpty() )
			g_EntityFuncs.SetModel( self, "models/wanted/twn2west.mdl" );
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

		self.m_FormattedName = "Dead Townie";

		if( pev.body == -1 )
			self.SetBodygroup( BODYGROUP_HEAD, Math.RandomLong(HEAD_1, HEAD_4) );

		self.pev.sequence = self.LookupSequence( m_szPoses[m_iPose] );
		if ( self.pev.sequence == -1 )
		{
			g_Game.AlertMessage( at_console, "Dead townie with bad pose\n" );
		}
	}
}

void Register()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_TownWes::monster_twnwesta", "monster_twnwesta" );
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_TownWes::monster_twnwesta_dead", "monster_twnwesta_dead" );
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_TownWes::monster_twnwestb", "monster_twnwestb" );
	g_CustomEntityFuncs.RegisterCustomEntity( "HLWanted_TownWes::monster_twnwestb_dead", "monster_twnwestb_dead" );

	g_Game.PrecacheModel( "models/scientist.mdl" ); // Otherwise it causes Host Error when spawning via entity maker
}

} // end of HLWanted_TownWes namespace