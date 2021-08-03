{
FILENAME: BLDCAVES.PAS

AUTHOR  : SCOTT TUNSTALL

DATE    : 17/4/1999

PURPOSE : TO KEEP TRACK OF ALL BOULDERDASH CAVES USED IN A GAME.
}


Unit BldCaves;



interface

uses bldcave, crt;



function LoadCave(     ucGameType   : byte;
                       ucCurrentCave   : byte;
                       ucDifficulty    : byte;
                       var rPlayFieldType : PlayFieldType;
                       var rCaveInfoStruct  : CaveInfoStruct
                  ) : boolean;



procedure DebugLoadCave(   ucGameType   : byte;
                           ucCurrentCave   : byte;
                           ucDifficulty    : byte;
                           var rPlayFieldType : PlayFieldType;
                           var rCaveInfoStruct  : CaveInfoStruct
                       );







implementation

const OnePlayer = 1;
const TwoPlayerCoop = 2;
const TwoPlayerCompetitive = 3;


type CaveListType = array [ 1..MAX_CAVES,
                            1..DIFFICULTY_LEVELS] of string[8];

var
    OnePlayerCaveDir   : string[80];
    CoopCaveDir        : string[80];
    CompetitiveCaveDir : string[80];

    OnePlayerCaveList   : CaveListType;
    CoopCaveList        : CaveListType;
    CompetitiveCaveList : CaveListType;






procedure GetCaveList( strListFile: string;
                       var ListOfStrings: CaveListType);

const NO_LISTFILE = 1;

var CaveListFile: Text;
    DiffCount    : byte;
    CaveListCount: byte;

begin
     Assign(CaveListFile, strListFile);
     {$i-}
     Reset(CaveListFile);
     {$i+}
     If IOResult <>0 Then
        Begin
        Writeln('Cannot open '+strListFile+'. Check that the file is not already');
        Writeln('in use.');
        Halt(NO_LISTFILE);
        End;

     for diffcount:=1 to DIFFICULTY_LEVELS do
         for cavelistcount:=1 to MAX_CAVES do
             Readln(CaveListfile,ListOfStrings[Cavelistcount,diffcount]);

     Close(CaveListFile);
end;







{ Load PlayField names into memory }

Procedure LoadCaveInfo;
const NO_CAVE_INI = 2;

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

  Load the specified PlayField from hard disk. No point in mallocing
  for all caves when you're only playing one at a time.

  Would be different of course, if we were loading from tape, a la C64 :)

  -----------------------------------------------------------------------
}




function LoadCave( ucGameType : byte;
                    ucCurrentCave : byte;
                    ucDifficulty  : byte;
                    var rPlayFieldType   : PlayFieldType;
                    var rCaveInfoStruct    : CaveInfoStruct
                    ) : boolean;



begin
     case ucGameType of
     OnePlayer           :
                         LoadCave:= LoadCaveFromFile( OnePlayerCaveDir+'\'+
                                                      OnePlayerCaveList[ucCurrentCave,
                                                      ucDifficulty]+'.MAP',
                                                      rPlayFieldType,
                                                      rCaveInfoStruct
                                                      );

     TwoPlayerCoop       :
                         LoadCave:=LoadCaveFromFile( CoopCaveDir+'\'+
                                                     CoopCaveList[ucCurrentCave,
                                                     ucDifficulty]+'.MAP',
                                                     rPlayFieldType,
                                                     rCaveInfoStruct
                                                   );

     TwoPlayerCompetitive:
                         LoadCave:=LoadCaveFromFile( CompetitiveCaveDir+'\'+
                                                     CompetitiveCaveList[ucCurrentCave,
                                                     ucDifficulty]+'.MAP',
                                                     rPlayFieldType,
                                                     rCaveInfoStruct);
     end;


end;





{
  Does the same as LoadCave, except it will halt the program if the
  cave cannot be loaded. Handy for debugging.
}


procedure DebugLoadCave(    ucGameType   : byte;
                            ucCurrentCave   : byte;
                            ucDifficulty    : byte;
                            var rPlayFieldType : PlayFieldType;
                            var rCaveInfoStruct  : CaveInfoStruct);

const MAP_FILE_NOT_FOUND_OR_READABLE = 3;

begin
     if not (LoadCave( ucGameType,
                       ucCurrentCave,
                       ucDifficulty,
                       rPlayFieldType,
                       rCaveInfoStruct))
        then begin
             TextMode(CO80);
             Writeln('Failed to load map : ', GetCurrentMapFileName);
             Write('Game Type : ');

             case ucGameType of
             OnePlayer            : Writeln('One Player');
             TwoPlayerCoop        : Writeln('Two Player cooperative');
             TwoPlayerCompetitive : Writeln('Two Player competitive');
             end;

             Writeln('Cave index : ', ucCurrentCave);
             Writeln('Difficulty : ', ucDifficulty);

             halt(MAP_FILE_NOT_FOUND_OR_READABLE);
        end;
end;













Begin
     LoadCaveInfo;

     Writeln('BOULDERDASH CAVE MANAGEMENT ROUTINES');
     Writeln('(C) 1999 Scott Tunstall.');
     Writeln('This unit is FREEWARE. Please distribute source/compiled code');
     Writeln('freely in it''s original, unaltered state.');
     Writeln;

End.