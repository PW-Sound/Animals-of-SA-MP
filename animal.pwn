#include <a_samp>
//#include <streamer>
#include <a_mysql>

/*
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	Animals of SA-MP by Sound.
		Copyright 2016.

	File Version: 0.2.0

	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	functions:

	CreateAnimal(type, Float:pX,  Float:pY,  Float:pZ, Float:angle, respawn = ANIMAL_RESPAWN_TIME, bool:inv = true, Float:health = 100.0);
	DestroyAnimal(animalid);
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
	IsAnimalLife(animalid);
	GetCreateAnimals();
	IsValidAnimal(animalid);
	SetAnimalBloodWhenFired(animalid, bool:blood);
	IsAnimalBlood(animalid);
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
	~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	Change:

	* 0.1.0
	- Release

	* 0.1.1
	- Исправлена функция SetAnimalRevival.
	- Добавленно описание каждой функции.
	- Исправленны автовызываемые функции.
	
	* 0.1.2
	- Исправлена ошибка при создании животного.
	- Исправлены серьезные недочеты.
	
	* 0.2.0
	- Добавлены функции SetAnimalBlood и IsAnimalBlood
	- Исправлены некотрые недочеты.
	- Удалена функция SetAnimalRevival
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

													 Специально для Pawn-Wiki.ru
*/
forward OnPlayerGiveDamageAnimal(playerid, animalid, weaponid, Float:damage);
forward OnAnimalDeath(animalid, killerid);
forward OnAnimalSpawn(animalid);

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
static so_inc@animal_respawn_time[MAX_ANIMALS];
static so_inc@animal_blood[MAX_ANIMALS char];
static so_inc@animal_blood_obj[MAX_ANIMALS];

/*
	Функция CreateAnimal: Создает животное.

	Параметры:
	type - Тип животного.
	Float:X - Кооридината по оси X.
	Float:Y - Кооридината по оси Y.
	Float:Z - Кооридината по оси Z.
	Float:angle - Угол поворота животного.
	respawn - Время, через которое животное заспавнится после смерти.
	bool:inv - Уязвимо ли животное.
	Float:health - Кол-во здоровья.

	Возвращает: ID созданого животного.
*/

stock CreateAnimal(type, Float:pX,  Float:pY,  Float:pZ, Float:angle, respawn = ANIMAL_RESPAWN_TIME, bool:inv = true, Float:health = 100.0)
{
	if(GetCreateAnimals() >= MAX_ANIMALS)
	    return -1;

	#if !defined Streamer_IncludeFileVersion
	so_inc@animals[so_inc@animal_count] = CreateObject(so_inc@animal_type_obj[type], pX, pY, pZ - so_inc@animal_fixz[type], 0.0, 0.0, angle + so_inc@animal_fixa[type]);
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
	so_inc@animal_respawn_time[so_inc@animal_count] = respawn;
	new animalid = so_inc@animal_count;
	so_inc@animal_count++;

	return animalid;
}
/*
	Функция DestroyAnimal: Удаляет животное.

	Параметры: animalid - ID существуещего животного.

	Возвращает: 1 при успешном удалении и 0, если животное не существует.
*/

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
/*
	Функция GetAnimalObjectID: Узнает ID объекта животного.

	Параметры: animalid - ID существуещего животного.

	Возвращает: ID объекта и INVALID_OBJECT_ID, если животное не существует.
*/
stock GetAnimalObjectID(animalid)
{
	if(!IsValidAnimal(animalid))
	    return INVALID_OBJECT_ID;
	return so_inc@animals[animalid];
}
/*
	Функция GetAnimalPos: Узнает позицию животного.

	Параметры:
	animalid - ID существуещего животного.
	&Float:X - Переменная для записи координаты оси X.
	&Float:Y - Переменная для записи координаты оси Y.
	&Float:Z - Переменная для записи координаты оси Z.

	Возвращает: 1 если функция успешна и 0, если животное не существует.
*/
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
/*
	Функция SetAnimalPos: Устанавливает позицию животного.

	Параметры:
	animalid - ID существуещего животного.
	Float:X - Координата по оси X.
	Float:Y - Координата по оси Y.
	Float:Z - Координата по оси Z.

	Возвращает: 1 если функция успешна и 0, если животное не существует.
*/
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
/*
	Функция GetAnimalAngle: Узнает угол поворота животного.

	Параметры:
	animalid - ID существуещего животного.
	&Float:angle - Переменная для записи угла поворота.

	Возвращает: 1 если функция успешна и 0, если животное не существует.
*/
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
/*
	Функция SetAnimalAngle: Устанавливает угол поворота животного.

	Параметры:
	animalid - ID существуещего животного.
	&Float:angle - Угол поворота.

	Возвращает: 1 если функция успешна и 0, если животное не существует.
*/
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
/*
	Функция IsAnimalInvulnerable: Узнает уязвимо ли животное.

	Параметры: animalid - ID существуещего животного.

	Возвращает: 1 если животное уязвимо и 0, если не уязвимо или животное не существует.
*/
stock IsAnimalInvulnerable(animalid)
{
    if(!IsValidAnimal(animalid))
	    return 0;

	if(!so_inc@animal_inv{animalid})
	    return 0;

	return 1;
}
/*
	Функция SetAnimalInvulnerable: Устанавливает уязвимость животному.

	Параметры:
	animalid - ID существуещего животного.
	bool:inv - Установить уязвимость.

	Возвращает: 1 если функция выполнена успешно и 0, если животное не существует.
*/
stock SetAnimalInvulnerable(animalid, bool: inv)
{
    if(!IsValidAnimal(animalid))
	    return 0;

    so_inc@animal_inv{animalid} = inv;

    return 1;
}
/*
	Функция SetAnimalHealth: Устанавливает здоровье животному.

	Параметры:
	animalid - ID существуещего животного.
	Float:health - Кол-во здоровья.

	Возвращает: 1 если функция выполнена успешно и 0, если животное не существует.
*/
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
/*
	Функция GetAnimalHealth: Получает кол-во здоровья животного.

	Параметры:
	animalid - ID существуещего животного.
	?Float:health - Переменная для записи здоровья.

	Возвращает: 1 если функция выполнена успешно и 0, если животное не существует.
*/
stock GetAnimalHealth(animalid, &Float:health)
{
    if(!IsValidAnimal(animalid))
	    return 0;

	health = so_inc@animal_heal_status[animalid];

	return 1;
}
/*
	Функция SetAnimalDamageFromWeapon: Устанавливает урон от опеределенного оружия.

	Параметры:
	weaponid - ID оружия.
	Float:damage - Кол-во урона.

	Возвращает: 1 если функция выполнена успешно и 0, если было указанно невалидный ID оружия.
*/
stock SetAnimalDamageFromWeapon(weaponid, Float:damage)
{
	if(weaponid > sizeof(so_inc@animal_damage))
		return 0;

	so_inc@animal_damage[weaponid] = damage;
	return 1;
}
/*
	Функция MoveAnimal: Включает движение животного.

	Параметры:
	animalid - ID животного.
	Float:X - Координата движения до оси X.
	Float:Y - Координата движения до оси Y.
	Float:Z - Координата движения до оси Z.
	Float:speed - Скорость движения.

	Возвращает: 1 если функция выполнена успешно и 0, если животное не существует.
*/
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
/*
	Функция SpawnAnimal: Респавнит животное.

	Параметры:
	animalid - ID животного.

	Возвращает: 1 если функция выполнена успешно и 0, если животное не существует.
*/
stock SpawnAnimal(animalid)
{
    if(!IsValidAnimal(animalid))
	    return 0;

	return OnAnimalSpawn(animalid) & 1;
}
/*
	Функция KillAmimal: Убивает животное.

	Параметры:
	animalid - ID животного.

	Возвращает: 1 если функция выполнена успешно и 0, если животное не существует.
*/
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

 	return OnAnimalDeath(animalid, INVALID_PLAYER_ID) & 1;
}
/*
	Функция SetAnimalRespawnTime: Устанавливает время респавна животного.

	Параметры:
	animalid - ID животного.
	respawn_time - Время респавна.

	Возвращает: 1 если функция выполнена успешно и 0, если животное не существует.
*/
stock SetAnimalRespawnTime(animalid, respawn_time)
{
    if(!IsValidAnimal(animalid))
	    return 0;

	so_inc@animal_respawn_time[animalid] = respawn_time;

	return 1;
}
/*
	Функция GetAnimalRespawnTime: Узнает время респавна животного.

	Параметры:
	animalid - ID животного.

	Возвращает: Время респавна животного и 0, если животное не существует.
*/
stock GetAnimalRespawnTime(animalid)
{
    if(!IsValidAnimal(animalid))
	    return 0;

	return so_inc@animal_respawn_time[animalid];
}
/*
	Функция StopAnimal: Останавливает животное.

	Параметры:
	animalid - ID животного.

	Возвращает: 1 если функция выполнена успешно и 0, если животное не существует.
*/
stock StopAnimal(animalid)
{
    if(!IsValidAnimal(animalid))
	    return 0;
    #if !defined Streamer_IncludeFileVersion
    StopObject(so_inc@animals[animalid]);
    #else
    StopDynamicObject(so_inc@animals[animalid]);
    #endif

	return 1;
}
/*
	Функция IsValidAnimal: Узнает, существует ли животное.

	Параметры:
	animalid - ID животного.

	Возвращает: 1 если животное существует и 0, если животное не существует.
*/
stock IsValidAnimal(animalid)
{
	if(so_inc@animals[animalid] == INVALID_ANIMAL_ID)
	    return 0;
	return 1;
}
/*
	Функция GetCreateAnimals: Узнает кол-во созданных животных.

	Параметры: -

	Возвращает: Кол-во созданных животных.
*/
stock GetCreateAnimals()
	return so_inc@animal_count;
/*
	Функция GetAnimalType: Узнает тип животного.

	Параметры: animalid - ID животного.

	Возвращает: Тип животного и 0, если животное не существует.
*/
stock GetAnimalType(animalid)
{
    if(!IsValidAnimal(animalid))
	    return -1;

	return so_inc@animal_type{animalid};
}
/*
	Функция IsAnimalLife: Узнает, живое ли животное.

	Параметры: animalid - ID животного.

	Возвращает: 1 если животное живое и 0, если животное мертво или не существует.
*/
stock IsAnimalLife(animalid)
{
	if(!IsValidAnimal(animalid))
	    return 0;
	if(!so_inc@animal_life{animalid})
		return 0;
	return 1;
}
/*
	Функция SetAnimalBlood: Устанавливает кровь животному.

	Параметры:
	animalid - ID животного.
	bool:blood - Включить/выключить кровь

	Возвращает: 1 если функция выполнена успешно и 0, если животное не существует.
*/
stock SetAnimalBlood(animalid, bool:blood)
{
    if(!IsValidAnimal(animalid))
	    return 0;

	so_inc@animal_blood{animalid} = blood;

	return 1;
}
/*
	Функция IsAnimalBlood: Узнает, установлена ли кровь животному.

	Параметры: animalid - ID животного.

	Возвращает: 1 если кровь установлена и 0, если нет или животное не существует.
*/
stock IsAnimalBlood(animalid)
{
    if(!IsValidAnimal(animalid))
	    return 0;

	return so_inc@animal_blood{animalid};
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
	            if(IsAnimalBlood(animalid))
				{
			    	new Float:X, Float:Y, Float:Z;
			    	GetObjectPos(so_inc@animals[animalid], X, Y, Z);
			    	if(so_inc@animal_blood_obj[animalid] != 0)
			        DestroyObject(so_inc@animal_blood_obj[animalid]), so_inc@animal_blood_obj[animalid] = 0;

                	so_inc@animal_blood_obj[animalid] = CreateObject(18668, X, Y,
					(GetAnimalType(animalid) == ANIMAL_TYPE_COW) ? (Z - 1.0) : (Z - 1.4),
					0.0, 0.0, 0.0);
				}
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
        if(IsAnimalBlood(animalid))
		{
 			new Float:X, Float:Y, Float:Z;
 			GetDynamicObjectPos(so_inc@animals[animalid], X, Y, Z);
 			if(so_inc@animal_blood_obj[animalid] != 0)
  				DestroyDynamicObject(so_inc@animal_blood_obj[animalid]), so_inc@animal_blood_obj[animalid] = 0;

			so_inc@animal_blood_obj[animalid] = CreateDynamicObject(18668, X, Y,
			(GetAnimalType(animalid) == ANIMAL_TYPE_COW) ? (Z - 1.0) : (Z - 1.4),
			0.0, 0.0, 0.0);
		}
		
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
/*
	Паблик OnPlayerGiveDamageAnimal: Получает информацию о нанесеном уроне для животного от игрока.

	Параметры:
	playerid - ID игрока, который нанес урон.
 	animalid - ID животного, которое получило урон.
 	weaponid - ID оружия.
 	Float:damage - Кол-во урона.

 	Возвращает: -
*/
public OnPlayerGiveDamageAnimal(playerid, animalid, weaponid, Float:damage)
{
    #if defined so_pub_OnPlayerGiveDamageAnimal
   		so_pub_OnPlayerGiveDamageAnimal(playerid, animalid, weaponid, damage);
  	#endif
	return 1;
}
/*
	Паблик OnAnimalDeath: Получает информацио о смерти животного.

	Параметры:
 	animalid - ID животного, которое убили.
 	killerid - ID убийцы.

 	Возвращает: -
*/
public OnAnimalDeath(animalid, killerid)
{
	StopAnimal(animalid);
	if(GetAnimalRespawnTime(animalid))
		SetTimerEx("OnAnimalSpawn", GetAnimalRespawnTime(animalid), false, "i", animalid);

  	#if defined so_pub_OnAnimalDeath
   		so_pub_OnAnimalDeath(animalid, killerid);
  	#endif

	return 1;
}
/*
	Паблик OnAnimalSpawn: Вызывается, когда животное респавнится.

	Параметры:
 	animalid - ID животного.

 	Возвращает: -
*/
public OnAnimalSpawn(animalid)
{
	StopAnimal(animalid);
	SetAnimalPos(animalid, so_inc@animal_pos_X[animalid], so_inc@animal_pos_Y[animalid], so_inc@animal_pos_Z[animalid]);
	SetAnimalAngle(animalid, so_inc@animal_angle[animalid]);

	so_inc@animal_life{animalid} = true;
	so_inc@animal_heal_status[animalid] = so_inc@animal_health[animalid];

	#if defined so_pub_OnAnimalSpawn
   		so_pub_OnAnimalSpawn(animalid);
  	#endif

	return 1;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
#if defined _ALS_OnPlayerGiveDamageAnimal
	#undef	OnPlayerGiveDamageAnimal
#else
	#define	_ALS_OnPlayerGiveDamageAnimal
#endif
#if	defined	so_pub_OnPlayerGiveDamageAnimal
	forward so_pub_OnPlayerGiveDamageAnimal(playerid, animalid, weaponid, Float:damage);
#endif
#define	OnPlayerGiveDamageAnimal so_pub_OnPlayerGiveDamageAnimal
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
#if defined _ALS_OnAnimalDeath
	#undef	OnAnimalDeath
#else
	#define	_ALS_OnAnimalDeath
#endif
#if	defined	so_pub_OnAnimalDeath
	forward so_pub_OnAnimalDeath(animalid, killerid);
#endif
#define	OnAnimalDeath so_pub_OnAnimalDeath
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
#if defined _ALS_OnAnimalSpawn
	#undef	OnAnimalSpawn
#else
	#define	_ALS_OnAnimalSpawn
#endif
#if	defined	so_pub_OnAnimalSpawn
	forward so_pub_OnAnimalSpawn(animalid);
#endif
#define	OnAnimalSpawn so_pub_OnAnimalSpawn
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */


















new cow, deer, turtle, shark, dolphin;
main()
{
	cow = CreateAnimal(ANIMAL_TYPE_COW, 40.3943,11.9059,2.9406,115.0753, 5000); // Создаем корову, которая будет респавнится после смерти через 5 секунд
	deer = CreateAnimal(ANIMAL_TYPE_DEER, 29.3959,17.9892,3.1172,162.5980); // Создаем оленя
	turtle = CreateAnimal(ANIMAL_TYPE_TURTLE, 42.9049,8.3838,2.6855,106.0180); // Создаем черепаху
	shark = CreateAnimal(ANIMAL_TYPE_SHARK, 38.4636,16.2182,3.1172,106.0180); // Создаем акулу
	dolphin = CreateAnimal(ANIMAL_TYPE_DOLPHIN, 36.4468,21.6427,3.1172,106.0180); // Создаем дельфина
	
	SetAnimalBlood(cow, true);
	SetAnimalBlood(deer, true);
	
	printf("%i", GetCreateAnimals()); // выводим в консоль максимальное кол-во созданных животных
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	if(!strcmp(cmdtext, "/moveme", true, 7))
	{
		/*
			По команде /move заставляем животное идти на место, где стоит игрок.
		*/
		new Float:X, Float:Y, Float:Z;
		GetPlayerPos(playerid, X, Y, Z);
		
		if(strlen(cmdtext) > 8)
		{
			if(!strcmp(cmdtext[8], "cow", true))
				MoveAnimal(cow, X, Y, Z, 1.0), SendClientMessage(playerid,-1, "Корова движется!");
	        if(!strcmp(cmdtext[8], "deer", true))
				MoveAnimal(deer, X, Y, Z, 1.0), SendClientMessage(playerid,-1, "Олень движется!");
			if(!strcmp(cmdtext[8], "turtle", true))
				MoveAnimal(turtle, X, Y, Z, 1.0), SendClientMessage(playerid,-1, "Черепаха движется!");
	        if(!strcmp(cmdtext[8], "shark", true))
				MoveAnimal(shark, X, Y, Z, 1.0), SendClientMessage(playerid,-1, "Акула движется!");
			if(!strcmp(cmdtext[8], "dolphin", true))
				MoveAnimal(dolphin, X, Y, Z, 1.0), SendClientMessage(playerid,-1, "Дельфин движется!");
		}
			
	    return 1;
	}
	if(!strcmp(cmdtext, "/inv", true, 4))
	{
	    /*
			По команде /inv делаем животное уязвимой.
		*/
		if(!strcmp(cmdtext[5], "cow", true))
			return SetAnimalInvulnerable(cow, false), SendClientMessage(playerid,-1, "Корова уязвима!");
        if(!strcmp(cmdtext[5], "deer", true))
			return SetAnimalInvulnerable(deer, false), SendClientMessage(playerid,-1,"Олень уязвим!");
        if(!strcmp(cmdtext[5], "turtle", true))
			return SetAnimalInvulnerable(turtle, false), SendClientMessage(playerid,-1,"Черепаха уязвима!");
    	if(!strcmp(cmdtext[5], "shark", true))
			return SetAnimalInvulnerable(shark, false), SendClientMessage(playerid,-1,"Окула уязвима!");
		if(!strcmp(cmdtext[5], "dolphin", true))
			return SetAnimalInvulnerable(dolphin, false), SendClientMessage(playerid,-1,"Дельфин уязвим!");
	    return 1;
	}
	if(!strcmp(cmdtext, "/angle", true, 6))
	{
	    /*
			По команде /angle поворачиваем животное в ту сторону, куда смотрит игрок.
		*/
		new Float:angle;
		GetPlayerFacingAngle(playerid, angle);
		if(!strcmp(cmdtext[7], "cow", true))
			SetAnimalAngle(cow, angle), SendClientMessage(playerid,-1, "Корова повернулась!");
        if(!strcmp(cmdtext[7], "deer", true))
			SetAnimalAngle(deer, angle), SendClientMessage(playerid,-1,"Олень повернулся!");
        if(!strcmp(cmdtext[7], "turtle", true))
			SetAnimalAngle(turtle, angle), SendClientMessage(playerid,-1,"Черепаха повернулась!");
    	if(!strcmp(cmdtext[7], "shark", true))
			SetAnimalAngle(shark, angle), SendClientMessage(playerid,-1,"Окула повернулась!");
		if(!strcmp(cmdtext[7], "dolphin", true))
			SetAnimalAngle(dolphin, angle), SendClientMessage(playerid,-1,"Дельфин повернулся!");
	    return 1;
	}
	
	if(!strcmp(cmdtext, "/health", true, 7))
	{
	    /*
			По команде /health установим животному 500 хп.
		*/
		if(!strcmp(cmdtext[8], "cow", true))
			SetAnimalHealth(cow, 500.0), SendClientMessage(playerid,-1, "Корове установленно 500 хп!");
        if(!strcmp(cmdtext[8], "deer", true))
			SetAnimalHealth(deer, 500.0), SendClientMessage(playerid,-1,"Оленю установленно 500 хп!");
        if(!strcmp(cmdtext[8], "turtle", true))
			SetAnimalHealth(turtle, 500.0), SendClientMessage(playerid,-1,"Черепахе установленно 500 хп!");
    	if(!strcmp(cmdtext[8], "shark", true))
			SetAnimalHealth(shark, 500.0), SendClientMessage(playerid,-1,"Окуле установленно 500 хп!");
		if(!strcmp(cmdtext[8], "dolphin", true))
			SetAnimalHealth(dolphin, 500.0), SendClientMessage(playerid,-1,"Дельфину установленнго 500 хп!");
	    return 1;
	}
	
	if(!strcmp(cmdtext, "/getheal", true, 8))
	{
	    /*
			По команде /getheal узнаем кол-во хп у животного.
		*/
		new Float:health, string[144];
		if(!strcmp(cmdtext[9], "cow", true))
		{
		    GetAnimalHealth(cow, health);
		    format(string, sizeof(string), "У коровы: %0.2f здоровья!", health);
		    SendClientMessage(playerid, -1, string);
			return 1;
		}
        if(!strcmp(cmdtext[9], "deer", true))
			{
		    GetAnimalHealth(deer, health);
		    format(string, sizeof(string), "У оленя: %0.2f здоровья!", health);
		    SendClientMessage(playerid, -1, string);
			return 1;
		}
        if(!strcmp(cmdtext[9], "turtle", true))
			{
		    GetAnimalHealth(turtle, health);
		    format(string, sizeof(string), "У черепахи: %0.2f здоровья!", health);
		    SendClientMessage(playerid, -1, string);
			return 1;
		}
    	if(!strcmp(cmdtext[9], "shark", true))
		{
		    GetAnimalHealth(shark, health);
		    format(string, sizeof(string), "У акулы: %0.2f здоровья!", health);
		    SendClientMessage(playerid, -1, string);
			return 1;
		}
		if(!strcmp(cmdtext[9], "dolphin", true))
		{
		    GetAnimalHealth(dolphin, health);
		    format(string, sizeof(string), "У дельфина: %0.2f здоровья!", health);
		    SendClientMessage(playerid, -1, string);
			return 1;
		}
	    return 1;
	}
	
	if(!strcmp(cmdtext, "/setpos", true, 7))
	{
	    /*
			По команде /setpos телепортируем животное на координаты игрока.
		*/
        new Float:X, Float:Y, Float:Z;
		GetPlayerPos(playerid, X, Y, Z);
		if(!strcmp(cmdtext[8], "cow", true))
		{
		    SetAnimalPos(cow, X, Y, Z);
			return 1;
		}
        if(!strcmp(cmdtext[8], "deer", true))
		{
		    SetAnimalPos(deer, X, Y, Z);
			return 1;
		}
        if(!strcmp(cmdtext[8], "turtle", true))
		{
		    SetAnimalPos(turtle, X, Y, Z);
			return 1;
		}
    	if(!strcmp(cmdtext[8], "shark", true))
		{
		    SetAnimalPos(shark, X, Y, Z);
			return 1;
		}
		if(!strcmp(cmdtext[8], "dolphin", true))
		{
		    SetAnimalPos(dolphin, X, Y, Z);
			return 1;
		}
	    return 1;
	}
	
	if(!strcmp(cmdtext, "/del", true, 4))
	{
	    /*
			По команде /del удалим животное.
		*/
        new Float:X, Float:Y, Float:Z;
		GetPlayerPos(playerid, X, Y, Z);
		if(!strcmp(cmdtext[5], "cow", true))
		{
		    DestroyAnimal(cow);
			return 1;
		}
        if(!strcmp(cmdtext[5], "deer", true))
		{
		    DestroyAnimal(deer);
			return 1;
		}
        if(!strcmp(cmdtext[5], "turtle", true))
		{
		    DestroyAnimal(turtle);
			return 1;
		}
    	if(!strcmp(cmdtext[5], "shark", true))
		{
		    DestroyAnimal(shark);
			return 1;
		}
		if(!strcmp(cmdtext[5], "dolphin", true))
		{
		    DestroyAnimal(dolphin);
			return 1;
		}
	    return 1;
	}
	
	if(!strcmp(cmdtext, "/kill", true, 5))
	{
	    /*
			По команде /kill убьем животное.
		*/
        new Float:X, Float:Y, Float:Z;
		GetPlayerPos(playerid, X, Y, Z);
		if(!strcmp(cmdtext[6], "cow", true))
		{
		    KillAnimal(cow);
			return 1;
		}
        if(!strcmp(cmdtext[6], "deer", true))
		{
		    KillAnimal(deer);
			return 1;
		}
        if(!strcmp(cmdtext[6], "turtle", true))
		{
		    KillAnimal(turtle);
			return 1;
		}
    	if(!strcmp(cmdtext[6], "shark", true))
		{
		    KillAnimal(shark);
			return 1;
		}
		if(!strcmp(cmdtext[6], "dolphin", true))
		{
		    KillAnimal(dolphin);
			return 1;
		}
	    return 1;
	}
	
	if(!strcmp(cmdtext, "/spawn", true, 6))
	{
	    /*
			По команде /kill убьем животное.
		*/
        new Float:X, Float:Y, Float:Z;
		GetPlayerPos(playerid, X, Y, Z);
		if(!strcmp(cmdtext[7], "cow", true))
		{
		    SpawnAnimal(cow);
			return 1;
		}
        if(!strcmp(cmdtext[7], "deer", true))
		{
		    SpawnAnimal(deer);
			return 1;
		}
        if(!strcmp(cmdtext[7], "turtle", true))
		{
		    SpawnAnimal(turtle);
			return 1;
		}
    	if(!strcmp(cmdtext[7], "shark", true))
		{
		    SpawnAnimal(shark);
			return 1;
		}
		if(!strcmp(cmdtext[7], "dolphin", true))
		{
		    SpawnAnimal(dolphin);
			return 1;
		}
	    return 1;
	}
	
	//вспомогательные команды
	if(!strfind(cmdtext, "/gun"))
	{
	    GivePlayerWeapon(playerid, strval(cmdtext[4]), cellmax);
	    return 1;
	}
	return 1;
}

public OnPlayerSpawn(playerid)
{
	SetPlayerPos(playerid, 0.0, 0.0 + 3, 0.0 + 3.1);
	return 1;
}


























