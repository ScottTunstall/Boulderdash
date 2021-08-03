Unit BldCaves;




interface


{$i playfld.inc }
{$i defs.inc }


type PlayFieldType = array[ 1..MAX_CAVE_WIDTH+1,
                            1..MAX_CAVE_HEIGHT+1] of byte;

type caveinfostruct = record
      Player1X          : byte;
      Player1Y          : byte;
      2PlayerGame       : boolean;
      Player2X          : byte;
      Player2Y          : byte;
      CaveWidth         : byte;
      CaveHeight        : byte;
      CaveDelay         : byte;
      CaveTime          : word;
      DiamondsNeeded    : byte;
      DiamondValue      : byte;
      BonusDiamondValue : byte;
      SlimePermeability : byte;
      AmoebaGrowthDelay : byte;
      MagicWallCycleTime: word;
end;








type GameTypes = ( OnePlayer, TwoPlayerCoop, TwoPlayerCompetitive);

procedure LoadCaveFromFile( FileName       : string;
                            var Cave       : PlayFieldType;
                            var CaveInfo   : CaveInfoStruct
                          );

procedure LoadCave(     TheGameType  : GameTypes;
                        CurrentCave  : byte;
                        Difficulty   : byte;
                        var Cave     : PlayFieldType;
                        var CaveInfo : CaveInfoStruct
                  );



implementation

type CaveListType = array [ 1..MAX_CAVES,
                            1..DIFFICULTY_LEVELS] of string[8];

var
    OnePlayerCaveDir   : string[80];
    CoopCaveDir        : string[80];
    CompetitiveCaveDir : string[80];

    OnePlayerCaveList   : CaveListType;
    CoopCaveList        : CaveListType;
    CompetitiveCaveList : CaveListType;






procedure GetCaveList( ListFile: string;
                       var ListOfStrings: CaveListType);

const NO_LISTFILE = 3;

var CaveListFile: Text;
    DiffCount    : byte;
    CaveListCount: byte;

begin
     Assign(CaveListFile, 'CAVES.LST');
     {$i-}
     Reset(CaveListFile);
     {$i+}
     If IOResult <>0 Then
        Begin
        Writeln('Cannot open '+ListFile+'. Check that the file is not already');
        Writeln('in use.');
        Halt(NO_LISTFILE);
        End;

     for diffcount:=1 to DIFFICULTY_LEVELS do
         for cavelistcount:=1 to MAX_CAVES do
             Readln(CaveListfile,ListOfStrings[Cavelistcount,diffcount]);

     Close(CaveListFile);
end;




{ Load cave names into memory }

Procedure LoadCaveInfo;
const NO_CAVE_INI = 1;

var Infile: Text;
    Count : byte;

begin
     Assign(InFile,'CAVES.INI');
     {$i-}
     Reset(InFile);
     {$i+}
     If IOResult <>0 Then
        Begin
        Writeln('Cannot open CAVES.INI . Check that the file exists and is');
        Writeln('not already in use.');
        Halt(NO_CAVE_INI);
        End;

     Readln(Infile,OnePlayerCaveDir);
     Readln(Infile,CoopCaveDir);
     Readln(Infile,CompetitiveCaveDir);

     GetCaveList(OnePlayerCaveDir+'\CAVES.LST',OnePlayerCaveList);
     GetCaveList(CoopCaveDir+'\CAVES.LST',CoopCaveList);
     GetCaveList(CompetitiveCaveDir+'\CAVES.LST',CompetitiveCaveList);

     close(InFile);
end;














{
  =======================================================================

  Load the specified cave from hard disk. No point in mallocing
  for all caves when you're only playing one at a time.

  Would be different of course, if we were loading from tape, a la C64 :)

  -----------------------------------------------------------------------
}



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









procedure LoadCaveFromFile( FileName: string;
                            var Cave: PlayFieldType;
                            var CaveWidth: byte;
                            var CaveHeight: byte);


const ERROR_LOADING_CAVE = 2;

var InFile          : text;
    across          : byte;
    down            : byte;


    ALineOfText     : string;
    definedwidth    : boolean;
    definedheight   : boolean;




begin
     FillChar(cave,sizeof(cave),ord(empty));

     For across:=1 to MAX_CAVE_WIDTH do
         begin
         Cave[across,1]:=ord(TitaniumWall);
         Cave[across,MAX_CAVE_HEIGHT]:=ord(TitaniumWall);
         end;

     For down:=1 to MAX_CAVE_HEIGHT do
         begin
         Cave[1,down]:=ord(TitaniumWall);
         Cave[MAX_CAVE_WIDTH,down]:=ord(TitaniumWall);
         end;


     For down:=2 to MAX_CAVE_HEIGHT-1 do
         For across:=2 to MAX_CAVE_WIDTH -1 do
             Cave[across,down]:=ord(earth);


     Assign(Infile, FileName);
     {$i-}
     Reset(Infile);
     {$i+}
     If IOResult <>0 Then
        Begin
        Writeln('Could not open cave file!');
        Writeln('Check that required files exist and are not currently in use.');
        Halt(ERROR_LOADING_CAVE);
        End;

     { We assume that we are reading boulderoid caves }


     definedwidth:=false;
     definedheight:=false;





     While not eof(InFile) do
     begin
          Readln(InFile,ALineOfText);

          if pos('width', ALineOfText)<>0 then
             begin
             CaveWidth:=SplitByte(ALineOfText);
             if CaveWidth >19 then
                definedwidth:=true;
             end;

          if pos('height', ALineOfText)<>0 then
             begin
             CaveHeight:=SplitByte(ALineOfText);
             if CaveHeight >19 then
                definedheight:=true;
             end;

          if pos('delay', ALineOfText)<>0 then
             CaveDelay:=SplitByte(ALineOfText) div 5;
          if pos('time', ALineOfText)<>0 then
             CaveTime:=SplitWord(ALineOfText);
          if pos('require', ALineOfText)<>0 then
             DiamondsNeeded:=SplitByte(ALineOfText);
          if pos('dpoints', ALineOfText)<>0 then
             DiamondValue:=SplitByte(ALineOfText);
          if pos('dextra', ALineOfText)<>0 then
             BonusDiamondValue:=SplitByte(ALineOfText);
          if pos('permeable', ALineOfText)<>0 then
             SlimePermeability:=SplitByte(ALineOfText);
          if pos('amrate1', ALineOfText)<>0 then
             AmoebaGrowthDelay:=SplitByte(ALineOfText);
          if pos('milltime', ALineOfText)<>0 then
             MagicWallCycleTime:=SplitWord(ALineOfText);




          if (pos('mapstart', ALineOfText)<>0) then
          begin
             if definedwidth and definedheight then
             begin
                  For down:=1 to CaveHeight do
                  begin
                      Readln(InFile, ALineOfText);

                      For across:=1 to CaveWidth do
                      case ALineOfText[across] of
                      'P','1' : begin
                                Player1X:= across;
                                Player1Y:= down;
                                end;
                      '2' : begin
                            Player2X:=across;
                            Player2Y:=down;
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
end;










procedure LoadCave( var Cave: PlayFieldType;
                        TheGameType: GameTypes;
                        CurrentCave: byte;
                        Difficulty: byte
                        var CaveWidth: byte;
                        var CaveHeight: byte
                  );



begin
     case TheGameType of
     OnePlayer           :
                         LoadCaveFromFile(OnePlayerCaveDir+'\'+
                         OnePlayerCaveList[CurrentCave,
                         Difficulty]+'.MAP', Cave);

     TwoPlayerCoop       :
                         LoadCaveFromFile(CoopCaveDir+'\'+
                         CoopCaveList[CurrentCave,
                         Difficulty]+'.MAP', Cave);

     TwoPlayerCompetitive:
                         LoadCaveFromFile(CompetitiveCaveDir+'\'+
                         CompetitiveCaveList[CurrentCave,
                         Difficulty]+'.MAP', Cave);
     end;


end;







