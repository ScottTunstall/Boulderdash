{
FILENAME: BLDGMSEL.PAS

AUTHOR  : SCOTT TUNSTALL

DATE    : 5/4/1999

PURPOSE : BOULDERDASH GAME TYPE SELECT SCREEN

}



Unit BldGmSel;

interface


procedure GameSelect( var TheGameType    : byte;
                      var StartLevel     : byte;
                      var Difficulty : byte;
                      lPlayer1HiScore : longint;
                      lPlayer2HiScore : longint
                    );




implementation

uses kojakvga, bouldmsc, nwkbdint;


const OnePlayer     = 1;
const TwoPlayerCoop = 2;
const TwoPlayerCompetitive = 3;


const DIFFICULTY_LEVELS = 5;

const SCANCODE_UP = 72;
const SCANCODE_DOWN = 80;
const SCANCODE_LEFT = 75;
const SCANCODE_RIGHT = 77;
const SCANCODE_ENTER = 28;
const SCANCODE_SPACE = 57;




procedure GameSelect( var TheGameType    : byte;
                      var StartLevel     : byte;
                      var Difficulty : byte;
                          lPlayer1HiScore : longint;
                          lPlayer2HiScore : longint
                      );
var

   { Game select Bitmap/ Palette pointer }

    pGameSelBmp     : pointer;
    GameSelPal : PaletteType;
    GamePalette             : PaletteType;
    pScratchBmp             : pointer;
    WndRect                 : WindowType;


    { Tile movement/ blit vars }
    pTileImg                : pointer;
    pArrowImg               : pointer;
    yoffset                 : integer;
    across                  : word;
    down                    : word;

    { BDAdviseFont vars }
    w, h                    : byte;

    ArrowItem               : byte;
    ArrowDelay              : byte;

    Player1HighScoreStr,
    Player2HighScoreStr     : string[8];


begin
     pScratchBmp:=New64KBitmap;
     pGameSelBmp:=New64KBitmap;
     UseBitmap(pGameSelBmp);
     LoadPCX('selGame.pcx', GameSelPal);

     LoadShape('bluetile.img', pTileImg);
     LoadShape('arrow.img', pArrowImg);


     InitVGAMode;
     UseBitmap(pScratchBmp);
     GetWindowSettings(WndRect);


     { Define clipping region so that our tiles won't overwrite wall
       at edge of screen }

     SetWindow(8,8,311,191);

     Cls;

     UsePalette(GameSelPal);
     UseFont(StandardVGAFont);

     { Advise boulderdash unit where our font & bitmap is }

     BDAdviseBitmap(pScratchBmp);


     HookKeyboardInt;

     yoffset:=0;
     ArrowItem:=1;
     ArrowDelay:=10;

     str(lPlayer1HiScore:7, Player1HighScoreStr);
     str(lPlayer2HiScore:7, Player2HighScoreStr);


     Repeat
           { Draw clipped tiles at top of window }

           For across:=0 to 18 do
               ClipBlock(across SHL 4,yoffset,pTileImg^);

           For down:=0 to 10 do
               For across:=0 to 18 do
                   Block(across SHL 4,yoffset+16+(down * 16), pTileImg^);

           { And tiles at bottom of window }

           For across:=0 to 18 do
               ClipBlock(across SHL 4,yoffset+192,pTileImg^);

           CopyMaskedBitmap(pGameSelBmp, pScratchBmp);

           Case TheGameType of
           OnePlayer            : BDPrintAt(56,24,'1',1);

           TwoPlayerCoop        : Begin
                                  BDPrintAt(56,24,'2',1);
                                  BDPrintAt(56,32,'CO OP',10);
                                  End;

           TwoPlayerCompetitive : Begin
                                  BDPrintAt(56,24,'2',1);
                                  BDPrintAt(56,32,'VS MODE',10);
                                  End;
           End;

           BDPrintAt(188,80,chr(64+StartLevel),10);
           BDPrintAt(188,88,chr(48+Difficulty),10);


           BDPrintAt(32,152,Player1HighScoreStr,1);
           BDPrintAt(152,152,Player2HighScoreStr,1);



           { Should we blit option highlight arrow or not ? }

           Dec(ArrowDelay);
           if ArrowDelay < 5 Then
              Begin
              Case ArrowItem Of
              1: Block(184,27,pArrowImg^);
              2: Block(208,83,pArrowImg^);
              3: Block(208,91,pArrowImg^);
              End;


              If ArrowDelay = 0 Then
                 ArrowDelay:=10;
              End;


           { Now transfer the back buffer to the main screen }

           Vwait(3);
           ShowAllBitmap(pScratchBmp);

           dec(yoffset);
           if yoffset = -16 then yoffset:=0;


           { Handle cursor key presses }


           if ArrowDelay MOD 3=0 Then
              Begin

              { Cursor up ? }


              if keydown[SCANCODE_UP] Then
                 begin
                 if Arrowitem = 1 Then
                    ArrowItem:= 3
                 else
                     dec(ArrowItem);
                 end
              else
                  { Cursor down ? }

                  if keydown[SCANCODE_DOWN] Then
                     begin
                     if ArrowItem = 3 Then
                        ArrowItem:= 1
                     else
                         inc(ArrowItem);
                     end;



              { Cursor left ? }

              if keydown[SCANCODE_LEFT] Then
                 Begin
                 Case ArrowItem of
                 1: Case TheGameType of
                    OnePlayer            : TheGameType:=TwoPlayerCompetitive;
                    TwoPlayerCoop        : TheGameType:=OnePlayer;
                    TwoPlayerCompetitive : TheGameType:=TwoPlayerCoop;
                    End;

                 2: Begin
                    If StartLevel = 1 Then
                       StartLevel:= 13
                    Else
                        Dec(StartLevel,4);
                    End;

                 3: If Difficulty = 1 Then
                       Difficulty:= DIFFICULTY_LEVELS
                    Else
                        Dec(Difficulty);
                 End
                 End
              Else
                  { Cursor right ? }

                  if keydown[SCANCODE_RIGHT] Then
                     Begin
                     Case ArrowItem of
                     1: Case TheGameType of
                        OnePlayer            : TheGameType:=TwoPlayerCoop;
                        TwoPlayerCoop        : TheGameType:=TwoPlayerCompetitive;
                        TwoPlayerCompetitive : TheGameType:=OnePlayer;
                        End;

                     2: Begin
                        Inc(StartLevel,4);
                        If StartLevel > 13 Then
                           StartLevel:= 1
                        End;

                     3: If Difficulty = DIFFICULTY_LEVELS Then
                        Difficulty:= 1
                     Else
                         Inc(Difficulty);
                     End;
                  End;

           end;

     Until Keydown[SCANCODE_ENTER] or Keydown[SCANCODE_SPACE];
     UnHookKeyboardInt;

     { Restore previous window dimensions }

     SetWindowEx(WndRect);

     FreeShape(pArrowImg);
     FreeShape(pTileImg);

     FreeBitmap(pGameSelBmp);
     FreeBitmap(pScratchBmp);
end;


begin
     Writeln('BOULDERDASH GAME SELECT ROUTINES');
     Writeln(' (C) 1999 Scott Tunstall.');
     Writeln('This unit is FREEWARE. Please distribute source/compiled code');
     Writeln('freely in it''s original, unaltered state.');
     Writeln;
end.