/*
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	Animals of SA-MP by Sound.
		Copyright 2016.
		
	File Version: 0.1
	
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	functions:
	
	CreateAnimal(type, Float:pX,  Float:pY,  Float:pZ, Float:angle, respawn = ANIMAL_RESPAWN_TIME, bool:revival = true, bool:inv = true, Float:health = 100.0);
	DestroyAnimsl(animalid);
	GetAnimalObjectID(animalid);
	GetAnimalPos(animalid, &Float:X, &Float:Y, &Float:Z);
	SetAnimalPos(animalid, Float:X, Float:Y, Float:Z);
	SetAnimalAngle(animalid, Float:angle);
	GetAnimalAngle(animalid, &Float:angle);
	IsAnimalInvulnerable(animalid);
	SetAnimalInvulnerable(animalid, bool: inv);
	SetAnimalHealth(animalid, Float:health);
	GetAnimalHealth(animalid, &Float:health);
	SetAnimalDamageFromWeapon(weaponid, Float:damage);
	MoveAnimal(animalid, Float:X, Float:Y, Float:Z, Float:speed);
	StopAnimal(animalid);
	SpawnAnimal(animalid);
	KillAnimal(animalid);
	IsAnimalLife(animalid);
	GetAnimalType(animalid);
	SetAnimalRevival(animalid, bool:rev);
	IsAnimalLife(animalid);
	GetCreateAnimals();
	IsValidAnimal(animalid);
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	CallBack:
	
	public OnPlayerGiveDamageAnimal(playerid, animalid, weaponid, Float:damage)
	public OnAnimalDeath(animalid, killerid)
	public OnAnimalSpawn(animalid)
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Macro:
	
	MAX_ANIMALS
	ANIMAL_RESPAWN_TIME
	ANIMAL_TYPE_COW
	ANIMAL_TYPE_DEER
	ANIMAL_TYPE_SHARK
	ANIMAL_TYPE_TURTLE
	ANIMAL_TYPE_DOLPHIN
*/

enum
{
	ANIMAL_TYPE_COW,
	ANIMAL_TYPE_DEER,
	ANIMAL_TYPE_SHARK,
	ANIMAL_TYPE_TURTLE,
	ANIMAL_TYPE_DOLPHIN,
	
	ANIMAL_RESPAWN_TIME = 3000,
	MAX_ANIMALS = 50,
	INVALID_ANIMAL_ID = -1
};

static const Float:so_inc@animal_fixz[] = {0.9, 0.5, 0.0, 0.5, 0.0};
static const Float:so_inc@animal_fixa[] = {180.0, 90.0, 0.0, 0.0, 0.0};
static const so_inc@animal_type_obj[] = {19833, 19315, 1608, 1609, 1607};
static Float:so_inc@animal_damage[] =
{
	0.5, 5.0, 10.0, 10.0, 10.0, 10.0 ,10.0,
	10.0, 10.0, 25.0, 10.0, 10.0, 10.0, 10.0,
	10.0, 10.0, 100.0, 0.0, 50.0 ,0.0, 0.0,
	0.0, 15.0, 15.0, 40.0, 30.0, 40.0, 40.0,
	15.0, 25.0, 35.0, 35.0, 15.0, 50.0, 50.0,
	100.0, 100.0, 5.0, 20.0
};

static so_inc@animal_count;
static so_inc@animals[MAX_ANIMALS] = {-1, ...};
static Float:so_inc@animal_pos_X[MAX_ANIMALS], Float:so_inc@animal_pos_Y[MAX_ANIMALS], Float:so_inc@animal_pos_Z[MAX_ANIMALS];
static Float:so_inc@animal_angle[MAX_ANIMALS];
static bool:so_inc@animal_inv[MAX_ANIMALS char];
static Float:so_inc@animal_health[MAX_ANIMALS];
static Float:so_inc@animal_heal_status[MAX_ANIMALS];
static so_inc@animal_type[MAX_ANIMALS char];
static so_inc@animal_life[MAX_ANIMALS char];
static so_inc@animal_revival[MAX_ANIMALS];
static so_inc@animal_respawn_time[MAX_ANIMALS];

stock CreateAnimal(type, Float:pX,  Float:pY,  Float:pZ, Float:angle, respawn = ANIMAL_RESPAWN_TIME, bool:revival = true, bool:inv = true, Float:health = 100.0)
{
	if(GetCreateAnimals() >= MAX_ANIMALS)
	    return -1;

	#if !defined Streamer_IncludeFileVersion
	so_inc@animals[so_inc@animal_count] = CreateDynamicObject(so_inc@animal_type_obj[type], pX, pY, pZ - so_inc@animal_fixz[type], 0.0, 0.0, angle + so_inc@animal_fixa[type]);
	#else
	so_inc@animals[so_inc@animal_count] = CreateDynamicObject(so_inc@animal_type_obj[type], pX, pY, pZ - so_inc@animal_fixz[type], 0.0, 0.0, angle + so_inc@animal_fixa[type]);
	#endif


	so_inc@animal_pos_X[so_inc@animal_count] = pX;
	so_inc@animal_pos_Y[so_inc@animal_count] = pY;
	so_inc@animal_pos_Z[so_inc@animal_count] = pZ;
	so_inc@animal_angle[so_inc@animal_count] = angle;
	so_inc@animal_inv{so_inc@animal_count} = inv;
	so_inc@animal_health[so_inc@animal_count] =
	so_inc@animal_heal_status[so_inc@animal_count] = health;
	so_inc@animal_type{so_inc@animal_count} = type;
	so_inc@animal_life{so_inc@animal_count} = true;
	so_inc@animal_revival{so_inc@animal_count} = revival;
	so_inc@animal_respawn_time[so_inc@animal_count] = respawn;
	new animalid = so_inc@animal_count;
	so_inc@animal_count++;

	return animalid;
}

stock DestroyAnimal(animalid)
{
	if(!IsValidAnimal(animalid))
	    return 0;
    #if !defined Streamer_IncludeFileVersion
	DestroyObject
	#else
	DestroyDynamicObject
	#endif
	(so_inc@animals[animalid]);


 	so_inc@animals[animalid] = -1;
	so_inc@animal_pos_X[animalid] =
	so_inc@animal_pos_Y[animalid] =
	so_inc@animal_pos_Z[animalid] =
	so_inc@animal_angle[animalid] =
	so_inc@animal_health[animalid] = 0.0;
	so_inc@animal_inv{animalid} = false;
	so_inc@animal_life{animalid} = true;

 	so_inc@animal_count--;

	return 1;
}

stock GetAnimalObjectID(animalid)
{
	if(!IsValidAnimal(animalid))
	    return INVALID_OBJECT_ID;
	return so_inc@animals[animalid];
}

stock GetAnimalPos(animalid, &Float:X, &Float:Y, &Float:Z)
{
    if(!IsValidAnimal(animalid))
	    return 0;
    #if !defined Streamer_IncludeFileVersion
	GetObjectPos
	#else
	GetDynamicObjectPos
	#endif
	(so_inc@animals[animalid], X, Y, Z);

	return 1;
}

stock SetAnimalPos(animalid, Float:X, Float:Y, Float:Z)
{
    if(!IsValidAnimal(animalid))
	    return 0;
    #if !defined Streamer_IncludeFileVersion
	SetObjectPos
	#else
	SetDynamicObjectPos
	#endif
    (so_inc@animals[animalid], X, Y, Z - so_inc@animal_fixz[GetAnimalType(animalid)]);
    
	return 1;
}

stock GetAnimalAngle(animalid, &Float:angle)
{
    if(!IsValidAnimal(animalid))
	    return 0;
	new Float:X, Float:Z, Float:Y;
	#if !defined Streamer_IncludeFileVersion
	GetObjectRot
	#else
	GetDynamicObjectRot
	#endif
	(so_inc@animals[animalid], X, Y, Z);
	
	angle = Z;

	return 1;
}

stock SetAnimalAngle(animalid, Float:angle)
{
    if(!IsValidAnimal(animalid))
	    return 0;
	#if !defined Streamer_IncludeFileVersion
	SetObjectRot
	#else
	SetDynamicObjectRot
	#endif
	(so_inc@animals[animalid], 0.0, 0.0, angle + so_inc@animal_fixa[GetAnimalType(animalid)]);

	return 1;
}

stock IsAnimalInvulnerable(animalid)
{
    if(!IsValidAnimal(animalid))
	    return 0;

	if(!so_inc@animal_inv{animalid})
	    return 0;

	return 1;
}

stock SetAnimalInvulnerable(animalid, bool: inv)
{
    if(!IsValidAnimal(animalid))
	    return 0;

    so_inc@animal_inv{animalid} = inv;

    return 1;
}

stock SetAnimalHealth(animalid, Float:health)
{
    if(!IsValidAnimal(animalid))
	    return 0;

	if(health <= 0.0)
	{
	    new Float:angle;
    	GetAnimalAngle(animalid, angle);
    	#if !defined Streamer_IncludeFileVersion
		SetObjectRot
		#else
		SetDynamicObjectRot
		#endif
		(so_inc@animals[animalid],
		(GetAnimalType(animalid) == ANIMAL_TYPE_DEER) ? (90.0) : (0.0),
		(GetAnimalType(animalid) == ANIMAL_TYPE_COW) ? (90.0) : (0.0),
		angle);
		so_inc@animal_life{animalid} = false;

 		OnAnimalDeath(animalid, INVALID_PLAYER_ID);
	}

	so_inc@animal_heal_status[animalid] = health;

	return 1;
}

stock GetAnimalHealth(animalid, &Float:health)
{
    if(!IsValidAnimal(animalid))
	    return 0;

	health = so_inc@animal_heal_status[animalid];

	return 1;
}

stock SetAnimalDamageFromWeapon(weaponid, Float:damage)
{
	if(weaponid > sizeof(so_inc@animal_damage))
		return 0;

	so_inc@animal_damage[weaponid] = damage;
	return 1;
}

stock MoveAnimal(animalid, Float:X, Float:Y, Float:Z, Float:speed)
{
    if(!IsValidAnimal(animalid))
	    return 0;

	new Float:aX, Float:aY, Float:aZ;
	GetAnimalPos(animalid, aX, aY, aZ);
	#if !defined Streamer_IncludeFileVersion
 	MoveObject
 	#else
 	MoveDynamicObject
 	#endif
 	(so_inc@animals[animalid], X, Y, Z - so_inc@animal_fixz[GetAnimalType(animalid)], speed);

	SetAnimalAngle(animalid, atan2(Y-aY, X-aX) - 90.0);

	return 1;
}

stock SpawnAnimal(animalid)
{
    if(!IsValidAnimal(animalid))
	    return 0;
	    
	return OnAnimalSpawn(animalid);
}

stock KillAnimal(animalid)
{
    if(!IsValidAnimal(animalid))
	    return 0;

    new Float:angle;
    GetAnimalAngle(animalid, angle);
    #if !defined Streamer_IncludeFileVersion
	SetObjectRot
	#else
	SetDynamicObjectRot
	#endif
	(so_inc@animals[animalid],
	(GetAnimalType(animalid) == ANIMAL_TYPE_DEER) ? (90.0) : (0.0),
	(GetAnimalType(animalid) == ANIMAL_TYPE_COW) ? (90.0) : (0.0),
	angle);
	
	new Float:X, Float:Y, Float:Z;
	#if !defined Streamer_IncludeFileVersion
	GetObjectPos
	#else
	GetDynamicObjectPos
	#endif
	(so_inc@animals[animalid], X, Y, Z);
	
	if(GetAnimalType(animalid) == ANIMAL_TYPE_DEER)
        #if !defined Streamer_IncludeFileVersion
		SetObjectPos
		#else
		SetDynamicObjectPos
		#endif
		(so_inc@animals[animalid], X, Y, Z - 0.4);

	so_inc@animal_life{animalid} = false;

 	return OnAnimalDeath(animalid, INVALID_PLAYER_ID);
}

stock SetAnimalRevival(animalid, bool:rev)
{
	if(!IsValidAnimal(animalid))
	    return 0;

	if(!so_inc@animal_revival{animalid})
	    return 0;

	return 1;
}

stock SetAnimalRespawnTime(animalid, respawn_time)
{
    if(!IsValidAnimal(animalid))
	    return 0;

	so_inc@animal_respawn_time[animalid] = respawn_time;

	return 1;
}

stock GetAnimalRespawnTime(animalid)
{
    if(!IsValidAnimal(animalid))
	    return 0;
	    
	return so_inc@animal_respawn_time[animalid];
}

stock StopAnimal(animalid)
{
    if(!IsValidAnimal(animalid))
	    return 0;
    #if !defined Streamer_IncludeFileVersion
    StopObject(so_inc@animals[animalid]);
    #else
    
    #endif

	return 1;
}

stock IsValidAnimal(animalid)
{
	if(so_inc@animals[animalid] == INVALID_ANIMAL_ID)
	    return 0;
	return 1;
}

stock GetCreateAnimals()
	return so_inc@animal_count;

stock GetAnimalType(animalid)
{
    if(!IsValidAnimal(animalid))
	    return -1;

	return so_inc@animal_type{animalid};
}

stock IsAnimalLife(animalid)
{
	if(!IsValidAnimal(animalid))
	    return -1;
	if(!so_inc@animal_life{animalid})
		return 0;
	return 1;
}

#if !defined Streamer_IncludeFileVersion
public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	if(hittype == BULLET_HIT_TYPE_OBJECT)
	{
	    for(new animalid; animalid < MAX_ANIMALS; animalid++)
	    {
			if(!IsValidAnimal(animalid))
			    continue;
	        if(hitid == so_inc@animals[animalid])
	        {
	            new Float:damage;
	            if(!so_inc@animal_inv{animalid} && so_inc@animal_life{animalid})
	            {
	            	damage = so_inc@animal_damage[weaponid];

	            	so_inc@animal_heal_status[animalid] -= damage;

					new Float:health;
					GetAnimalHealth(animalid, health);

					if(health <= 0.0)
					{
					    new Float:angle;
					    GetAnimalAngle(animalid, angle);
						SetObjectRot(so_inc@animals[animalid],
						(GetAnimalType(animalid) == ANIMAL_TYPE_DEER) ? (90.0) : (0.0),
					 	(GetAnimalType(animalid) == ANIMAL_TYPE_COW) ? (90.0) : (0.0),
			 			angle);

                        new Float:X, Float:Y, Float:Z;
						GetObjectPos(so_inc@animals[animalid], X, Y, Z);
						if(GetAnimalType(animalid) == ANIMAL_TYPE_DEER)
						SetObjectPos(so_inc@animals[animalid], X, Y, Z - 0.4);

						OnAnimalDeath(animalid, playerid);
						so_inc@animal_life{animalid} = false;
					}
					OnPlayerGiveDamageAnimal(playerid, animalid, weaponid, damage);
				}

	        }
	    }
	}
	return 1;
}
#else
public OnPlayerShootDynamicObject(playerid, weaponid, STREAMER_TAG_OBJECT objectid, Float:x, Float:y, Float:z)
{
	for(new animalid; animalid < MAX_ANIMALS; animalid++)
	{
		if(!IsValidAnimal(animalid))
			continue;
		if(objectid != so_inc@animals[animalid])
			continue;
			
		new Float:damage;
		if(!so_inc@animal_inv{animalid} && so_inc@animal_life{animalid})
		{
			damage = so_inc@animal_damage[weaponid];

			so_inc@animal_heal_status[animalid] -= damage;

			new Float:health;
			GetAnimalHealth(animalid, health);
			if(health <= 0.0)
			{
				new Float:angle;
				GetAnimalAngle(animalid, angle);
				SetDynamicObjectRot(so_inc@animals[animalid],
				(GetAnimalType(animalid) == ANIMAL_TYPE_DEER) ? (90.0) : (0.0),
				(GetAnimalType(animalid) == ANIMAL_TYPE_COW) ? (90.0) : (0.0),
				angle);

				new Float:X, Float:Y, Float:Z;
				GetDynamicObjectPos(so_inc@animals[animalid], X, Y, Z);
				if(GetAnimalType(animalid) == ANIMAL_TYPE_DEER)
				SetDynamicObjectPos(so_inc@animals[animalid], X, Y, Z - 0.4);

				OnAnimalDeath(animalid, playerid);
				so_inc@animal_life{animalid} = false;
			}
			OnPlayerGiveDamageAnimal(playerid, animalid, weaponid, damage);
		}

	}
	return 1;
}
#endif

forward OnPlayerGiveDamageAnimal(playerid, animalid, weaponid, Float:damage);
public OnPlayerGiveDamageAnimal(playerid, animalid, weaponid, Float:damage)
{
	return 1;
}
#if defined _ALS_OnPlayerGiveDamageAnimal
	#undef	OnPlayerGiveDamageAnimal
#else
	#define	_ALS_OnPlayerGiveDamageAnimal
#endif
#if	defined	so_pub_OnPlayerGiveDamageAnimal
	forward so_pub_OnPlayerGiveDamageAnimal(playerid, animalid, weaponid, Float:damage);
#endif
#define	OnPlayerGiveDamageAnimal so_pub_OnPlayerGiveDamageAnimal

forward OnAnimalDeath(animalid, killerid);
public OnAnimalDeath(animalid, killerid)
{
	StopAnimal(animalid);
	if(GetAnimalRespawnTime(animalid) && so_inc@animal_revival{animalid})
		SetTimerEx("OnAnimalSpawn", GetAnimalRespawnTime(animalid), false, "i", animalid);
	return 1;
}
#if defined _ALS_OnAnimalDeath
	#undef	OnAnimalDeath
#else
	#define	_ALS_OnAnimalDeath
#endif
#if	defined	so_pub_OnAnimalDeath
	forward so_pub_OnAnimalDeath(animalid, killerid);
#endif
#define	OnAnimalDeath so_pub_OnAnimalDeath

forward OnAnimalSpawn(animalid);
public OnAnimalSpawn(animalid)
{
	StopAnimal(animalid);
	SetAnimalPos(animalid, so_inc@animal_pos_X[animalid], so_inc@animal_pos_Y[animalid], so_inc@animal_pos_Z[animalid]);
	SetAnimalAngle(animalid, so_inc@animal_angle[animalid]);
	
	so_inc@animal_life{animalid} = true;
	so_inc@animal_heal_status[animalid] = so_inc@animal_health[animalid];
	return 1;
}
#if defined _ALS_OnAnimalSpawn
	#undef	OnAnimalSpawn
#else
	#define	_ALS_OnAnimalSpawn
#endif
#if	defined	so_pub_OnAnimalSpawn
	forward so_pub_OnAnimalSpawn(animalid);
#endif
#define	OnAnimalSpawn so_pub_OnAnimalSpawn
