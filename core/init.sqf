#include <macro.h>
/*
	Master client initialization file
*/
life_firstSpawn = true;
life_session_completed = false;
private["_handle","_timeStamp","_pic"];
0 cutText["Setting up client, please wait...","BLACK FADED"];
0 cutFadeOut 9999999;
_timeStamp = diag_tickTime;
diag_log "------------------------------------------------------------------------------------------------------";
diag_log "--------------------------------- Starting Altis Life Client Init ----------------------------------";
diag_log "------------------------------------------------------------------------------------------------------";
waitUntil {!isNull player && player == player}; //Wait till the player is ready
//Setup initial client core functions
diag_log "::Life Client:: Initialization Variables";
[] call compile PreprocessFileLineNumbers "core\configuration.sqf";
diag_log "::Life Client:: Variables initialized";
diag_log "::Life Client:: Setting up Eventhandlers";
[] call life_fnc_setupEVH;
diag_log "::Life Client:: Eventhandlers completed";
diag_log "::Life Client:: Setting up user actions";
[] call life_fnc_setupActions;
diag_log "::Life Client:: User actions completed";
diag_log "::Life Client:: Waiting for server functions to transfer..";
waitUntil {(!isNil {TON_fnc_clientGangLeader})};
diag_log "::Life Client:: Received server functions.";
0 cutText ["Warte auf den Server...","BLACK FADED"];
0 cutFadeOut 99999999;
diag_log "::Life Client:: Waiting for the server to be ready..";
waitUntil{!isNil "life_server_isReady"};
waitUntil{(life_server_isReady OR !isNil "life_server_extDB_notLoaded")};
if(!isNil "life_server_extDB_notLoaded") exitWith {
	diag_log "::Life Client:: Server did not load extDB";
	999999 cutText ["The server-side extension extDB was not loaded into the engine, report this to the server admin.","BLACK FADED"];
	999999 cutFadeOut 99999999;
};
[] call SOCK_fnc_dataQuery;
waitUntil {life_session_completed};
0 cutText["Beendige Client-Setup Prozedur...","BLACK FADED"];
0 cutFadeOut 9999999;

//diag_log "::Life Client:: Group Base Execution";
[] spawn life_fnc_escInterupt;

switch (playerSide) do
{
	case west:
	{
		_handle = [] spawn life_fnc_initCop;
		waitUntil {scriptDone _handle};
	};
	
	case civilian:
	{
		_handle = [] spawn life_fnc_initCiv;
		waitUntil {scriptDone _handle};
	};
	
	case independent:
	{
		_handle = [] spawn life_fnc_initMedic;
		waitUntil {scriptDone _handle};
	};

	case east:
	{
		_handle = [] spawn life_fnc_initADAC;
		waitUntil {scriptDone _handle};
	};
	
	case sideLogic:
    {
        _handle = [] spawn life_fnc_initZeus;
        waitUntil {scriptDone _handle};
    };
};

player setVariable["restrained",false,true];
player setVariable["Escorting",false,true];
player setVariable["transporting",false,true];
diag_log "Past Settings Init";
[] execFSM "core\fsm\client.fsm";
diag_log "Executing client.fsm";
waitUntil {!(isNull (findDisplay 46))};
diag_log "Display 46 Found";
(findDisplay 46) displayAddEventHandler ["KeyDown", "_this call life_fnc_keyHandler"];
player addRating 99999999;
diag_log "------------------------------------------------------------------------------------------------------";
diag_log format["                End of Altis Life Client Init :: Total Execution Time %1 seconds ",(diag_tickTime) - _timeStamp];
diag_log "------------------------------------------------------------------------------------------------------";
[[getPlayerUID player,player getVariable["realname",name player]],"life_fnc_wantedProfUpdate",false,false] spawn life_fnc_MP;
life_sidechat = true;
[[player,life_sidechat,playerSide],"TON_fnc_managesc",false,false] spawn life_fnc_MP;
0 cutText ["","BLACK IN"];
[] call life_fnc_hudSetup;
LIFE_ID_PlayerTags = ["LIFE_PlayerTags","onEachFrame","life_fnc_playerTags"] call BIS_fnc_addStackedEventHandler;
LIFE_ID_RevealObjects = ["LIFE_RevealObjects","onEachFrame","life_fnc_revealObjects"] call BIS_fnc_addStackedEventHandler;
[] call life_fnc_settingsInit;
player setVariable["steam64ID",getPlayerUID player];
player setVariable["realname",profileName,true];

life_fnc_moveIn = compileFinal
"
	player moveInCargo (_this select 0);
";

life_fnc_garageRefund = compileFinal
"
	_price = _this select 0;
	_unit = _this select 1;
	if(_unit != player) exitWith {};
	ja_pare = ja_pare + _price;
";

[] execVM "core\init_survival.sqf";

_handle = [] spawn compile PreprocessFileLineNumbers "eigen\configuration.sqf";
waitUntil {scriptDone _handle};
_handle = [] spawn compile PreprocessFileLineNumbers "eigen\functions.sqf";
waitUntil {scriptDone _handle};

__CONST__(life_paycheck,life_paycheck); //Make the paycheck static.