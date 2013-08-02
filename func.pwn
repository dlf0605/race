stock ResetPlayerVariables(playerid)
{
  pSpec		[playerid] = -1;
    pClass		[playerid] = false;
    pSkipClass  [playerid] = true;
	pLoggedIn	[playerid] = false;
	pAdmin		[playerid] = 0;
    pSkin       [playerid] = 0;
	pWin		[playerid] = 0;
	pLoss		[playerid] = 0;
	pBan        [playerid] = false;
	pReason     [playerid] = "";

	ResetPlayerRaceVariables(playerid);
	ResetPlayerEditVariables(playerid);
	return 1;
}

stock ResetPlayerEditVariables(playerid)
{
	pEditName		[playerid] = "";
	pEdit			[playerid] = false;
	pEditCircuit	[playerid] = false;
	pEditVehicle	[playerid] = 0;
	pEditAir       	[playerid] = false;
	pEditTick		[playerid] = 0;
	pEditCurrent  	[playerid] = 0;
	for(new cp = 0; cp < MAX_CHECKPOINTS; cp++)
	{
		pEditCp		[playerid][cp][0] = 0.0;
		pEditCp		[playerid][cp][1] = 0.0;
		pEditCp		[playerid][cp][2] = 0.0;
	}
	pEditLR			[playerid] = 0;
	pEditUD			[playerid] = 0;
	pEditMode		[playerid] = 0;
	pEditLastMove	[playerid] = 0;
	pEditSpeed		[playerid] = 0.0;

	if(pEditObj[playerid] != -1)
		DestroyPlayerObject(playerid, pEditObj[playerid]);
	pEditObj		[playerid] = -1;
	return 1;
}

stock ResetPlayerRaceVariables(playerid)
{
	pJoined				[playerid] = false;
	pLap				[playerid] = 0;
	pTime				[playerid] = 0;
	pCp					[playerid] = 0;
    pSlot               [playerid] = -1;
	if(pVeh[playerid] != -1)
		DestroyVehicle(pVeh[playerid]);
	pVeh[playerid] = -1;
	return 1;
}

stock PlayerJoinRace(playerid)
{
	if(pJoined[playerid] == true) return 0;

	pJoined[playerid] = true;
	OnPlayerEnterRaceCheckpoint(playerid);
	pTime[playerid] = GetTickCount();
	TogglePlayerControllable(playerid, true);

	PlayerTextDrawShow(playerid, td_back[playerid]);
	PlayerTextDrawShow(playerid, td_time[playerid][0]);
	PlayerTextDrawShow(playerid, td_time[playerid][1]);
	PlayerTextDrawShow(playerid, td_pos[playerid][0]);
	PlayerTextDrawShow(playerid, td_pos[playerid][1]);
	PlayerTextDrawShow(playerid, td_pos[playerid][2]);
	PlayerTextDrawShow(playerid, td_pos[playerid][3]);
	PlayerTextDrawShow(playerid, td_pos[playerid][4]);
	PlayerTextDrawShow(playerid, td_speed[playerid][0]);
	PlayerTextDrawShow(playerid, td_speed[playerid][1]);
	PlayerTextDrawShow(playerid, td_speed[playerid][2]);
	PlayerTextDrawShow(playerid, td_progress[playerid][0]);
	PlayerTextDrawShow(playerid, td_progress[playerid][1]);
	PlayerTextDrawShow(playerid, td_progress[playerid][2]);
	return 1;
}

stock PlayerLeaveRace(playerid, bool:disqualify)
{
	if(pJoined[playerid] == false) return 0;
	if(disqualify == false)
	{
		new string[128], time;
		time = GetTickCount() - pTime[playerid];

		new name[MAX_PLAYER_NAME+1];
		GetPlayerName(playerid, name, sizeof(name));
		format(string, sizeof(string), "~w~%s finished the Race %i%s~n~~r~%s", name, rPos, GetNumberSuffix(rPos), MsToStr(time));
		GameTextForAll(string, 5000, 3);

		if(rPos == 1)
		{
			pWin[playerid] ++;
			if(rCountdown > 30) rCountdown = 30;
		}
		else pLoss[playerid] ++;
		rPos ++;
	}
	DisablePlayerRaceCheckpoint(playerid);

	PlayerTextDrawHide(playerid, td_back[playerid]);
	PlayerTextDrawHide(playerid, td_time[playerid][0]);
	PlayerTextDrawHide(playerid, td_time[playerid][1]);
	PlayerTextDrawHide(playerid, td_pos[playerid][0]);
	PlayerTextDrawHide(playerid, td_pos[playerid][1]);
	PlayerTextDrawHide(playerid, td_pos[playerid][2]);
	PlayerTextDrawHide(playerid, td_pos[playerid][3]);
	PlayerTextDrawHide(playerid, td_pos[playerid][4]);
	PlayerTextDrawHide(playerid, td_speed[playerid][0]);
	PlayerTextDrawHide(playerid, td_speed[playerid][1]);
	PlayerTextDrawHide(playerid, td_speed[playerid][2]);
	PlayerTextDrawHide(playerid, td_progress[playerid][0]);
	PlayerTextDrawHide(playerid, td_progress[playerid][1]);
	PlayerTextDrawHide(playerid, td_progress[playerid][2]);

	ResetPlayerRaceVariables(playerid);
	return 1;
}

stock AttemptRaceRecord(playerid)
{
	new time = GetTickCount() - pTime[playerid];
	if(!IsPlayerConnected(playerid) || rState < STATE_STARTED || (rRecord != 0 && time > rRecord)) return 0;

	new string[128], name[MAX_PLAYER_NAME+1];
	GetPlayerName(playerid, name, sizeof(name));
	if(rRecord > 0)
		format(string, sizeof(string), "%s has beaten the old record by %s (%s +%s)", name, rRecordholder, MsToStr(time), MsToStr(rRecord - time));
	else
		format(string, sizeof(string), "%s has set a new record (%s)", name, MsToStr(time));
	SendClientMessageToAll(COLOR_WHITE, string);

	rRecord = time;
	format(rRecordholder, sizeof(rRecordholder), "%s", name);
	return 1;
}

stock ResetRaceVariables()
{
	KillTimer(rTimer);
	rName = "";
	rCircuit = false;
	rVehicle = 0;
	rAir = false;
	rRecord = 0;
	rRecordholder = "";
	for(new cp = 0; cp < MAX_CHECKPOINTS; cp++)
	{
		rCp[cp][0] = 0.0;
		rCp[cp][1] = 0.0;
		rCp[cp][2] = 0.0;
	}

	rCountdown = 10;
	rLaps = 1;
	rPos = 1;
	return 1;
}

stock Float:GetDistance(Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2)
{
	return floatsqroot( ((x1 - x2) * (x1 - x2)) + ((y1 - y2) * (y1 - y2)) + ((z1 - z2) * (z1 - z2)) );
}

stock Float:GetRaceDistance()
{
	new Float:distance, cps;
	cps = GetRaceCps();
	for(new cp = 0; cp < MAX_CHECKPOINTS; cp++)
	{
		if(cp > cps) break;
		if(cp == cps && rCircuit == true)
		{
			distance += GetDistance(rCp[cp][0], rCp[cp][1], rCp[cp][2], rCp[0][0], rCp[0][1], rCp[0][2]);
		}
		else if(cp < cps) distance += GetDistance(rCp[cp][0], rCp[cp][1], rCp[cp][2], rCp[cp+1][0], rCp[cp+1][1], rCp[cp+1][2]);
	}
	return distance;
}

stock Float:GetPlayerTraveledDistance(playerid)
{
	new Float:distance, cps;
	cps = GetRaceCps();
	if(rCircuit == true && pLap[playerid] > 0)
	{
		distance += (GetRaceDistance() * pLap[playerid]);
	}

	for(new cp = 0; cp < MAX_CHECKPOINTS; cp++)
	{
		if(cp > cps) break;
		if(cp == pCp[playerid])
	    {
			distance -= GetPlayerDistanceFromPoint(playerid, rCp[cp][0], rCp[cp][1], rCp[cp][2]);
			break;
		}

		if(cp == cps && rCircuit == true)
		{
			distance += GetDistance(rCp[cp][0], rCp[cp][1], rCp[cp][2], rCp[0][0], rCp[0][1], rCp[0][2]);
		}
		else if(cp < cps) distance += GetDistance(rCp[cp][0], rCp[cp][1], rCp[cp][2], rCp[cp+1][0], rCp[cp+1][1], rCp[cp+1][2]);
	}
	return distance;
}

forward SetRaceState(stateid);
public SetRaceState(stateid)
{
	switch(stateid)
	{
		case STATE_STARTING:
		{
			rState = STATE_STARTING;
			ResetRaceVariables();

			if(GetValidRaces() == 0) return 1;
			LoadRace(GetRandomRace());
			SetRaceState(STATE_COUNTDOWN);

			for(new playerid = 0; playerid < MAX_PLAYERS; playerid++)
			{
			    if(!IsPlayerConnected(playerid) || !IsPlayerSpawned(playerid)) continue;
				SpawnPlayerFix(playerid);
			}
			return 1;
		}
		case STATE_COUNTDOWN:
		{
			if(rCountdown == 0)
			{
				new distance = floatround(GetRaceDistance());
				if(rCircuit == true)
				{
                    if(distance > 4000) rLaps = 1;
					else if(distance > 2000) rLaps = 2;
					else if(distance > 1000) rLaps = 4;
					else rLaps = 5;

					rCountdown = ((distance / 10) * rLaps);
				}
				else rCountdown = (distance / 10);
				SetRaceState(STATE_STARTED);

				for(new playerid = 0; playerid < MAX_PLAYERS; playerid++)
				{
					if(!IsPlayerConnected(playerid) || !IsPlayerSpawned(playerid)) continue;
					GameTextForPlayer(playerid, "~g~Go!!", 1000, 6);
			    	PlayerPlaySound(playerid, 3200, 0, 0, 0);
					PlayerJoinRace(playerid);
				}
			}
			else
			{
				new string[10];
				format(string, sizeof(string), "~w~%i", rCountdown);
				for(new playerid = 0; playerid < MAX_PLAYERS; playerid++)
				{
					if(!IsPlayerConnected(playerid) || !IsPlayerSpawned(playerid)) continue;
					GameTextForPlayer(playerid, string, 1000, 6);
			        PlayerPlaySound(playerid, 1056, 0, 0, 0);
				}

				rCountdown --;
				rState = STATE_COUNTDOWN;

				KillTimer(rTimer);
				rTimer = SetTimerEx("SetRaceState", 1000, false, "i", STATE_COUNTDOWN);
			}
            return 1;
		}
		case STATE_STARTED:
		{
			if(rCountdown < 100)
			{
				new string[64], second[10];

				if(rCountdown <= 1) second = "second";
				else second = "seconds";
				format(string, sizeof(string), "~w~The race will end in ~r~%i ~w~%s...", rCountdown, second);

				for(new playerid = 0; playerid < MAX_PLAYERS; playerid++)
				{
					if(!IsPlayerConnected(playerid)) continue;
					PlayerTextDrawSetString(playerid, td_timeleft[playerid], string);
					PlayerTextDrawShow(playerid, td_timeleft[playerid]);
				}
			}

			if(rCountdown == 0) SetRaceState(STATE_FINISHED);
			else
			{
				rCountdown--;
				rState = STATE_STARTED;

				KillTimer(rTimer);
				rTimer = SetTimerEx("SetRaceState", 1000, false, "i", STATE_STARTED);
			}
			return 1;
		}
		case STATE_FINISHED:
		{
            KillTimer(rTimer);

			SaveRace(rName);
			for(new playerid = 0; playerid < MAX_PLAYERS; playerid++)
			{
				if(!IsPlayerConnected(playerid)) continue;
				PlayerLeaveRace(playerid, true);
				PlayerTextDrawHide(playerid, td_timeleft[playerid]);
			}
			SetRaceState(STATE_STARTING);
           	return 1;
		}
	}
		
	return 1;
}

forward TimeCycle();
public TimeCycle()
{
	gTime[1] ++;
	if(gTime[1] == 60)
	{
		gTime[0]++; gTime[1] = 0;
		if(gTime[0] == 24) gTime[0] = 0;
		SetWorldTime(gTime[0]);

		if(random(10) == 0)
		{
			switch(random(16))
			{
				case 0: SetWeather(0);
				case 1: SetWeather(1);
				case 2: SetWeather(2);
				case 3: SetWeather(4);
				case 4: SetWeather(3);
				case 5: SetWeather(5);
				case 6: SetWeather(6);
				case 7: SetWeather(7);
				case 8: SetWeather(8);
				case 9: SetWeather(9);
				case 10: SetWeather(10);
				case 11: SetWeather(11);
				case 12: SetWeather(16);
				case 13: SetWeather(17);
				case 14: SetWeather(18);
				case 15: SetWeather(19);
			}
		}
	}

	for(new playerid = 0; playerid < MAX_PLAYERS; playerid++)
	{
		if(!IsPlayerConnected(playerid)) continue;
		SetPlayerTime(playerid, gTime[0], gTime[1]);
	}
	return 1;
}

stock IsPlayerSpawned(playerid)
{
	if(pEdit[playerid] == true) return false;
	switch(GetPlayerState(playerid))
	{
		case 1..6, 8: return true;
		case 7: if(pClass[playerid] == false) return true;
	}
	return false;
}

forward SpawnPlayerFix(playerid);
public SpawnPlayerFix(playerid)
{
	if(IsPlayerInAnyVehicle(playerid))
	{
		new Float:x, Float:y, Float:z;
		GetPlayerPos(playerid, x, y, z);
		SetPlayerPos(playerid, x, y, z);
	}
	SpawnPlayer(playerid);
	return 1;
}

forward PublicKick(playerid);
public PublicKick(playerid)
{
	Kick(playerid);
	return 1;
}

forward PublicBanEx(playerid, const reason[]);
public PublicBanEx(playerid, const reason[])
{
	BanEx(playerid, reason);
	return 1;
}

stock KickEx(playerid, const reason[], bool:ban = false)
{
	new string[128];
	format(pReason[playerid], sizeof(pReason[]), reason);
	pBan[playerid] = ban;

	if(ban == true)
	{
		format(string, sizeof(string), "You got BANNED! Reason: %s.", reason);
		SendClientMessage(playerid, COLOR_RED, string);
		SetTimerEx("PublicBanEx", 100, false, "is", playerid, reason);
	}
	else
	{
		format(string, sizeof(string), "You got KICKED! Reason: %s.", reason);
		SendClientMessage(playerid, COLOR_RED, string);
		SetTimerEx("PublicKick", 100, false, "i", playerid);
	}
	return 1;
}

stock GetRacingPlayers()
{
	new players;
	for(new playerid = 0; playerid < MAX_PLAYERS; playerid++)
	{
		if(!IsPlayerConnected(playerid)) continue;
		if(pJoined[playerid] == true) players++;
	}
	return players;
}

stock GetPlayerRacePosition(playerid)
{
	new pos = 1;
	for(new players = 0; players < MAX_PLAYERS; players++)
	{
	    if(!IsPlayerConnected(players) || players == playerid) continue;

		if(pLap[players] > pLap[playerid] && rCircuit == true) pos++;
		else if((rCircuit == true && pLap[players] >= pLap[playerid]) || rCircuit == false)
		{
			if(pCp[players] > pCp[playerid]) pos++;
			else if(pCp[players] == pCp[playerid])
			{
				new Float:x, Float:y, Float:z, Float:distance[2];
				x = rCp[pCp[playerid]][0];
				y = rCp[pCp[playerid]][1];
				z = rCp[pCp[playerid]][2];

				distance[0] = GetPlayerDistanceFromPoint(playerid, x, y, z);
				distance[1] = GetPlayerDistanceFromPoint(players, x, y, z);
				if(distance[0] > distance[1]) pos++;
			}
		}
	}
	return pos;
}

stock GetPlayerSpeed(playerid)
{
    new Float:x, Float:y, Float:z, Float:speed;
    if(IsPlayerInAnyVehicle(playerid))
    {
        new vehicleid = GetPlayerVehicleID(playerid);
		GetVehicleVelocity(vehicleid, x, y, z);
	}
    else GetPlayerVelocity(playerid, x, y, z);

    speed = floatsqroot(floatpower(floatabs(x), 2.0) + floatpower(floatabs(y), 2.0) + floatpower(floatabs(z), 2.0)) * 160.0;
    return floatround(speed);
}

stock GetPlayerProgress(playerid)
{
	new Float:totaldistance, Float:playerdistance, Float:progress;

	totaldistance = GetRaceDistance();
	playerdistance = GetPlayerTraveledDistance(playerid);
	if(rCircuit == true) progress = (playerdistance / (totaldistance * rLaps)) * 100;
	else progress = (playerdistance / totaldistance) * 100;

	if(progress < 0.0) progress = 0.0;
	else if(progress > 100.0) progress = 100.0;
	return floatround(progress);
}

stock GetGridPosition(slotid, Float:angle, &Float:x, &Float:y)
{
	x = rCp[0][0];
	y = rCp[0][1];

	if(IsNumberEven(slotid)) GetXYInAngleOfPos(x, y, x, y, angle + 90.0, 3.0);// Left
	else GetXYInAngleOfPos(x, y, x, y, angle + 270.0, 3.0);// Right
	if(slotid > 1) GetXYInAngleOfPos(x, y, x, y, angle + 180.0, (slotid / 2) * 10.0);// Backwards
}

stock GetXYInAngleOfPos(Float:xpos, Float:ypos, &Float:x, &Float:y, Float:angle, Float:distance)
{
    x = xpos + (distance * floatsin(-angle, degrees));
    y = ypos + (distance * floatcos(-angle, degrees));
}

stock IsNumberEven(number)
{
	new remainder = number % 2;
	if(remainder > 0) return false;
	else return true;
}

stock IsSlotAvailable(slot)
{
	for(new playerid = 0; playerid < MAX_PLAYERS; playerid++)
	{
		if(!IsPlayerConnected(playerid)) continue;
		if(pSlot[playerid] == slot) return 0;
	}
	return 1;
}

stock SetPlayerLowestSlot(playerid)
{
	for(new slot = 0; slot < MAX_PLAYERS; slot++)
	{
		if(IsSlotAvailable(slot))
		{
			pSlot[playerid] = slot;
			return 1;
		}
	}
	return 0;
}

stock GetRaceCps(playerid = -1)
{
	new cps, Float:x, Float:y, Float:z;
	if(playerid == -1) for(new cp = 0; cp < MAX_CHECKPOINTS; cp++)
	{
		x = rCp[cp][0];
		y = rCp[cp][1];
		z = rCp[cp][2];

		if(x == 0.0 && y == 0.0 && z == 0.0) continue;
		cps++;
	}
	else for(new cp = 0; cp < MAX_CHECKPOINTS; cp++)
	{
		x = pEditCp[playerid][cp][0];
		y = pEditCp[playerid][cp][1];
		z = pEditCp[playerid][cp][2];

		if(x == 0.0 && y == 0.0 && z == 0.0) continue;
		cps++;
	}
	return cps - 1;
}

stock GetNumberSuffix(number)
{
	new value[20], string[3], length;
	format(value, sizeof(value), "%i", number);
	length = strlen(value);

	if(value[length-1] == '1' && (length == 1 || (length > 1 && value[length-2] != '1'))) string = "st";
	else if(value[length-1] == '2' && (length == 1 || (length > 1 && value[length-2] != '1'))) string = "nd";
	else if(value[length-1] == '3' && (length == 1 || (length > 1 && value[length-2] != '1'))) string = "rd";
	else string = "th";
	return string;
}

stock MsToStr(ms)
{
    new str[20];
	new h = (ms /  (1000 * 60 * 60)),
        m = (ms %  (1000 * 60 * 60)) / (1000 * 60),
        s = ((ms % (1000 * 60 * 60)) % (1000 * 60)) / 1000;

    ms = ms - (h * 60 * 60 * 1000) - (m * 60 * 1000) - (s * 1000);

	if(h > 0) format(str, 20, "%02d:%02d:%02d:%03d", h, m, s, ms);
	else if(m > 0) format(str, 20, "%02d:%02d:%03d", m, s, ms);
	else format(str, 20, "%02d:%03d", s, ms);
    return str;
}

stock SecToStr(sec)
{
	new tStr[6];
	if(sec < 60) format(tStr, sizeof(tStr), "%02d", sec);
	else format(tStr, sizeof(tStr), "%02d:%02d", sec / 60, sec % 60);
	return tStr;
}

stock StripNL(str[])
{
	new i = strlen(str);
	while (i-- && str[i] <= ' ') str[i] = '\0';
}

stock GetLevelName(level)
{
	new name[20];
	switch(level)
	{
		case LEVEL_PLAYER: name = "Player";
		case LEVEL_MOD: name = "Moderator";
		case LEVEL_ADMIN: name = "Admin";
		default: name = "Unknown";
	}
	return name;
}

stock GetMoveDirectionFromKeys(ud, lr)
{
	new direction = 0;

    if(lr < 0)
	{
		if(ud < 0) 		direction = MOVE_FORWARD_LEFT;
		else if(ud > 0) direction = MOVE_BACK_LEFT;
		else            direction = MOVE_LEFT;
	}
	else if(lr > 0)
	{
		if(ud < 0)      direction = MOVE_FORWARD_RIGHT;
		else if(ud > 0) direction = MOVE_BACK_RIGHT;
		else			direction = MOVE_RIGHT;
	}
	else if(ud < 0) 	direction = MOVE_FORWARD;
	else if(ud > 0) 	direction = MOVE_BACK;

	return direction;
}

stock MoveCamera(playerid)
{
	new Float:vector[3], Float:pos[3];
	GetPlayerCameraPos(playerid, pos[0], pos[1], pos[2]);
    GetPlayerCameraFrontVector(playerid, vector[0], vector[1], vector[2]);

	if(pEditSpeed[playerid] <= 1) pEditSpeed[playerid] += 0.03;

	new Float:speed = 100.0 * pEditSpeed[playerid];

	new Float:x, Float:y, Float:z;
	GetNextCameraPosition(pEditMode[playerid], pos, vector, x, y, z);
	MovePlayerObject(playerid, pEditObj[playerid], x, y, z, speed);

	pEditLastMove[playerid] = GetTickCount();
	return 1;
}

stock GetNextCameraPosition(move_mode, Float:pos[3], Float:vector[3], &Float:X, &Float:Y, &Float:Z)
{
    #define OFFSET_X (vector[0]*6000.0)
	#define OFFSET_Y (vector[1]*6000.0)
	#define OFFSET_Z (vector[2]*6000.0)
	switch(move_mode)
	{
		case MOVE_FORWARD:
		{
			X = pos[0]+OFFSET_X;
			Y = pos[1]+OFFSET_Y;
			Z = pos[2]+OFFSET_Z;
		}
		case MOVE_BACK:
		{
			X = pos[0]-OFFSET_X;
			Y = pos[1]-OFFSET_Y;
			Z = pos[2]-OFFSET_Z;
		}
		case MOVE_LEFT:
		{
			X = pos[0]-OFFSET_Y;
			Y = pos[1]+OFFSET_X;
			Z = pos[2];
		}
		case MOVE_RIGHT:
		{
			X = pos[0]+OFFSET_Y;
			Y = pos[1]-OFFSET_X;
			Z = pos[2];
		}
		case MOVE_BACK_LEFT:
		{
			X = pos[0]+(-OFFSET_X - OFFSET_Y);
 			Y = pos[1]+(-OFFSET_Y + OFFSET_X);
		 	Z = pos[2]-OFFSET_Z;
		}
		case MOVE_BACK_RIGHT:
		{
			X = pos[0]+(-OFFSET_X + OFFSET_Y);
 			Y = pos[1]+(-OFFSET_Y - OFFSET_X);
		 	Z = pos[2]-OFFSET_Z;
		}
		case MOVE_FORWARD_LEFT:
		{
			X = pos[0]+(OFFSET_X  - OFFSET_Y);
			Y = pos[1]+(OFFSET_Y  + OFFSET_X);
			Z = pos[2]+OFFSET_Z;
		}
		case MOVE_FORWARD_RIGHT:
		{
			X = pos[0]+(OFFSET_X  + OFFSET_Y);
			Y = pos[1]+(OFFSET_Y  - OFFSET_X);
			Z = pos[2]+OFFSET_Z;
		}
	}
}

forward UpdateCommandInfo();
public UpdateCommandInfo()
{
	new string[100], rand;
	for(new playerid = 0; playerid < MAX_PLAYERS; playerid++)
	{
	    if(!IsPlayerConnected(playerid)) continue;

		switch(pAdmin[playerid])
		{
		    case 0: rand = 3;
			case 1: rand = 6;
			case 2: rand = 8;
			default: continue;
		}

		switch(random(rand))
		{
			case 0: string = "~r~/Spec~w~ - Spectate.";
			case 1: string = "~r~/Respawn~w~ - Respawn.";
			case 2: string = "~r~/Pm~w~ - Private message.";

			case 3: string = "~r~/List~w~ - List of all the races.";
			case 4: string = "~r~/Edit~w~ - Create / Edit your own race.";
			case 5: string = "~r~/Kick~w~ - Remove a player temporary.";

			case 6: string = "~r~/Ban~w~ - Remove a player.";
			case 7: string = "~r~/Setlevel~w~ - Promote / Demote a player.";
		}
		PlayerTextDrawSetString(playerid, td_cmds[playerid], string);
	}
	return 1;
}

forward UpdateRaceHUD();
public UpdateRaceHUD()
{
	if(rState != STATE_STARTED) return 1;
	new string[20], var;

	for(new playerid = 0; playerid < MAX_PLAYERS; playerid++)
	{
		if(!IsPlayerConnected(playerid)) continue;

		if(pJoined[playerid] == true)
		{
			var = GetTickCount() - pTime[playerid];
			if(rRecord == 0 || (rRecord > 0 && var < rRecord)) format(string, sizeof(string), "%s", MsToStr(var));
			else format(string, sizeof(string), "~r~%s", MsToStr(var));
			PlayerTextDrawSetString(playerid, td_time[playerid][0], string);

			var = GetPlayerRacePosition(playerid);
			format(string, sizeof(string), "%i", var);
			PlayerTextDrawSetString(playerid, td_pos[playerid][0], string);

			format(string, sizeof(string), "%s", GetNumberSuffix(var));
			PlayerTextDrawSetString(playerid, td_pos[playerid][1], string);

			format(string, sizeof(string), "%i", GetRacingPlayers());
			PlayerTextDrawSetString(playerid, td_pos[playerid][2], string);

			format(string, sizeof(string), "%i", GetPlayerSpeed(playerid));
			PlayerTextDrawSetString(playerid, td_speed[playerid][0], string);

			format(string, sizeof(string), "%i", GetPlayerProgress(playerid));
			PlayerTextDrawSetString(playerid, td_progress[playerid][0], string);
		}
	}
	return 1;
}

stock ShowPlayerRaceEditDialog(playerid, dialogid)
{
	if(pEdit[playerid] == false) return 0;

	switch(dialogid)
	{
		case 0:// Main Menu
		{
			new string[500], line[50];
			if(pEditCircuit[playerid] == true) strcat(string, "Circuit: Yes\n");
			else strcat(string, "Circuit: No\n");

			if(pEditAir[playerid] == true) strcat(string, "Air: Yes\n");
			else strcat(string, "Air: No\n");
			
			format(line, sizeof(line), "Vehicle: %s\n", VehicleNames[pEditVehicle[playerid]]);
			strcat(string, line);

			format(line, sizeof(line), "Current Checkpoint: %i\n", pEditCurrent[playerid]);
			strcat(string, line);

			strcat(string, "Stop Editing");

			ShowPlayerDialog(playerid, DIALOG_MAIN, DIALOG_STYLE_LIST, ""C_WHITE"Race Edit - Main Menu", string, "Ok", "Close");
			return 1;
		}
		case 1:// Vehicle List
		{
			new string[2000], line[50];
			for(new model = 0; model < sizeof(RaceVehicles); model++)
			{
				format(line, sizeof(line), "%s\n", VehicleNames[ RaceVehicles[model]-400 ]);
				strcat(string, line);
			}
			ShowPlayerDialog(playerid, DIALOG_VEHICLE, DIALOG_STYLE_LIST, "Race Edit - Choose Vehicle", string, "Ok", "Back");
			return 1;
		}
		case 2:// CP List
		{
			new string[1000], line[50];
			for(new cp = 0; cp < MAX_CHECKPOINTS; cp++)
			{
				new Float:x, Float:y, Float:z;
				x = pEditCp[playerid][cp][0];
				y = pEditCp[playerid][cp][1];
				z = pEditCp[playerid][cp][2];

				if(x == 0.0 && y == 0.0 && z == 0.0)
				{
					if(cp == pEditCurrent[playerid]) line = ">> <empty>\n";
					else line = "<empty>\n";
				}
				else
				{
					if(cp == pEditCurrent[playerid]) line = ">> SAVED\n";
					else line = "SAVED\n";
				}
				strcat(string, line);
			}
			ShowPlayerDialog(playerid, DIALOG_CPLIST, DIALOG_STYLE_LIST, "Race Edit - Choose Checkpoint", string, "Ok", "Back");
			return 1;
		}
		case 3:// CP Config
		{
			new string[100];
			string = "Do you want to remove this checkpoint?";
			ShowPlayerDialog(playerid, DIALOG_CP, DIALOG_STYLE_MSGBOX, "Race Edit - Checkpoint", string, "Ok", "Back");
			return 1;
		}
		case 4:// Stop Editing
		{
			new string[100];
			string = "Do you want to save the changes?";
			ShowPlayerDialog(playerid, DIALOG_CLOSE, DIALOG_STYLE_MSGBOX, "Race Edit - Stop Editing", string, "Yes", "No");
			return 1;
		}
	}
	return 1;
}

stock LoadRace(const race[], playerid = -1)
{
	if(strlen(race) == 0) return 0;

	new path[32];
	format(path, sizeof(path), "races/%s.txt", race);
	if(!dini_Exists(path)) return 0;

	if(playerid == -1)
	{
		rCircuit = dini_Bool(path, "circuit");
		rVehicle = dini_Int(path, "vehicle");
		rAir = dini_Bool(path, "air");
		rRecord = dini_Int(path, "record");
		format(rRecordholder, sizeof(rRecordholder), dini_Get(path, "recordholder"));
		format(rName, sizeof(rName), "%s", race);

		for(new cp = 0; cp < MAX_CHECKPOINTS; cp++)
		{
			new string[10];
			format(string, sizeof(string), "x%i", cp);
			rCp[cp][0] = dini_Float(path, string);

			format(string, sizeof(string), "y%i", cp);
			rCp[cp][1] = dini_Float(path, string);

			format(string, sizeof(string), "z%i", cp);
			rCp[cp][2] = dini_Float(path, string);
		}
	}
	else
	{
		pEditCircuit[playerid] = dini_Bool(path, "circuit");
		pEditVehicle[playerid] = dini_Int(path, "vehicle");
        pEditAir[playerid] = dini_Bool(path, "air");
		format(pEditName[playerid], sizeof(pEditName[]), "%s", race);

		for(new cp = 0; cp < MAX_CHECKPOINTS; cp++)
		{
			new string[10];
			format(string, sizeof(string), "x%i", cp);
			pEditCp[playerid][cp][0] = dini_Float(path, string);

			format(string, sizeof(string), "y%i", cp);
			pEditCp[playerid][cp][1] = dini_Float(path, string);

			format(string, sizeof(string), "z%i", cp);
			pEditCp[playerid][cp][2] = dini_Float(path, string);
		}
	}
	return 1;
}

stock SaveRace(const race[], playerid = -1)
{
	if(strlen(race) == 0) return 0;

	new path[32];
	format(path, sizeof(path), "races/%s.txt", race);
	if(!dini_Exists(path)) dini_Create(path);

	if(playerid == -1)
	{
		dini_IntSet(path, "record", rRecord);
		dini_Set(path, "recordholder", rRecordholder);
	}
	else
	{
		dini_BoolSet(path, "circuit", pEditCircuit[playerid]);
		dini_IntSet(path, "vehicle", pEditVehicle[playerid]);
		dini_BoolSet(path, "air", pEditAir[playerid]);
		dini_Unset(path, "record");
		dini_Unset(path, "recordholder");

		for(new cp = 0; cp < MAX_CHECKPOINTS; cp++)
		{
			new string[10];
			format(string, sizeof(string), "x%i", cp);
			dini_FloatSet(path, string, pEditCp[playerid][cp][0]);
			
			format(string, sizeof(string), "y%i", cp);
			dini_FloatSet(path, string, pEditCp[playerid][cp][1]);

			format(string, sizeof(string), "z%i", cp);
			dini_FloatSet(path, string, pEditCp[playerid][cp][2]);
		}
	}

	new File:file, string[32];
	path = "racelist.txt";

	if(!fexist(path)) file = fopen(path, io_readwrite);
	else file = fopen(path, io_read);
	if(file)
	{
		while(fread(file, string))
		{
			StripNL(string);
			if(!strcmp(race, string, true) && strlen(race) == strlen(string))
				return fclose(file);
		}
		fclose(file);

		file = fopen(path, io_append);
		if(file)
		{
			fwrite(file, race);
			fwrite(file, "\r\n");
			fclose(file);
		}
	}
	return 1;
}

stock IsValidRace(const race[])
{
	new path[32];
	format(path, sizeof(path), "races/%s.txt", race);
	return dini_Exists(path);
}

stock GetValidRaces()
{
	new File:file, path[32], races;
	path = "racelist.txt";
	if(fexist(path))
	{
		file = fopen(path, io_read);
		if(file)
		{
			new string[32];
			while(fread(file, string)) races++;
			fclose(file);
		}
	}
	return races;
}

stock GetRaceName(race)
{
	new File:file, path[32], string[32];

	path = "racelist.txt";
	if(fexist(path))
	{
		file = fopen(path, io_read);
		if(file)
		{
			new races;
			while(fread(file, string))
			{
				if(races == race)
				{
				    StripNL(string);
					break;
				}
				else string = "";
				races++;
			}
    		fclose(file);
		}
	}
	return string;
}

stock GetRandomRace()
{
	new raceid, races, string[32];
	races = GetValidRaces();
	raceid = random(races);

	format(string, sizeof(string), "%s", GetRaceName(raceid));
	return string;
}

stock InitializeDatabase()
{
	new query[500];
	db = db_open("server.db");

	strcat(query, "CREATE TABLE IF NOT EXISTS `players` ");
	strcat(query, "(`name`, `password`, `ip`, `admin`, `skin`, `win`, `loss`)");
	db_free_result( db_query(db, query) );
	return 1;
}

stock IsPlayerRegistered(playerid)
{
	new query[200], name[MAX_PLAYER_NAME+1], DBResult:result;
	GetPlayerName(playerid, name, sizeof(name));

	format(query, sizeof(query), "SELECT `name` FROM `players` WHERE `name` = '%s'", DBEscape(name));
	result = db_query(db, query);
	if(db_num_rows(result) > 0)
	{
		db_free_result(result);
		return 1;
	}
	db_free_result(result);
	return 0;
}

stock RegisterPlayer(playerid, const password[])
{
	if(IsPlayerRegistered(playerid)) return 0;

	new query[500], hash[129], name[MAX_PLAYER_NAME+1], msg[128];
	GetPlayerName(playerid, name, sizeof(name));
	WP_Hash(hash, sizeof(hash), password);

	format(query, sizeof(query), "INSERT INTO `players` (`name`, `password`, `ip`, `admin`, `skin`, `win`, `loss`) VALUES ('%s', '%s', '0', '0', '0', '0', '0')",
	    DBEscape(name), DBEscape(hash));
	db_free_result( db_query(db, query) );

	format(msg, sizeof(msg), "Account successfully registered! (Account: %s)", name);
	SendClientMessage(playerid, COLOR_WHITE, msg);

	pSkipClass	[playerid] = false;
	LoginPlayer(playerid, true);
	return 1;
}

stock LoginPlayer(playerid, bool:autologin)
{
	if(!IsPlayerRegistered(playerid)) return 0;

	new query[500], DBResult:result, field[20], name[MAX_PLAYER_NAME+1], ip[16], msg[128];
	GetPlayerName(playerid, name, sizeof(name));
	GetPlayerIp(playerid, ip, sizeof(ip));

	format(query, sizeof(query), "UPDATE `players` SET `ip` = '%s' WHERE `name` = '%s'",
		DBEscape(ip), DBEscape(name));
	db_free_result( db_query(db, query) );

	format(query, sizeof(query), "SELECT `admin`, `skin`, `win`, `loss` FROM `players` WHERE `name` = '%s'",
	    DBEscape(name));
	result = db_query(db, query);
	if(db_num_rows(result) > 0)
	{
		db_get_field_assoc(result, "admin", field, sizeof(field)); pAdmin[playerid] = strval(field);
		db_get_field_assoc(result, "skin", field, sizeof(field)); pSkin[playerid] = strval(field);
		db_get_field_assoc(result, "win", field, sizeof(field)); pWin[playerid] = strval(field);
		db_get_field_assoc(result, "loss", field, sizeof(field)); pLoss[playerid] = strval(field);
	}
	db_free_result(result);

	if(autologin == true) format(msg, sizeof(msg), "Account automatically logged in! (%s)", name);
	else format(msg, sizeof(msg), "Account successfully logged in! (%s)", name);
	SendClientMessage(playerid, COLOR_WHITE, msg);
	pLoggedIn	[playerid] = true;

	TogglePlayerSpectating(playerid, false);
	PlayerTextDrawHide(playerid, td_intro[playerid]);
	return 1;
}

stock SavePlayer(playerid)
{
	if(!IsPlayerRegistered(playerid) || pLoggedIn[playerid] == false) return 0;

	new query[500], name[MAX_PLAYER_NAME+1];
	GetPlayerName(playerid, name, sizeof(name));

	format(query, sizeof(query), "UPDATE `players` SET `admin` = '%i', `skin` = '%i', `win` = '%i', `loss` = '%i' WHERE `name` = '%s'",
		pAdmin[playerid], pSkin[playerid], pWin[playerid], pLoss[playerid], DBEscape(name));
	db_free_result( db_query(db, query) );
	return 1;
}

stock DBEscape(text[])
{
    new ret[80* 2], ch, i, j;
    while((ch = text[i++]) && j < sizeof(ret))
    {
        if(ch == '\'')
        {
            if(j < sizeof (ret) - 2)
            {
                ret[j++] = '\'';
                ret[j++] = '\'';
            }
        }
        else if(j < sizeof (ret)) ret[j++] = ch;
        else j++;
    }
    ret[sizeof(ret) - 1] = '\0';
    return ret;
}
