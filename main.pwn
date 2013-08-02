/******************************************************************************/
#define   STATE_STARTING		0
#define 	STATE_COUNTDOWN 	1
#define 	STATE_STARTED   	2
#define 	STATE_FINISHED      3

#define 	MOVE_FORWARD		1
#define 	MOVE_BACK           2
#define 	MOVE_LEFT       	3
#define 	MOVE_RIGHT      	4
#define 	MOVE_FORWARD_LEFT   5
#define 	MOVE_FORWARD_RIGHT	6
#define 	MOVE_BACK_LEFT		7
#define 	MOVE_BACK_RIGHT		8

#define     LEVEL_PLAYER        0
#define     LEVEL_MOD           1
#define     LEVEL_ADMIN         2

#define 	MAX_CHECKPOINTS 	100

#if defined MAX_PLAYERS
#undef 		MAX_PLAYERS
#endif
#define 	MAX_PLAYERS 		50

#define COLOR_TRANSPARENT	0xFFFFFF00
#define COLOR_WHITE			0xFFFFFFC8
#define COLOR_GREY			0xC0C0C0C8
#define COLOR_BLACK			0x000000C8
#define COLOR_RED			0xFF0000C8
#define COLOR_DARKRED		0x400000C8
#define COLOR_BLUE			0x0080C0C8
#define COLOR_LIGHTBLUE		0x00FFFFC8
#define COLOR_ORANGE		0xFF8000C8
#define COLOR_YELLOW		0xFFFF00C8
#define COLOR_LIGHTGREEN	0x80FF80C8
#define COLOR_GREEN			0x00FF00C8
#define COLOR_PINK			0xFF80FFC8
#define COLOR_PURPLE		0x800080C8

#define C_WHITE			"{FFFFFF}"
#define C_GREY			"{C0C0C0}"
#define C_BLACK			"{000000}"
#define C_RED			"{FF0000}"
#define C_DARKRED		"{400000}"
#define C_BLUE			"{0080C0}"
#define C_LIGHTBLUE		"{00FFFF}"
#define C_ORANGE		"{FF8000}"
#define C_YELLOW		"{FFFF00}"
#define C_LIGHTGREEN	"{80FF80}"
#define C_GREEN			"{00FF00}"
#define C_PINK			"{FF80FF}"
#define C_PURPLE		"{800080}"

#define IRC_WHITE 		"0"
#define IRC_BLACK 		"1"
#define IRC_DARKBLUE 	"2"
#define IRC_GREEN 		"3"
#define IRC_RED 		"4"
#define IRC_BROWN 		"5"
#define IRC_PURPLE 		"6"
#define IRC_ORANGE 		"7"
#define IRC_YELLOW 		"8"
#define IRC_LIMEGREEN 	"9"
#define IRC_BLUEGREEN 	"10"
#define IRC_AQUABLUE 	"11"
#define IRC_LIGHTBLUE 	"12"
#define IRC_PINK 		"13"
#define IRC_GREY 		"14"
#define IRC_LIGHTGREY 	"15"

enum
{
	DIALOG_REGISTER,
	DIALOG_LOGIN,
	DIALOG_STATS,
	DIALOG_MAIN,
	DIALOG_VEHICLE,
	DIALOG_CPLIST,
	DIALOG_CP,
	DIALOG_CLOSE
}
/******************************************************************************/
new	pEditName				[MAX_PLAYERS][20],
	bool:pEdit				[MAX_PLAYERS],
	bool:pEditCircuit		[MAX_PLAYERS],
	pEditVehicle			[MAX_PLAYERS],
	bool:pEditAir			[MAX_PLAYERS],
	pEditTick				[MAX_PLAYERS],
	pEditCurrent	  		[MAX_PLAYERS],
	Float:pEditCp			[MAX_PLAYERS][MAX_CHECKPOINTS][3],
	pEditObj            	[MAX_PLAYERS],
	pEditLR					[MAX_PLAYERS],
	pEditUD					[MAX_PLAYERS],
	pEditMode				[MAX_PLAYERS],
	pEditLastMove			[MAX_PLAYERS],
	Float:pEditSpeed		[MAX_PLAYERS],

	bool:pJoined			[MAX_PLAYERS],
	pVeh					[MAX_PLAYERS],
	pCp						[MAX_PLAYERS],
	pLap					[MAX_PLAYERS],
	pTime        			[MAX_PLAYERS],
	pSpec					[MAX_PLAYERS],
	bool:pClass				[MAX_PLAYERS],
	bool:pSkipClass         [MAX_PLAYERS],
	bool:pLoggedIn			[MAX_PLAYERS],
	pAdmin					[MAX_PLAYERS],
	pSkin                   [MAX_PLAYERS],
	pWin					[MAX_PLAYERS],
	pLoss					[MAX_PLAYERS],
	pSlot                   [MAX_PLAYERS],
	bool:pBan               [MAX_PLAYERS],
	pReason					[MAX_PLAYERS][32],

	PlayerText:td_intro     [MAX_PLAYERS],
	PlayerText:td_timeleft  [MAX_PLAYERS],
	PlayerText:td_back      [MAX_PLAYERS],
	PlayerText:td_time  	[MAX_PLAYERS][2],
	PlayerText:td_pos    	[MAX_PLAYERS][5],
	PlayerText:td_speed		[MAX_PLAYERS][3],
	PlayerText:td_progress	[MAX_PLAYERS][3],
	PlayerText:td_border    [MAX_PLAYERS],
	PlayerText:td_cmds      [MAX_PLAYERS],
	PlayerText:td_info		[MAX_PLAYERS];
/******************************************************************************/
new DB:db;
new gTime[2];

new	rTimer,
	rCountdown,
	rLaps,
	rPos,
	rState,
	bool:rCircuit,
	bool:rAir,
	rVehicle,
	rName[20],
	rRecord,
	rRecordholder[MAX_PLAYER_NAME+1],
	Float:rCp[MAX_CHECKPOINTS][3];
/******************************************************************************/
new VehicleNames[212][] =
{
    "Landstalker", "Bravura", "Buffalo", "Linerunner", "Pereniel", "Sentinel", "Dumper", "Firetruck", "Trashmaster", "Stretch", "Manana", "Infernus",
    "Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam", "Esperanto", "Taxi", "Washington", "Bobcat", "Mr Whoopee", "BF Injection",
    "Hunter", "Premier", "Enforcer", "Securicar", "Banshee", "Predator", "Bus", "Rhino", "Barracks", "Hotknife", "Trailer", "Previon", "Coach", "Cabbie",
    "Stallion", "Rumpo", "RC Bandit", "Romero", "Packer", "Monster", "Admiral", "Squalo", "Seasparrow", "Pizzaboy", "Tram", "Trailer", "Turismo", "Speeder",
    "Reefer", "Tropic", "Flatbed", "Yankee", "Caddy", "Solair", "Berkley's RC Van", "Skimmer", "PCJ-600", "Faggio", "Freeway", "RC Baron", "RC Raider",
    "Glendale", "Oceanic", "Sanchez", "Sparrow", "Patriot", "Quad", "Coastguard", "Dinghy", "Hermes", "Sabre", "Rustler", "ZR3 50", "Walton", "Regina",
    "Comet", "BMX", "Burrito", "Camper", "Marquis", "Baggage", "Dozer", "Maverick", "News Chopper", "Rancher", "FBI Rancher", "Virgo", "Greenwood",
    "Jetmax", "Hotring", "Sandking", "Blista Compact", "Police Maverick", "Boxville", "Benson", "Mesa", "RC Goblin", "Hotring Racer A", "Hotring Racer B",
    "Bloodring Banger", "Rancher", "Super GT", "Elegant", "Journey", "Bike", "Mountain Bike", "Beagle", "Cropdust", "Stunt", "Tanker", "RoadTrain",
    "Nebula", "Majestic", "Buccaneer", "Shamal", "Hydra", "FCR-900", "NRG-500", "HPV1000", "Cement Truck", "Tow Truck", "Fortune", "Cadrona", "FBI Truck",
    "Willard", "Forklift", "Tractor", "Combine", "Feltzer", "Remington", "Slamvan", "Blade", "Freight", "Streak", "Vortex", "Vincent", "Bullet", "Clover",
    "Sadler", "Firetruck", "Hustler", "Intruder", "Primo", "Cargobob", "Tampa", "Sunrise", "Merit", "Utility", "Nevada", "Yosemite", "Windsor", "Monster A",
    "Monster B", "Uranus", "Jester", "Sultan", "Stratum", "Elegy", "Raindance", "RC Tiger", "Flash", "Tahoma", "Savanna", "Bandito", "Freight", "Trailer",
    "Kart", "Mower", "Duneride", "Sweeper", "Broadway", "Tornado", "AT-400", "DFT-30", "Huntley", "Stafford", "BF-400", "Newsvan", "Tug", "Trailer A", "Emperor",
    "Wayfarer", "Euros", "Hotdog", "Club", "Trailer B", "Trailer C", "Andromada", "Dodo", "RC Cam", "Launch", "Police Car (LSPD)", "Police Car (SFPD)",
    "Police Car (LVPD)", "Police Ranger", "Picador", "S.W.A.T. Van", "Alpha", "Phoenix", "Glendale", "Sadler", "Luggage Trailer A", "Luggage Trailer B",
    "Stair Trailer", "Boxville", "Farm Plow", "Utility Trailer"
};

new RaceVehicles[] =
{
	400, 401, 402, 403, 404, 405, 406, 407, 408, 409, 410, 411, 412, 413, 414, 415, 416, 417, 418, 419, 420, 421, 422, 423, 424, 425, 426, 427, 428, 429,
	430, 431, 432, 433, 434, 436, 437, 438, 439, 440, 441, 442, 443, 444, 445, 446, 447, 448, 451, 452, 453, 454, 455, 456, 457, 458, 459, 460, 461, 462,
	463, 464, 465, 466, 467, 468, 469, 470, 471, 472, 473, 474, 475, 476, 477, 478, 479, 480, 481, 482, 483, 484, 485, 486, 487, 488, 489, 490, 491, 492,
	493, 494, 495, 596, 497, 498, 499, 500, 501, 502, 503, 504,	505, 506, 507, 508,	509, 510, 511, 512, 513, 514, 515, 516, 517, 518, 519, 520, 521, 522,
	523, 524, 525, 526, 527, 528, 529, 530, 531, 532, 533, 534, 535, 536, 539, 540,	541, 542, 543, 544, 545, 546, 547, 548, 549, 550, 551, 552, 553, 554,
	555, 556, 557, 558, 559, 560, 561, 562, 563, 564, 565, 566, 567, 568, 571, 572, 573, 574, 575, 576, 577, 578, 579, 580, 581, 582, 583, 585, 586, 587,
	588, 589, 592, 593, 594, 595, 596, 597, 598, 599, 600, 601, 602, 603, 604, 605, 609
};
