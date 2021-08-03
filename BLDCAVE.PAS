{
FILENAME: BLDCAVE.PAS

AUTHOR  : SCOTT TUNSTALL

DATE    : 17/4/1999

PURPOSE : TO LOAD A SINGLE BOULDERDASH CAVE.

NOTES   : THIS IS USED BY BOTH THE MAIN GAME AND CONSTRUCTION KIT.

}




unit BLDCave;

interface

{$i playfld.inc }
{$i defs.inc }

type PlayFieldType = array[ 1..MAX_CAVE_WIDTH+1,
                            1..MAX_CAVE_HEIGHT+1] of byte;

type caveinfostruct = record
      m_cPlayer1X          : byte;
      m_cPlayer1Y          : byte;
      m_bIsTwoPlayerGame   : boolean;
      m_cPlayer2X          : byte;
      m_cPlayer2Y          : byte;
      m_cCaveWidth         : byte;
      m_cCaveHeight        : byte;
      m_cCaveDelay         : byte;
      m_wCaveTime          : word;
      m_cDiamondsNeeded    : byte;
      m_cDiamondValue      : byte;
      m_cBonusDiamondValue : byte;
      m_cSlimePermeability : byte;
      m_cAmoebaGrowthDelay : byte;
      m_wMagicWallCycleTime: word;
end;




function LoadCaveFromFile( FileName       : string;
                            var PlayField : PlayFieldType;
                            var CaveInfo   : CaveInfoStruct
                          ) : boolean;

function GetCurrentMapFileName : string;


implementation


var CurrentMapFileName: string;







function SplitByte(AString: string): byte;
var


    TheWord: word;
    ErrCode: integer;

begin
     val(copy(AString,pos(' ', AString)+1,length(AString)-(pos(' ', AString))),
     TheWord, ErrCode);

     SplitByte:=TheWord;
end;



function SplitWord(AString: string): word;
var


    TheWord: word;
    ErrCode: integer;

begin
     val(copy(AString,pos(' ', AString)+1,length(AString)-(pos(' ', AString))),
     TheWord, ErrCode);

     SplitWord:=TheWord;
end;







{
Load a boulderoid .MAP file into memory.

Expects: FileName contains the FULL PATH of the file to load,
         e.g. C:\GAMES\MYMAP.MAP

         PlayField is the array to load the map into

         CaveInfo is used to contain information about the cave
         loaded, such as it's size, speed of play etc.

Returns: If this cave can be loaded, TRUE.
}


function LoadCaveFromFile(  FileName: string;
                            var PlayField: PlayFieldType;
                            var CaveInfo: CaveInfoStruct) : boolean;


const ERROR_LOADING_CAVE = 2;

var InFile          : text;
    across          : byte;
    down            : byte;


    ALineOfText     : string;
    definedwidth    : boolean;
    definedheight   : boolean;




begin
     CurrentMapFileName:=FileName;


     FillChar(PlayField,sizeof(PlayField),ord(empty));

     For across:=1 to MAX_CAVE_WIDTH do
         begin
         PlayField[across,1]:=ord(TitaniumWall);
         PlayField[across,MAX_CAVE_HEIGHT]:=ord(TitaniumWall);
         end;

     For down:=1 to MAX_CAVE_HEIGHT do
         begin
         PlayField[1,down]:=ord(TitaniumWall);
         PlayField[MAX_CAVE_WIDTH,down]:=ord(TitaniumWall);
         end;


     For down:=2 to MAX_CAVE_HEIGHT-1 do
         For across:=2 to MAX_CAVE_WIDTH -1 do
             PlayField[across,down]:=ord(earth);


     Assign(Infile, FileName);
     {$i-}
     Reset(Infile);
     {$i+}
     If IOResult <>0 Then
        Begin
        LoadCaveFromFile:=false;
        exit;
        End;

     { We assume that we are reading boulderoid caves }

     CaveInfo.m_bIsTwoPlayerGame:=false;
     definedwidth:=false;
     definedheight:=false;





     While not eof(InFile) do
     begin
          Readln(InFile,ALineOfText);

          if pos('width', ALineOfText)<>0 then
             begin
             CaveInfo.m_cCaveWidth:=SplitByte(ALineOfText);
             if CaveInfo.m_cCaveWidth >9 then
                definedwidth:=true;
             end;

          if pos('height', ALineOfText)<>0 then
             begin
             CaveInfo.m_cCaveHeight:=SplitByte(ALineOfText);
             if CaveInfo.m_cCaveHeight >9 then
                definedheight:=true;
             end;

          if pos('delay', ALineOfText)<>0 then
             CaveInfo.m_cCaveDelay:=SplitByte(ALineOfText) div 5;
          if pos('time', ALineOfText)<>0 then
             CaveInfo.m_wCaveTime:=SplitWord(ALineOfText);
          if pos('require', ALineOfText)<>0 then
             CaveInfo.m_cDiamondsNeeded:=SplitByte(ALineOfText);
          if pos('dpoints', ALineOfText)<>0 then
             CaveInfo.m_cDiamondValue:=SplitByte(ALineOfText);
          if pos('dextra', ALineOfText)<>0 then
             CaveInfo.m_cBonusDiamondValue:=SplitByte(ALineOfText);
          if pos('permeable', ALineOfText)<>0 then
             CaveInfo.m_cSlimePermeability:=SplitByte(ALineOfText);
          if pos('amrate1', ALineOfText)<>0 then
             CaveInfo.m_cAmoebaGrowthDelay:=SplitByte(ALineOfText);
          if pos('milltime', ALineOfText)<>0 then
             CaveInfo.m_wMagicWallCycleTime:=SplitWord(ALineOfText);




          if (pos('mapstart', ALineOfText)<>0) then
          begin
             if definedwidth and definedheight then
             begin
                  For down:=1 to CaveInfo.m_cCaveHeight do
                  begin
                      Readln(InFile, ALineOfText);

                      For across:=1 to CaveInfo.m_cCaveWidth do
                      case ALineOfText[across] of
                      'P','1' : begin
                                CaveInfo.m_cPlayer1X:= across;
                                CaveInfo.m_cPlayer1Y:= down;
                                end;
                      '2' : begin
                            CaveInfo.m_bIsTwoPlayerGame:=True;
                            CaveInfo.m_cPlayer2X:=across;
                            CaveInfo.m_cPlayer2Y:=down;
                            end;

                      'F' : PlayField[across,down]:=ord(rockford);
                      ' ' : PlayField[across,down]:=ord(empty);
                      '.' : PlayField[across,down]:=ord(earth);
                      'w' : PlayField[across,down]:=ord(NormalWall);
                      'x' : PlayField[across,down]:=ord(ExpandingWall);
                      'm' : PlayField[across,down]:=ord(MagicWall);
                      'W' : PlayField[across,down]:=ord(Titaniumwall);
                      'a' : PlayField[across,down]:=ord(Amoeba);
                      's' : PlayField[across,down]:=ord(PermWall);
                      'r' : PlayField[across,down]:=ord(Boulder);
                      'd' : PlayField[across,down]:=ord(Diamond);


                      'n' : PlayField[across,down]:=ord(FireFlyUp);
                      'q' : PlayField[across,down]:=ord(FireFlyDown);
                      'Q' : PlayField[across,down]:=ord(FireFlyLeft);
                      'O' : PlayField[across,down]:=ord(FireFlyRight);
                      'b' : PlayField[across,down]:=ord(ButterFlyUp);
                      'B' : PlayField[across,down]:=ord(ButterFlyRight);
                      'c' : PlayField[across,down]:=ord(ButterFlyDown);
                      'C' : PlayField[across,down]:=ord(ButterFlyLeft);
                      'X' : PlayField[across,down]:=ord(VisibleLevelExit);
                      'H' : PlayField[across,down]:=ord(InVisibleLevelExit);
                      end;
                  end;
                  Readln(InFile, ALineOfText); { Skip 'mapend' }

             end
             else
                 begin
                 writeln('Mapstart without width & height defined !');
                 halt(ERROR_LOADING_CAVE);
                 end;
          end;

     end;

     close(InFile);
     LoadCaveFromFile:=true;
end;






{
=========================================================

Return name of map currently in use/ most recently loaded

Used for error reporting.

---------------------------------------------------------
}

function GetCurrentMapFileName: string;
begin
     GetCurrentMapFileName:=CurrentMapFileName;
end;









begin
     Writeln('BOULDEROID MAP LOAD ROUTINES FOR BOULDERDASH');
     Writeln('(C) 1999 Scott Tunstall.');
     Writeln('This unit is FREEWARE. Please distribute source/compiled code');
     Writeln('freely in it''s original, unaltered state.');
     Writeln;


end.



