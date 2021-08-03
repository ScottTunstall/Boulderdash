{
FILENAME: BLDTITLE.PAS

AUTHOR  : SCOTT TUNSTALL

DATE    : 5/3/1999

PURPOSE : IMPLEMENTATION OF THE BOULDERDASH TITLE PAGE.

NOTES   : I have moved the non game parts into self contained units
          which IMHO is a much better approach.

          Also look at the Hungarian notation I have applied :)

}




Unit BldTitle;




interface


type EndTitleTypes = (eTimeOutExpired, eContinue, eEscapePressed);


Function ShowTitle(timeout: word) : EndTitleTypes;


implementation

uses kojakvga, nwkbdint, crt;



{ ================================================================

  Display the title screen, which makes rockford tap his foot etc.

  Expects: Timeout specifies how long the title page should last,
           expressed <timeout> * 5 VBLs.

  Returns: FALSE if no key pressed.

}


Function ShowTitle(timeout: word) : EndTitleTypes;
const FootDelayLatch = 10;

var
     pRockFordBmp:              pointer;
     IntroScreenPalette:        PaletteType;
     pBlinkImg:                 pointer;
     pFootDownImg:              pointer;
     pDiamondFlashImg:          pointer;
     FootDelay:                 byte;
     IsKeyPressed:              boolean;
     TheKeyPressed:             char;

Begin
     { Load Bitmaps }

     pRockFordBmp:=New64KBitmap;
     UseBitmap(pRockFordBmp);
     SetWindow(0,0,319,199);
     LoadPCX('Introscn.pcx', IntroScreenPalette);

     { Now load sprites }

     LoadShape('blink.img', pBlinkImg);
     LoadShape('footdown.img', pFootDownImg);
     LoadShape('dflash.img', pDiamondFlashImg);


     { set graphics display mode & colours }

     InitVGAMode;
     UsePalette (IntroScreenPalette);
     UseBitmap  (VGA_ADDR);



     FootDelay:=FootDelayLatch;

     repeat
           { Wait 5 vertical blanks: (72 VBLs = 1 sec) }

           vwait(5);
           ShowAllBitmap(pRockFordBmp);

           { Do we tap foot or not ? }

           Dec(FootDelay);
           if FootDelay <5 Then         { Yep }
           Begin
              Block(101,125,pFootDownImg^);
              if FootDelay = 0 Then FootDelay:=FootDelayLatch;
           End;


           { Blink ? }

           if random(20) = 4 Then
              Block(79,40, pBlinkImg^);

           { Make the diamond rockford's holding shine }

           if random(20) = 5  Then
              Block(134,62, pDiamondFlashImg^);

           Dec(timeout);

           IsKeyPressed:=keypressed;

     until (timeout = 0) or IsKeypressed;

     { reason for exiting... free memory we allocated }

     FreeShape(pBlinkImg);
     FreeShape(pFootDownImg);
     FreeShape(pDiamondFlashImg);
     FreeBitmap(pRockFordBmp);

     if isKeyPressed Then
        begin
        TheKeyPressed:=ReadKey;
        if TheKeyPressed=#27 Then
           ShowTitle:=eEscapePressed
        else
            ShowTitle:=eContinue;
        end
     else
         ShowTitle:=eTimeOutExpired;

End;








begin

end.

















{ ********************************************************************

  LEVEL EDITOR

  This can import Boulderoid caves for use with Boulderdash.


  ********************************************************************

}












{
select start level, difficulty etc.
}

procedure GameSelect( var TheGameType: GameTypes;
                      var StartLevel, GameDifficulty: byte);
var
    { Tile movement/ blit vars }
    yoffset: integer;
    across : word;
    down   : word;

    { BDAdviseFont vars }
    w, h   : byte;

    ArrowItem: byte;
    ArrowDelay: byte;

    Player1HighScoreStr,
    Player2HighScoreStr: string[8];

begin


     InitVGAMode;

     { Scratchpad will be our back buffer }

     UseBitmap(ScratchPad);
     { Define clipping region so that our tiles won't overwrite wall
       at edge of screen }

     SetWindow(8,8,311,191);

     Cls;

     UsePalette(GameSelectScreenPalette);
     UseFont(StandardVGAFont);

     { Advise boulderdash unit where our font & bitmap is }

     BDAdviseBitmap(GetUsedBitmapAddr);
     GetCurrentFontSize(w,h);
     BDAdviseFont(GetUsedFontAddr,w,h);


     HookKeyboardInt;

     yoffset:=0;
     ArrowItem:=1;
     ArrowDelay:=10;

     str(Player1HiScore:7, Player1HighScoreStr);
     str(Player2HiScore:7, Player2HighScoreStr);

     Repeat
           { Draw clipped tiles at top of window }

           For across:=0 to 18 do
               ClipBlock(across SHL 4,yoffset,BlueTilePtr^);

           For down:=0 to 10 do
               For across:=0 to 18 do
                   Block(across SHL 4,yoffset+16+(down * 16), BlueTilePtr^);

           { And tiles at bottom of window }

           For across:=0 to 18 do
               ClipBlock(across SHL 4,yoffset+192,BlueTilePtr^);

           CopyMaskedBitmap(GameSelectScreenPtr, ScratchPad);

           Case GameType of
           OnePlayer     : BDPrintAt(64,33,'1',1);
           TwoPlayerCoop : Begin
                           BDPrintAt(64,33,'2',1);
                           BDPrintAt(64,41,'CO-OP',10);
                           End;
           TwoPlayerCompetitive : Begin
                                  BDPrintAt(64,33,'2',1);
                                  BDPrintAt(64,41,'VS MODE',10);
                                  End;
           End;

           BDPrintAt(196,89,chr(64+StartLevel),10);
           BDPrintAt(196,97,chr(48+Difficulty),10);


           BDPrintAt(32,161,Player1HighScoreStr,1);
           BDPrintAt(152,161,Player2HighScoreStr,1);



           { Should we blit option highlight arrow or not ? }

           Dec(ArrowDelay);
           if ArrowDelay < 5 Then
              Begin
              Case ArrowItem Of
              1: Blit(184,24,ArrowPtr^);
              2: Blit(208,80,ArrowPtr^);
              3: Blit(208,88,ArrowPtr^);
              End;


              If ArrowDelay = 0 Then
                 ArrowDelay:=10;
              End;


           { Now transfer the back buffer to the main screen }

           Vwait(3);
           ShowAllBitmap(ScratchPad);

           dec(yoffset);
           if yoffset = -16 then yoffset:=0;


           { Handle cursor key presses }


           if ArrowDelay MOD 3=0 Then
              Begin

              { Cursor up ? }


              if keydown[Player1UpKey] or keydown[Player2UpKey] Then
                 begin
                 if Arrowitem = 1 Then
                    ArrowItem:= 3
                 else
                     dec(ArrowItem);
                 end
              else
                  { Cursor down ? }

                  if keydown[Player1DownKey] or keydown[Player2DownKey] Then
                     begin
                     if ArrowItem = 3 Then
                        ArrowItem:= 1
                     else
                         inc(ArrowItem);
                     end;



              { Cursor left ? }

              if keydown[Player1LeftKey] or Keydown[Player2LeftKey] Then
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

                  if keydown[Player1RightKey] or keydown[Player2RightKey] Then
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

     Until Keydown[Player1DigKey] or Keydown[Player2DigKey];
     UnHookKeyboardInt;

     SetWindow(0,0,319,199);
end;