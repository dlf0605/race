CMD:edit(playerid, params[])
{
  if(pEdit[playerid] == false)
	{
		if(pAdmin[playerid] < LEVEL_MOD) return 0;

		new racename[16];
		if(sscanf(params, "s[21]", racename))
		{
		    SendClientMessage(playerid, COLOR_RED, "USAGE: /Edit <race>");
			SendClientMessage(playerid, COLOR_WHITE, "TIP: Use /List to see the current list of races to edit.");
			SendClientMessage(playerid, COLOR_WHITE, "TIP: To create a new race, use a name that cannot be found");
			return 1;
		}
		format(pEditName[playerid], sizeof(pEditName[]), "%s", racename);

		new string[200], action[10], Float:x, Float:y, Float:z;
		if(IsValidRace(racename))
		{
			LoadRace(racename, playerid);
			action = "Editing";
		}
		else action = "Creating";

		format(string, sizeof(string), "~w~You are %s the race ~r~%s~w~. Press ~r~~k~~PED_SPRINT~~w~ to save checkpoints and use ~r~/Edit~w~ to open the menu.", action, racename);
		PlayerTextDrawSetString(playerid, td_info[playerid], string);

		GetPlayerPos(playerid, x, y, z);
		TogglePlayerSpectating(playerid, true);

		if(pEditObj[playerid] == -1)
			pEditObj[playerid] = CreatePlayerObject(playerid, 19300, x, y, z, 0.0, 0.0, 0.0);
		AttachCameraToPlayerObject(playerid, pEditObj[playerid]);

		pEdit[playerid] = true;
		if(rState > STATE_STARTING) PlayerLeaveRace(playerid, true);
	}

	ShowPlayerRaceEditDialog(playerid, 0);
	return 1;
}

CMD:list(playerid, params[])
{
	if(pAdmin[playerid] < LEVEL_MOD) return 0;

	new File:file, path[32];
	path = "racelist.txt";
	if(!fexist(path)) return 1;

	file = fopen(path, io_read);
	if(!file) return 1;

	SendClientMessage(playerid, COLOR_WHITE, " ");
	SendClientMessage(playerid, COLOR_WHITE, "Races:");

	new line[32], string[128];
	while(fread(file, line))
	{
		StripNL(line);
		if(strlen(line) + strlen(string) >= 128)
		{
		    SendClientMessage(playerid, COLOR_WHITE, string);
			string = "";
		}
		strcat(string, line);
		strcat(string, " ");
	}
	if(strlen(string) > 0) SendClientMessage(playerid, COLOR_WHITE, string);
	SendClientMessage(playerid, COLOR_WHITE, " ");
	return 1;
}

CMD:respawn(playerid)
{
	if(!IsPlayerSpawned(playerid))
		return SendClientMessage(playerid, COLOR_RED, "ERROR: You are not spawned!");

	SpawnPlayerFix(playerid);
	return 1;
}

CMD:spec(playerid, params[])
{
	if(!strcmp(params, "off", true) && strlen(params) == strlen("off") && pSpec[playerid] != -1)
	{
		TogglePlayerSpectating(playerid, false);
		pSpec[playerid] = -1;
		PlayerTextDrawSetString(playerid, td_info[playerid], "~~");
		return 1;
	}

	new id;
	if(sscanf(params, "i", id))
		return SendClientMessage(playerid, COLOR_RED, "USAGE: /Spec <playerid>");

	if(pEdit[playerid] == true)
		return SendClientMessage(playerid, COLOR_RED, "ERROR: You are editing a race!");

	if(!IsPlayerConnected(id))
		return SendClientMessage(playerid, COLOR_RED, "ERROR: This player is not connected!");

	if(id == playerid)
		return SendClientMessage(playerid, COLOR_RED, "ERROR: You cannot use this on yourself!");

	if(!IsPlayerSpawned(id))
		return SendClientMessage(playerid, COLOR_RED, "ERROR: This player is not spawned!");

	TogglePlayerSpectating(playerid, true);
	pSpec[playerid] = id;

	new string[128], name[MAX_PLAYER_NAME+1];
	GetPlayerName(id, name, sizeof(name));
	format(string, sizeof(string), "~w~You are spectating ~r~%s~w~. Use ~r~/Spec off~w~ to stop.", name);
	PlayerTextDrawSetString(playerid, td_info[playerid], string);

	if(IsPlayerInAnyVehicle(id))
	{
		new vehicleid = GetPlayerVehicleID(id);
		PlayerSpectateVehicle(playerid, vehicleid);
	}
	else PlayerSpectatePlayer(playerid, id);
	return 1;
}

CMD:kick(playerid, params[])
{
	if(pAdmin[playerid] < LEVEL_MOD) return 0;

	new id, reason[32];
	if(sscanf(params, "is[32]", id, reason))
		return SendClientMessage(playerid, COLOR_RED, "USAGE: /Kick <playerid> <reason>");

	if(!IsPlayerConnected(id))
		return SendClientMessage(playerid, COLOR_RED, "ERROR: This player is not connected!");

	if(id == playerid)
		return SendClientMessage(playerid, COLOR_RED, "ERROR: You cannot use this on yourself!");

	KickEx(id, reason);
	return 1;
}

CMD:ban(playerid, params[])
{
	if(pAdmin[playerid] < LEVEL_ADMIN) return 0;

	new id, reason[32];
	if(sscanf(params, "is[32]", id, reason))
		return SendClientMessage(playerid, COLOR_RED, "USAGE: /Ban <playerid> <reason>");

	if(!IsPlayerConnected(id))
		return SendClientMessage(playerid, COLOR_RED, "ERROR: This player is not connected!");

	if(id == playerid)
		return SendClientMessage(playerid, COLOR_RED, "ERROR: You cannot use this on yourself!");

	KickEx(id, reason, true);
	return 1;
}

CMD:setlevel(playerid, params[])
{
	if(pAdmin[playerid] < LEVEL_ADMIN) return 0;

	new id, level;
	if(sscanf(params, "ii", id, level))
		return SendClientMessage(playerid, COLOR_RED, "USAGE: /Setlevel <playerid> <level>");

	if(!IsPlayerConnected(id))
		return SendClientMessage(playerid, COLOR_RED, "ERROR: This player is not connected!");

	if(id == playerid)
		return SendClientMessage(playerid, COLOR_RED, "ERROR: You cannot use this on yourself!");

	if(pAdmin[playerid] < pAdmin[id])
		return SendClientMessage(playerid, COLOR_RED, "ERROR: You cannot affect this player!");

	if(level < LEVEL_PLAYER || level > LEVEL_ADMIN)
		return SendClientMessage(playerid, COLOR_RED, "ERROR: Invalid level!");

	if(level == pAdmin[id])
		return SendClientMessage(playerid, COLOR_RED, "ERROR: This is the current level of this player!");

	new string[128], name[MAX_PLAYER_NAME+1], name2[MAX_PLAYER_NAME+1], type[9];
	GetPlayerName(playerid, name, sizeof(name));
	GetPlayerName(id, name2, sizeof(name2));

	if(level > pAdmin[id]) type = "promoted";
	else type = "demoted";

	format(string, sizeof(string), "You have %s %s from %s (%i) to %s (%i)", type, name2, GetLevelName(pAdmin[id]), pAdmin[id], GetLevelName(level), level);
	SendClientMessage(playerid, COLOR_WHITE, string);

	format(string, sizeof(string), "%s has %s you from %s (%i) to %s (%i)", name, type, GetLevelName(pAdmin[id]), pAdmin[id], GetLevelName(level), level);
	SendClientMessage(id, COLOR_WHITE, string);
	
	printf("%s has %s %s from %s (%i) to %s (%i)", name, type, name2, GetLevelName(pAdmin[id]), pAdmin[id], GetLevelName(level), level);
	pAdmin[id] = level;
	return 1;
}

CMD:pm(playerid, params[])
{
	new id, msg[100];
	if(sscanf(params, "is[100]", id, msg))
		return SendClientMessage(playerid, COLOR_RED, "USAGE: /Pm <playerid> <message>");

	if(!IsPlayerConnected(id))
		return SendClientMessage(playerid, COLOR_RED, "ERROR: This player is not connected!");

	if(id == playerid)
		return SendClientMessage(playerid, COLOR_RED, "ERROR: You cannot use this on yourself!");

	new string[128], name[MAX_PLAYER_NAME+1], name2[MAX_PLAYER_NAME+1];
	GetPlayerName(playerid, name, sizeof(name));
	GetPlayerName(id, name2, sizeof(name2));

	format(string, sizeof(string),  "PM Sent to %s (%i): %s", name2, id, msg);
	SendClientMessage(playerid, COLOR_YELLOW, string);

	format(string, sizeof(string), "PM Recieved from %s (%i): %s", name, playerid, msg);
	SendClientMessage(id, COLOR_YELLOW, string);

	printf("%s > %s: %s", name, name2, msg);
	return 1;
}
