Unit Titlescreen;

uses kojakvga, nwkbdint, crt;


interface

Procedure TitleScreen;




implementation


{ Display the title screen,
  which makes rockford tap his foot etc. }


Procedure TitleScreen;
var
     IntroScreenPtr: pointer;
     IntroScreenPalette:
     FootDelay: byte;
     CountDownBeforeDemo: word;


Begin
     IntroScreenPtr:=New64KBitmap;
     UseBitmap(IntroScreenPtr);
     LoadPCX('Introscn.pcx', IntroScreenPalette);


     InitVGAMode;
     SetWindow(0,0,319,199);

     UsePalette (IntroScreenPalette);
     UseBitmap  (VGA_ADDR);

     CountDownBeforeDemo:=300;
     FootDelay:=10;

     repeat
           { Wait 5 vertical blanks: (72 VBLs = 1 sec) }

           vwait(5);
           ShowAllBitmap(IntroScreenPtr);

           { Do we tap foot or not ? }

           Dec(FootDelay);
           if FootDelay <5 Then         { Yep }
           Begin
              Block(101,125,FootDownPtr^);
              if FootDelay = 0 Then FootDelay:=10;
           End;


           { Blink ? }

           if random(20) = 4 Then
              Block(79,40, BlinkPtr^);

           { Make the diamond rockford's holding shine }

           if random(20) = 5  Then
              Block(134,62, DiamondFlashPtr^);


           Dec(CountDownBeforeDemo);
           if CountDownBeforeDemo = 0 Then
              Begin
              DemoDataIndx:=1;
              DemoDir:=Standing;
              ResetGameValues(OnePlayer);
              LoadCaveFromFile('demo.MAP', PlayField);
              PlayGame(demo);

              InitVGAMode;
              SetWindow(0,0,319,199);

              UsePalette (IntroScreenPalette);
              UseBitmap  (VGA_ADDR);

              CountDownBeforeDemo:=300;
              FootDelay:=10;
              End;


     until keypressed;
     readkey;

     FreeBitmap(IntroScreenPtr);
End;




begin

end.

















{ ********************************************************************

  LEVEL EDITOR

  This can import Boulderoid caves for use with Boulderdash.


  ********************************************************************

}











