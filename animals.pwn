#include <a_samp>
#include <streamer>
#include <animals>
new cow, deer, turtle, shark, dolphin;
main()
{
	cow = CreateAnimal(ANIMAL_TYPE_COW, 40.3943,11.9059,2.9406,115.0753, 5000); // Создаем корову, которая будет респавнится после смерти через 5 секунд
	deer = CreateAnimal(ANIMAL_TYPE_DEER, 29.3959,17.9892,3.1172,162.5980); // Создаем оленя
	turtle = CreateAnimal(ANIMAL_TYPE_TURTLE, 42.9049,8.3838,2.6855,106.0180); // Создаем черепаху
	shark = CreateAnimal(ANIMAL_TYPE_SHARK, 38.4636,16.2182,3.1172,106.0180); // Создаем акулу
	dolphin = CreateAnimal(ANIMAL_TYPE_DOLPHIN, 36.4468,21.6427,3.1172,106.0180); // Создаем дельфина
	
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
