{
PROGRAM  : BOULDERDASH! A 2 player PC version of the C64 classic
           Rockford's riot.

FILENAME : DEFS.INC

AUTHOR   : SCOTT TUNSTALL B.Sc

EMAIL    : TUNSTALS@EMAIL.MSN.COM
           TUNSTALS@HOTMAIL.COM

CREATION : 20TH AUGUST 1998
DATE


NOTES    : THIS IS THE INCLUDE FILE FOR BOULDER.PAS WHICH DEFINES
           ANIMATIONS, TYPEDEFS ETC.

}


{$ifndef BOULDER_ANIMS_H}
{$define BOULDER_ANIMS_H}



{ Define sprite positions within an "image array".
  You have to make the images pos relative because you may want to add
  more animation frames.. not that I will ;) }



Const
      { Non animated stuff }

      { Earth }

      EarthMaxShapes = 1;
      Earth1             = 1;


      { Empty space }

      EmptyMaxShapes = 1;
      Empty1             = Earth1 +1;




      { Animated stuff }

{ Player 1 frame info }

{      p1maxshapes       = 3; }                   { 3 shapes either dir }
      p1walkleftframes  = 4;
      p1walkrightframes = p1walkleftframes;
      p1blinkframes     = 3;
      p1standframes     = 1;
      p1markerframes    = 1;

      p1numdirections   = 2;                    { left & right }

      p1stand           = Empty1+1;
      p1walkleft1       = p1stand+1;
      p1walkleft2       = p1walkleft1+1;
      p1walkleft3       = p1walkleft2+1;
      p1walkright1      = p1walkleft3+1;
      p1walkright2      = p1walkright1+1;
      p1walkright3      = p1walkright2+1;
      p1blink1          = p1walkright3+1;
      p1blink2          = p1blink1+1;
      p1marker          = p1blink2+1;


{ Animation sequences }

      p1leftseq: array[1..p1walkleftframes] of byte =
      (p1walkleft1, p1walkleft2, p1walkleft3, p1walkleft2);
      p1rightseq: array[1..p1walkrightframes] of byte =
      (p1walkright1, p1walkright2, p1walkright3, p1walkright2);
      p1blinkseq: array[1..p1blinkframes] of byte =
      (p1blink1, p1blink2, p1blink1);




{ Player 2 frame info }

      p2maxshapes       = 3;
      p2numdirections   = 2;                    { left & right }

      p2walkleftframes  = 4;
      p2walkrightframes = p2walkleftframes;
      p2blinkframes     = 3;
      p2standframes     = 1;
      p2markerframes    = 1;


{ Player 2 animation sequences }

      p2stand           = p1marker+1;
      p2walkleft1       = p2stand+1;
      p2walkleft2       = p2walkleft1+1;
      p2walkleft3       = p2walkleft2+1;
      p2walkright1      = p2walkleft3+1;
      p2walkright2      = p2walkright1+1;
      p2walkright3      = p2walkright2+1;
      p2blink1          = p2walkright3+1;
      p2blink2          = p2blink1+1;
      p2marker          = p2blink2+1;


      p2leftseq: array[1..p2walkleftframes] of byte =
      (p2walkleft1, p2walkleft2, p2walkleft3, p2walkleft1);
      p2rightseq: array[1..p2walkrightframes] of byte =
      (p2walkright1, p2walkright2, p2walkright3, p2walkright2);
      p2blinkseq: array[1..p2blinkframes] of byte =
      (p2blink1, p2blink2, p2blink1);



      { Non moving Rockford }


      rockford1          = p2marker+1;


      { Diamond }

      diamondmaxshapes = 5;
      diamondframes = 5;

      diamondstrobe1    = rockford1 +1;
      diamondstrobe2    = diamondstrobe1 + 1;
      diamondstrobe3    = diamondstrobe2 + 1;
      diamondstrobe4    = diamondstrobe3 + 1;
      diamondstrobe5    = diamondstrobe4 + 1;

      diamondseq: array[1..diamondframes] of byte =
      (diamondstrobe1, diamondstrobe2, diamondstrobe3,
      diamondstrobe4, diamondstrobe5);


      { Butterfly }

      bflymaxshapes     = 3;
      bflyframes        = 8;

      bflyflap1         = diamondstrobe5+1;
      bflyflap2         = bflyflap1+1;
      bflyflap3         = bflyflap2+1;

      bflyseq: array[1..bflyframes] of byte =
      (bflyflap3, bflyflap3, bflyflap2,bflyflap1, bflyflap1,bflyflap2, bflyflap3, bflyflap3);

      fflymaxshapes     = 4;
      fflyframes        = 4;
      fflyflap1         = bflyflap3+1;
      fflyflap2         = fflyflap1+1;
      fflyflap3         = fflyflap2+1;
      fflyflap4         = fflyflap3+1;

      fflyseq: array[1..fflyframes] of byte =
      (fflyflap1, fflyflap2, fflyflap3, fflyflap4);



      { Amoeba }
      Amoebamaxshapes   = 4;
      Amoebaframes      = 4;

      Amoebawibble1     = fflyflap4+1;          { Well the wall does wibble! }
      Amoebawibble2     = Amoebawibble1+1;
      Amoebawibble3     = Amoebawibble2+1;
      Amoebawibble4     = Amoebawibble3+1;

      AmoebaSeq: array[1..Amoebaframes] of byte =
      (Amoebawibble1, Amoebawibble2, Amoebawibble3, Amoebawibble4);


      { Permeable wall }

      Permwallmaxshapes = 4;
      Permwallframes    = 4;

      Permwallwibble1   = Amoebawibble4+1;
      Permwallwibble2   = Permwallwibble1+1;
      Permwallwibble3   = Permwallwibble2+1;
      Permwallwibble4   = Permwallwibble3+1;

      PermwallSeq: array[1..Permwallframes] of byte =
      (Permwallwibble1, Permwallwibble2, Permwallwibble3, Permwallwibble4);


      { Magic wall }

      Mgcwallmaxshapes  = 4;
      Mgcwallframes    = 4;

      MgcWallStrobe1    = Permwallwibble4+1;
      MgcWallStrobe2    = MgcWallStrobe1 +1;
      MgcWallStrobe3    = MgcWallStrobe2 +1;
      MgcWallStrobe4    = MgcWallStrobe3 +1;

      MgcWallSeq: array[1..Mgcwallframes] of byte =
      (MgcWallStrobe1,MgcWallStrobe2,MgcWallStrobe3, MgcWallStrobe4);

      { Titanium wall }

      Titaniummaxshapes = 1;
      VisibleExitFrames = 2;
      TitaniumWall1     = MgcWallStrobe4 + 1;

      { Flashing exit sequence, which uses the titanium wall shape }

      VisibleExitSeq: array[1..VisibleExitFrames] of byte =
      (TitaniumWall1, Empty1);


      { Normal / Expanding wall }

      NormalWallmaxshapes = 1;
      NormalWall1       = TitaniumWall1+1;


      BoulderMaxShapes = 1;
      Boulder1         = NormalWall1 + 1;

      { Explosion }

      ExplosionMaxShapes = 3;
      Explosion1         = Boulder1+1;
      Explosion2         = Explosion1+1;
      Explosion3         = Explosion2+1;

      { NB: There's no anim sequence for the explosion because it doesn't
        cycle and also because there can be many different stages of
        an explosion on screen, in different areas. }






      { Now calculate how many anim frames in total, so we can reserve
        RAM for all the image pointers required }

      NumAnimFrames    =( EarthMaxShapes+
                          EmptyMaxShapes+
                          p1walkleftframes +
                          p1walkrightframes +
                          p1blinkframes+
                          p1standframes+
                          p1markerframes+
                          p2walkleftframes +
                          p2walkrightframes +
                          p2blinkframes+
                          p1standframes+
                          p1markerframes+
                          diamondmaxshapes +
                          bflymaxshapes +
                          fflymaxshapes +
                          Amoebamaxshapes +
                          Permwallmaxshapes +
                          Mgcwallmaxshapes +
                          Titaniummaxshapes +
                          NormalWallmaxshapes +
                          BoulderMaxShapes +
                          Explosionmaxshapes+
                          1 { For the standing still rockford });


      { Animation delays for animated objects :)
        On a scale from 1 to 10, 1 = extremely fast anim }

      PlayerAnimDelay      = 9;
      FFlyAnimDelay        = 8;
      BFlyAnimDelay        = 6;
      DiamondAnimDelay     = 5;
      MgcWallAnimDelay     = 4;
      AmoebaAnimDelay      = 7;
      PermWallAnimDelay    = 7;
      VisibleExitAnimDelay = 20;


      { Demo data }

      DemoData: array [1..64] of byte = (
                 $FF,$FF,$1E,$77,$2D,$97,$4F,$2D,$47,$3E,$1B,$4F,$1E,$B7,$1D,$27,
                 $4F,$6D,$17,$4D,$3B,$4F,$1D,$1B,$47,$3B,$4F,$4E,$5B,$3E,$5B,$4D,
                 $3B,$5F,$3E,$AB,$1E,$3B,$1D,$6B,$4D,$17,$4F,$3D,$47,$4D,$4B,$2E,
                 $27,$3E,$A7,$A7,$1D,$47,$1D,$47,$2D,$5F,$57,$4E,$57,$6F,$1D,$00);



type actors = (
                player1, player2, rockford,
                boulder, fallingboulder,
                diamond, fallingdiamond,
                amoeba, permwall, magicwall,
                fireflyup, fireflydown,
                fireflyleft, fireflyright,
                butterflyup, butterflydown,
                butterflyleft, butterflyright,
                titaniumwall, normalwall,
                expandingwall, earth,
                visiblelevelexit, invisiblelevelexit,
                empty,

                { And now the "strange" actor types }

                { Keep p1appearing1..p1appearing8 TOGETHER.
                  They are used in a case <range> statement!

                  Do NOT insert any types between them.
                  Same for p2appearing1..p2appearing8
                }

                p1appearing1,p1appearing2,
                p1appearing3,p1appearing4,
                p1appearing5,p1appearing6,
                p1appearing7,p1appearing8,
                p1appearing9,

                p2appearing1,p2appearing2,
                p2appearing3,p2appearing4,
                p2appearing5,p2appearing6,
                p2appearing7,p2appearing8,
                p2appearing9,

                explosionstage1, explosionstage2,
                explosionstage3, explosionstage4,
                explosionstage5
                );




const actor_handled = $80; { When ORed with the ordinal value of an actor,
                             this instructs UpdateObjects to ignore the
                             actor because he has already been handled }




type PlayerAnims = (MovingLeft, MovingRight, MovingUp {Unused},
                    MovingDown {Unused}, Standing, Blinking);


{$endif}