private["_unit","_amount","_copName"];
if(playerSide != west) exitWith {hint "Was glaubst du wer du bist? Auf jedenfall kein Cop."};
if((lbCurSel 2406) == -1) exitWith {hint "Du musst eine Person anklicken!"};
if((lbCurSel 2407) == -1) exitWith {hint "Du musst ein Verbrechen anklicken!"};
_unit = lbData [2406,lbCurSel 2406];
_unit = call compile format["%1",_unit];
_amount = lbData [2407,lbCurSel 2407];
_copName = profileName;
if(isNil "_unit") exitWith {};
//if(side _unit == west) exitWith {hint "What are ya trying to do, start a police war? Dickhead." };
//if(_unit == player) exitWith {hint "You can't make yourself wanted, dipshit";};
if(isNull _unit) exitWith {};

[[1,format["%1 wurde von %2 zur Fahndung ausgeschrieben.",_unit getVariable["realname",name _unit],_copName,_amount,getPlayerUID _unit]],"life_fnc_broadcast",west,false] spawn life_fnc_MP;

[[getPlayerUID _unit,_unit getVariable["realname",name _unit],_amount],"life_fnc_wantedAdd",false,false] spawn life_fnc_MP;