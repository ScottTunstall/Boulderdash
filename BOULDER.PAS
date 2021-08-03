{
**************************************************************************

PROGRAM  : BOULDERDASH! A 2 player PC version of the C64 classic
           Rockford's riot.

FILENAME : BOULDER.PAS

AUTHOR   : SCOTT TUNSTALL B.Sc (AKA LIEUTENANT KOJAK)

EMAIL    : TUNSTALS@EMAIL.MSN.COM
           TUNSTALS@HOTMAIL.COM

CREATION : 4TH SEPTEMBER 1998
DATE

UPDATED  : 5TH MARCH 1999
           18TH APRIL 1999

NOTES    : BOULDER DASH (With C64 graphics!)
           (C) 1985 Peter Liepa / First Star Software
           (C) 1999 Peter Liepa / S. Tunstall

           I'm writing this ENTIRELY in Turbo Pascal because, to be quite
           honest I couldn't be arsed writing it all in assembler.
           If I find that the game is too slow on a P90 then I may
           reconsider my actions.

           The code is NOT by any means what you'd call "pretty". I've
           optimised as far as I can within Turbo Pascal's limits, and
           everything is procedural.

           For 5th March 99 revision, I moved all non game stuff into
           Units so that I could integrate with the forthcoming
           construction kit.

           For 18th April 99 revision, I added more comments, and
           key define routine.



           DEFAULT KEYS:

           Player 1:

           W = Up
           X = Down
           A = Left
           D = Right
           SPACE = Dig


           Player 2 (and also used on option screens, press ENTER to
           select option)

           Cursor keys to move
           Enter to dig



           Press ESC at title page to abort
           Press F1 for player 1 to commit suicide during game
           Press F12 for player 2 to commit suicide

           Press CTRL + END to abort game during play.




CREDITS  : Svend Christiansen, for his help with general gameplay and
           graphics (supplying bitmaps for the animation sequences)

           Andy Jefferies for hosting this game on his web site:

                www.kwikrite.clara.net/boulderdash


           Peter BroadRibb for the * SUPERLATIVE * boulderdash info,
           which even covers C64 SID waveforms and demo data!

           Get it from:

           http://www.stack.nl/~ep/sp/peterb/


           Sheena Drummond for being my girlfriend and forcing me on ;)


           And last, but not least...
           EVERYONE who requested a copy of the game!

           Much respect is due!



LEGAL    : This game and source is FREEWARE. You are NOT allowed to
           sell this game nor any part/ whole of this source for profit.

           You may extract portions of the code but YOU MUST send
           me any alterations or updates that you intend to release
           into the public domain.

           You MAY NOT use any part of the source to produce a new
           program which you intend to sell for profit.




SYSTEM REQUIREMENTS:
--------------------

KOJAKVGA unit, version 3.6
NWKBDINT unit, present in SWAG's June 1996 KEYBOARD.SWG -  SCOTT TUNSTALL
BOULDMSC unit

Pentium 90 or faster recommended for fast gameplay.

VGA adaptor
Turbo Pascal 7



**************************************************************************
}


Program BDASH;

Uses KOJAKVGA,
     BldLdGfx,
     BldTitle,
     BldOpts,
     BldGmSel,
     BldInput,
     BldCave,
     BldCaves,
     BldCam,
     Bouldmsc,
     crt;


{$I types.inc }
{$I anims.inc }
{$I colours.inc }




{$DEFINE DEBUG}





{ Globals }

Var

        pScratchBmp     : pointer;

{ Main game, non-PlayField graphics }


        { Main game, non PlayField shapes }

        g_pPlayer1Panel      : pointer;
        g_pPlayer2Panel      : pointer;



{ stuff that applies to both players }

        g_eGameMode           : GameModes;
        g_ctGameType          : byte;
        g_PlayerViewWidth     : byte;   { Size of player screen(s) in blocks }
        g_cPlayerViewHeight   : byte;
        g_cSharedDiamondCount : byte;   { If in Coop mode, total of player
                                          one's diamonds & player 2's }
        g_bEnoughDiamonds        : boolean;


{ PlayField details }
        g_PlayField           : PlayFieldType;
        g_cCaveInfoStruct     : CaveInfoStruct;

        TickCount             : byte;

        g_bHasMagicWallCycled : boolean;       { Magic wall cycled before? }
        g_bMagicWallCycling   : boolean;       { Is magic wall cycling? }
        g_cAmoebaGrowthCount  : byte;


        g_cCurrentCave        : byte;
        g_cDifficulty         : byte;
        g_cCaveDelayCount     : byte;          { Counts up to g_cCaveInfoStruct.CaveDelay.
                                                   When g_cCaveDelayCount =
                                                   g_cCaveInfoStruct.CaveDelay, all objects
                                                   can move }


{ Player 1 specific }

        g_bIsPlayer1Alive        : boolean; { Can player one move? }
        g_cPlayer1X              : byte;
        g_cPlayer1Y              : byte;
        g_bPlayer1Appeared       : boolean; { On screen yet ? }
        g_cPlayer1Lives          : byte;    { Number of lives player one has }
        g_lPlayer1HiScore        : longint;
        g_lPlayer1Score          : longint;        { Current score }
        g_ePlayer1Anim           : PlayerAnims;    { Player 1 direction }
        g_ePlayer1LastAnim       : PlayerAnims;
        g_iPlayer1CameraX        : integer;
        g_iPlayer1CameraY        : integer;
        g_iPlayer1DestCameraX    : integer;
        g_iPlayer1DestCameraY    : integer;
        g_cPlayer1Diamonds       : byte;          { How many diamonds has the player }
        g_bPlayer1CompletedLevel : boolean;



{ Player 2 specific }

        g_cPlayer2X              : byte;
        g_cPlayer2Y              : byte;
        g_bIsPlayer2Alive        : boolean;
        g_bPlayer2Appeared       : boolean;
        g_cPlayer2Lives          : byte;    { Number of lives player two has }
        g_lPlayer2HiScore        : longint;
        g_lPlayer2Score          : longint;
        g_ePlayer2Anim           : PlayerAnims;
        g_ePlayer2LastAnim       : PlayerAnims;
        g_iPlayer2CameraX        : integer;
        g_iPlayer2CameraY        : integer;
        g_iPlayer2DestCameraX    : integer;
        g_iPlayer2DestCameraY    : integer;
        g_cPlayer2Diamonds       : byte;
        g_bPlayer2CompletedLevel : boolean;


{ Demo information }

        g_cDemoDataIndx          : byte;
        g_cDemoMoveCount         : byte;
        g_eDemoDirection         : PlayerAnims;


{ Animation details }
        g_cPlayer1AnimIndex        : byte;          { offsets into an anim seq }
        g_cPlayer1AnimCount        : byte;          { When it counts up to g_ePlayer1AnimSpeed,
                                                   move to the next anim frame }

        g_cPlayer2AnimIndex        : byte;
        g_cPlayer2AnimCount        : byte;

        g_cFFlyAnimIndex           : byte;
        g_cFFlyAnimCount           : byte;

        g_cBFlyAnimIndex           : byte;
        g_cBFlyAnimCount           : byte;

        g_cDiamondAnimIndex        : byte;
        g_cDiamondAnimCount        : byte;

        g_cMgcWallAnimIndex        : byte;
        g_cMgcWallAnimCount        : byte;

        g_cAmoebaAnimIndex         : byte;
        g_cAmoebaAnimCount         : byte;

        g_cPermWallAnimIndex       : byte;
        g_cPermWallAnimCount       : byte;

        g_cVisibleExitAnimIndex    : byte;
        g_cVisibleExitAnimCount    : byte;




{
********************************************************************


 PROCEDURE SECTION


********************************************************************
}








{
=================================================================

Called before starting a cave..

Reset all animation and player related stuff (except life counts)

-----------------------------------------------------------------
}


procedure OnStartCave;
begin
     { Cave & Animation stuff first }

     g_cCaveDelayCount:=1;
     TickCount:=1;

     g_cPlayer1AnimIndex:=1;
     g_cPlayer1AnimCount:=1;

     g_cPlayer2AnimIndex:=1;
     g_cPlayer2AnimCount:=1;

     g_cFFlyAnimIndex:=1;
     g_cFFlyAnimCount:=1;

     g_cBFlyAnimIndex:=1;
     g_cBFlyAnimCount:=1;

     g_cDiamondAnimIndex:=1;
     g_cDiamondAnimCount:=1;

     g_bHasMagicWallCycled:=false;
     g_bMagicWallCycling:=false;
     g_cMgcWallAnimIndex:=1;
     g_cMgcWallAnimCount:=1;

     g_cAmoebaAnimIndex:=1;
     g_cAmoebaAnimCount:=1;
     g_cAmoebaGrowthCount:=1;

     g_cPermWallAnimIndex:=1;
     g_cPermWallAnimCount:=1;

     g_cVisibleExitAnimIndex:=1;
     g_cVisibleExitAnimCount:=1;


     { Now player stuff }

     g_cSharedDiamondCount:=0;
     g_bEnoughDiamonds:=false;

     g_bPlayer1Appeared:=false;
     g_lPlayer1Score:=0;
     g_ePlayer1Anim:=Standing;
     g_ePlayer1LastAnim:=MovingLeft;
     g_cPlayer1Diamonds:=0;
     g_bPlayer1CompletedLevel:=false;


     if g_ctGameType <> OnePlayer Then
        Begin
        g_bPlayer2Appeared:=false;
        g_lPlayer2Score:=0;
        g_ePlayer2Anim:=Standing;
        g_ePlayer2LastAnim:=MovingLeft;
        g_cPlayer2Diamonds:=0;
        g_bPlayer2CompletedLevel:=false;
        End;


end;





{
==============================================

Draw area of cave depicted at CameraX, CameraY

----------------------------------------------
}


procedure DrawPlayerCaveArea( Player: byte;
                              IsPlayerAlive: boolean;
                              CameraX,
                              CameraY: integer);


var CameraXinblocks: byte;
    CameraYinblocks: byte;
    PixelXOffset   : byte;
    PixelYOffset  : byte;


    across         : integer;
    down           : integer;
    shape          : byte;

    HighLightNdx   : byte;
    HighLightX     : integer;
    HighLightY     : integer;


    temp           : integer;

begin

     { For smooth scroll }

     CameraXinblocks:= CameraX SHR 4;   { Divide X coord by 16 }
     CameraYinblocks:= CameraY SHR 4;   { Ditto with Y }
     PixelXOffset:=16-(CameraX and $0f);
     PixelYOffset:=16-(CameraY and $0f);



     for down:=0 to g_cPlayerViewHeight do
         for across:= 0 to g_PlayerViewWidth do
             begin

             case (g_PlayField[ CameraXinblocks+across,
                              CameraYinblocks+down] and $7F) of

             { The most common elements of a cave,
               hence most likely to be blitted,
               go first in the case statement}

             ord(empty): shape:=Empty1;
             ord(earth): shape:=Earth1;

             ord(player1): begin
                           case g_ePlayer1Anim of
                           standing : shape:= p1stand;

                           MovingLeft    : shape:=
                                           p1leftseq[g_cPlayer1AnimIndex];
                           MovingRight   : shape:=
                                           p1rightseq[g_cPlayer1AnimIndex];
                           Blinking      : shape:=
                                           p1blinkseq[g_cPlayer1AnimIndex];

                           end;

                           if (g_ctGameType<> OnePlayer) And (Player = 1) Then
                              Begin
                              HighlightNdx:=p1Marker;
                              HighlightX:=pixelxoffset+(across SHL 4)-16;
                              HighlightY:=pixelyoffset+(down SHL 4)-32;
                              End;

                           end;


             ord(player2): begin
                           case g_ePlayer2Anim of
                           standing : shape:= p2stand;
                           MovingLeft    : shape:=
                                           p2leftseq[g_cPlayer2AnimIndex];
                           MovingRight   : shape:=
                                           p2rightseq[g_cPlayer2AnimIndex];
                           Blinking      : shape:=
                                           p2blinkseq[g_cPlayer2AnimIndex];

                           end;

                           if Player = 2 Then
                              Begin
                              HighlightNdx:=p2Marker;
                              HighlightX:=pixelxoffset+(across SHL 4)-16;
                              HighlightY:=pixelyoffset+(down SHL 4)-32;
                              End;
                           end;


             ord(rockford): shape:=rockford1;

             ord(diamond),
             ord(FallingDiamond): shape:= DiamondSeq[g_cDiamondAnimIndex];

             ord(boulder),
             ord(fallingboulder): shape:= boulder1;


             ord(fireflyup),
             ord(fireflydown),
             ord(fireflyleft),
             ord(fireflyright): shape:= FFlySeq[g_cFFlyAnimIndex];

             ord(butterflyup),
             ord(butterflydown),
             ord(butterflyleft),
             ord(butterflyright): shape:= BFlySeq[g_cBFlyAnimIndex];

             ord(amoeba): shape:=AmoebaSeq[g_cAmoebaAnimIndex];
             ord(permwall): shape:=PermwallSeq[g_cPermWallAnimIndex];
             ord(magicwall): if g_bMagicwallcycling then
                                shape:=MgcWallSeq[g_cMgcWallAnimIndex]
                             else
                                 shape:=NormalWall1;

             ord(titaniumwall),
             ord(invisiblelevelexit) : shape:=TitaniumWall1;
             ord(normalwall),
             ord(expandingwall)      : shape:=NormalWall1;

             ord(visiblelevelexit)   : if g_bEnoughDiamonds
                                       then
                                           shape:=VisibleExitSeq[g_cVisibleExitAnimIndex]
                                       else
                                           shape:=TitaniumWall1;

             ord(Explosionstage1),
             ord(Explosionstage5)    : shape:= Explosion1;
             ord(Explosionstage2),
             ord(Explosionstage4)    : shape:= Explosion2;
             ord(Explosionstage3)    : shape:= Explosion3;

             ord(p1Appearing1),
             ord(p2Appearing1),
             ord(p1Appearing3),
             ord(p2Appearing3)       : shape:=titaniumwall1;

             ord(p1Appearing2),
             ord(p2Appearing2),
             ord(p1Appearing4),
             ord(p2Appearing4)    :   shape:= empty1;

             ord(p1Appearing5),
             ord(p2Appearing5),
             ord(p1Appearing9),
             ord(p2Appearing9)    :   shape:= Explosion1;

             ord(p1Appearing6),
             ord(p2Appearing6),
             ord(p1Appearing8),
             ord(p2Appearing8)    : shape:= Explosion2;

             ord(p1Appearing7),
             ord(p2Appearing7)    : shape:= Explosion3;

             end;

             { Now put tile on screen, note that window boundaries
               are being taken into account }



             clipblock( pixelxoffset+(across SHL 4)-16,
                        pixelyoffset+(down SHL 4)-16,
                        ShapeList[shape]^);

         end;

         { And now, after all blocks and players have been drawn,
           draw the player highlight marker (which is VERY useful
           in 2 player games when the screen gets busy)
         }

         if (g_ctGameType <> OnePlayer) and IsPlayerAlive Then
         clipblit( HighLightX, HighlightY, ShapeList[HighLightNdx]^);

end;







{
===================================

Is object at x,y indestructible ?

-----------------------------------
}

function Indestructible(x,y: byte): boolean;
begin
     case g_PlayField[x,y] of
     ord(TitaniumWall),
     ord(VisibleLevelExit),
     ord(InVisibleLevelExit),
     ord(p1appearing1)..ord(p1appearing9),
     ord(p1appearing2)..ord(p2appearing9) : Indestructible:=true;
     else
         Indestructible:=false;
     end;
end;






{
========================================================================

Explode into a given object.

Expects: CentreX and CentreY identify the map coordinates for the
         explosion's epicentre :)

         Meaning: Where the middle of the explosion is <g>

         actortoexplode is the actor to fill the 3 x 3 explosion area
         with.

------------------------------------------------------------------------
}

procedure Explode( centrex,
                   centrey: byte;
                   actortoexplode: actors);

var left   : byte;
    top    : byte;
    across : byte;
    down   : byte;


begin
     left:=centrex-1;           { Move to top left of where explosion will be }
     top:=centrey-1;

     for down:=0 to 2 do
         for across:=0 to 2 do
             begin
             case g_PlayField[left+across, top+down] of

             { has rockford "statue" been hit? If so then both players die! }

             ord(rockford): begin
                            Explode( g_cPlayer1X,
                                     g_cPlayer1Y,
                                     ExplosionStage1);

                            If g_bIsPlayer2Alive Then
                               Explode( g_cPlayer2X,
                                        g_cPlayer2Y,
                                        ExplosionStage1);
                            end;

             { has player been caught in the explosion? }

             ord(player1) : g_bIsPlayer1Alive:=false;
             ord(player2) : g_bIsPlayer2Alive:=false;
             end;

             if not Indestructible(left+across, top+down) then
                g_PlayField[left+across, top+down]:=ord(ActorToExplode) or actor_handled;

         end;
end;









{
==========================================================

  Check if an object can move down.

  If the object is already falling then we need to perform
  some checks to see what's beneath it, such as:

  Have we hit player one/two?
  A firefly or butterfly?

----------------------------------------------------------
}



procedure check_movedown( x,
                          y: byte;
                          WhatObjIsFalling,
                          WhatObjIsStill: Actors);

var whats_beneath: byte;
begin
     whats_beneath:=g_PlayField[x,y+1];

     { The most likely scenario }

     if whats_beneath = ord(empty) then
        begin
        g_PlayField[x,y]:=ord(empty);
        g_PlayField[x,y+1]:=ord(WhatObjIsFalling);
        end
     else
         begin
         { We have to halt the object's descent }

         g_PlayField[x,y]:=ord(WhatObjIsStill);
         case g_PlayField[x, y+1] of
              ord(RockFord): begin
                             if g_bIsPlayer1Alive Then
                                Explode( g_cPlayer1X,
                                         g_cPlayer1Y,
                                         ExplosionStage1);

                             if g_bIsPlayer2Alive Then
                                Explode( g_cPlayer2X,
                                         g_cPlayer2Y,
                                         ExplosionStage1);
                             end;


              ord(Player1) : begin
                             Explode(x,y,explosionstage1);
                             end;

              ord(Player2) : begin
                             Explode(x,y,explosionstage1);
                             end;


              ord(FireFlyUp),
              ord(FireFlyDown),
              ord(FireFlyLeft),
              ord(FireFlyRight):   begin
                                   explode(x,y, explosionstage1);

                                   end;

              ord(ButterFlyUp),
              ord(ButterFlyDown),
              ord(ButterFlyLeft),
              ord(ButterFlyRight): begin
                                   Explode(x,y, diamond);

                                   end;
          end;
     end;
end;






{
====================================================

  Can we make an object fall?

  WhatObjIs identifies what the object that may fall
  is currently (e.g. boulder or Diamond)
  and WhatObjBecomes is the "falling" version.

----------------------------------------------------
}


procedure Check_fall( x,
                      y: byte;
                      WhatObjIs,
                      WhatObjBecomes: actors);
var
   whats_beneath: byte;

begin
     whats_beneath:=g_PlayField[x,y+1];

     { magic wall ? }

     if whats_beneath=ord(magicwall) then
        begin
        g_PlayField[x,y]:=ord(empty);

        if not g_bHasmagicwallcycled then
           begin
           {Indicate magic wall has begun cycle}

           g_bMagicwallcycling:=true;

           if (g_PlayField[x,y+2]=ord(empty)) then
           case WhatObjIs of
           diamond: g_PlayField[x,y+2]:=ord(boulder);
           boulder: g_PlayField[x,y+2]:=ord(diamond);
           end;

        exit;
        end;
     end;


     { permeable wall ? }

     if whats_beneath=ord(permwall) then
        begin
        if (random(g_cCaveInfoStruct.m_cSlimePermeability)=1) and
           (g_PlayField[x,y+2] =ord(empty)) then
           begin
           g_PlayField[x,y]:=ord(empty);
           g_PlayField[x,y+2]:=ord(WhatObjIs) or actor_handled;
           exit;
           end;
        end;

     { Nothing below, Straight fall downwards }

     if whats_beneath=ord(empty) then
        begin
        {g_PlayField[x,y]:=ord(Empty); }
        g_PlayField[x,y]:=ord(WhatObjBecomes) or actor_handled;
        exit;
        end;


     { Now, we can only make the object topple off if it is on
       either a normal wall or a boulder, or a diamond. }

     if (whats_beneath <> ord(normalwall))
     and (whats_beneath <> ord(boulder))
     and (whats_beneath <> ord(diamond)) then exit;


     { Otherwise, try and make object topple off to left or right }

     if (g_PlayField[x-1,y]=ord(empty))
     and (g_PlayField[x-1,y+1] = ord(empty)) then
        begin
        g_PlayField[x,y]:=ord(Empty);
        g_PlayField[x-1,y]:=ord(WhatObjIs);
        exit;
        end;

     if (g_PlayField[x+1,y]=ord(empty))
     and (g_PlayField[x+1,y+1] = ord(empty)) then
        begin
        g_PlayField[x,y]:=ord(Empty);
        g_PlayField[x+1,y]:=ord(WhatObjIs) or actor_handled;
        end;
end;







{ ************************************************************************

  MOVE ENEMIES

}





{
======================================================

 Is the character at x,y a rockford, player or amoeba?
 Returns TRUE if yes.


 Used by the firefly and butterfly
 routines.

------------------------------------------------------
}

function IsPlayerOrAmoebaAt( x,
                             y: byte
                             ) : boolean;
begin
     case g_PlayField[x,y] of
     ord(rockford): IsPlayerOrAmoebaAt:=true;
     ord(player1),
     ord(player2),
     ord(amoeba)  : IsPlayerOrAmoebaAt:=true;

     else
         IsPlayerOrAmoebaAt:=false;
     end;
end;








{
======================================================

FireFly and Butterfly move routines call this routine.


Returns TRUE if the firefly/ butterfly in question
did hit a player or amoeba at x,y, AND calls the
explode routine.

------------------------------------------------------
}


function HaveHitPlayerOrAmoebaAt ( x,
                                   y : byte;
                                   ExplodeActor : Actors) : boolean;

var bHaveExploded: boolean;

begin
     { Check squares to left, right, above, below baddy }

     bHaveExploded:=false;
     bHaveExploded:= IsPlayerOrAmoebaAt(X-1, Y) or
                    IsPlayerOrAmoebaAt(X+1, Y) or
                    IsPlayerOrAmoebaAt(X, Y-1) or
                    IsPlayerOrAmoebaAt(X, Y+1);
     if bHaveExploded then
        Explode(x,y, ExplodeActor);

     HaveHitPlayerOrAmoebaAt:=bHaveExploded;
end;











{
==================================================================

Called by the Firefly and butterfly move routines.

Expects: oldx and oldy identify the firefly/butterfly's current
         map position

         newx and newy identify the position on the map where the
         firefly/butterfly is trying to move to.

         ActorToWrite is the actor to put into map[newx,newy]
         should mapx[newx,newy] be empty.

------------------------------------------------------------------
}

function TryMove( oldx,
                  oldy,
                  newX,
                  newY,
                  ActorToWrite: byte
                  ): boolean;

begin

        case g_PlayField[newX, newY] of

        Ord(Empty) : Begin
                     g_PlayField[oldx,oldy]:=ord(Empty);
                     g_PlayField[newx, newy]:=ActorToWrite;
                     TryMove:=true;
                     End;
        else
            TryMove:=false;

        End;
end;






{
  ==============================================================

  BUTTERFLY MOVE ROUTINES

  Butterflies always move to their RIGHT if they can.

  If not then they go straightforward, if that's possible.

  If not straightforward, then to their LEFT, missing a frame.

  If not to their left, then they turn back on themselves,
  again, missing a frame.

  --------------------------------------------------------------
}

procedure MoveButterFlyUp(x,y: byte);
begin
     if not HaveHitPlayerOrAmoebaAt(x,y, Diamond) Then
     Begin
          if not TryMove( x,
                          y,
                          x+1,
                          y,
                          ord(ButterFlyRight) or actor_handled)
                           then
          begin
               if not TryMove( x,
                               y,
                               x,
                               y-1,
                               ord(ButterFlyUp) or actor_handled)
                                then
               begin
                    g_PlayField[x,y]:=ord(ButterFlyLeft);
               end;
          end;
     end;




end;





procedure MoveButterFlyDown(x,y: byte );
begin
     if not HaveHitPlayerOrAmoebaAt(x,y, Diamond) Then
     Begin
          if not TryMove( x,
                          y,
                          x-1,
                          y,
                          ord(ButterFlyLeft))
                           then
          begin
               if not TryMove( x,
                               y,
                               x,
                               y+1,
                               ord(ButterFlyDown))
                               then
               begin
                    g_PlayField[x,y]:=ord(ButterFlyRight);
               end;
          end;

     End;
end;





procedure MoveButterFlyLeft(x,y: byte );
begin
     if not HaveHitPlayerOrAmoebaAt(x,y, Diamond) Then
     Begin
          if not TryMove( x,
                          y,
                          x,
                          y-1,
                          ord(ButterFlyUp) or actor_handled)
                           then
          begin
               if not TryMove( x,
                               y,
                               x-1,
                               y,
                               ord(ButterFlyLeft))
                               then
               begin
                    g_PlayField[x,y]:=ord(ButterFlyDown);
               end;
          end;

     End;
end;




procedure MoveButterFlyRight(x,y:byte);
begin
     if not HaveHitPlayerOrAmoebaAt(x,y, Diamond) Then
     Begin
          if not TryMove( x,
                          y,
                          x,
                          y+1,
                          ord(ButterFlyDown)
                        )
                          then
          begin
               if not TryMove( x,
                               y,
                               x+1,
                               y,
                               ord(ButterFlyRight) or actor_handled
                             )
                             then
               begin
                    g_PlayField[x,y]:=ord(ButterFlyUp);
               end;
          end;

     End;
end;











{
=====================================================

FIREFLY MOVEMENT routines.

The fireflies ALWAYS move LEFT if they can.

If not then they go straightforward, if possible.

If not straightforward, then to their right, but they
miss this frame's movement.

If not to their right, then turn back on themselves,
again missing a frame.

-----------------------------------------------------
}


procedure MoveFireFlyUp(x,y: byte);
begin
     if not HaveHitPlayerOrAmoebaAt(x,y, ExplosionStage1) Then
     Begin
          if not TryMove( x,
                          y,
                          x-1,
                          y,
                          ord(FireFlyLeft))
                          then
          begin
               if not TryMove( x,
                               y,
                               x,
                               y-1,
                               ord(FireFlyUp) or actor_handled)
                               then
               begin
                    g_PlayField[x,y]:=ord(FireFlyRight);
               end;
          end;

     End;

end;





procedure MoveFireFlyDown(x,y: byte );
begin
     if not HaveHitPlayerOrAmoebaAt(x,y, ExplosionStage1) Then
     Begin
          if not TryMove( x,
                          y,
                          x+1,
                          y,
                          ord(FireFlyRight) or actor_handled)
                           then
          begin
               if not TryMove( x,
                               y,
                               x,
                               y+1,
                               ord(FireFlyDown))
                               then
               begin
                    g_PlayField[x,y]:=ord(FireFlyLeft);
               end;
          end;

     End;
end;





procedure MoveFireFlyLeft(x,y: byte );
begin
     if not HaveHitPlayerOrAmoebaAt(x,y, ExplosionStage1) Then
     Begin
          if not TryMove( x,
                          y,
                          x,
                          y+1,
                          ord(FireFlyDown))
                          then
          begin
               if not TryMove( x,
                               y,
                               x-1,
                               y,
                               ord(FireFlyLeft))
                               then
               begin
                    g_PlayField[x,y]:=ord(FireFlyUp);
               end;
          end;

     End;
end;




procedure MoveFireFlyRight(x,y:byte );
begin
     if not HaveHitPlayerOrAmoebaAt(x,y, ExplosionStage1) Then
     Begin
          if not TryMove( x,
                          y,
                          x,
                          y-1,
                          ord(FireFlyUp) or actor_handled)
                          then
          begin
               if not TryMove( x,
                               y,
                               x+1,
                               y,
                               ord(FireFlyRight) or actor_handled)
                               then
               begin
                    g_PlayField[x,y]:=ord(FireFlyDown);
               end;
          end;

     End;
end;








{
 =========================================================================

 Makes the amoeba wibble!!!

 Expects: x and y identify the location of a single amoeba. The amoeba
          will try and grow in a random direction.


 This routine is incomplete, I will have to look at Peter BroadRibb's
 boulderdash spec for details of how Monsieur Liepa did things.

 ------------------------------------------------------------------------
}

procedure wibble(x,y:byte);
var GrowToX: byte;
    GrowToY: byte;

begin
     inc(g_camoebagrowthcount);
     if g_cAmoebagrowthcount = g_cCaveInfoStruct.m_cAmoebaGrowthDelay Then
        begin
        g_cAmoebaGrowthCount:=1;

        growToX:=x;
        growToY:=y;

        Case random(4) of   { Up,down,left,right }
        1: dec(growtoy);
        2: inc(growtoy);
        3: dec(growtox);
        4: inc(growtox);
        End;

        case g_PlayField[growToX, growToY] and $7f of
        ord(empty),
        ord(earth)      : g_PlayField[growToX, growToY]:=ord(amoeba);

        ord(Butterflyup),
        ord(Butterflydown),
        ord(Butterflyleft),
        ord(Butterflyright)  : Explode(growToX, growToY, Diamond);

        ord(FireFlyUp),
        ord(FireFlyDown),
        ord(FireFlyLeft),
        ord(FireFlyRight)    : Explode(growToX, growToY, ExplosionStage1);
        end;
     end;

end;






{
=========================================================================

Update animation frame.

Expects: TheAnimDelay is used to control animation speed. It will count
         up to MaxAnimDelay.

         When TheAnimDelay = MaxAnimDelay, the "Anim Frame Index"
         variable referenced by TheAnimIndex will be incremented.

         Should TheAnimIndex = MaxAnimIndex then that means that the
         "animation sequence" has ended, so the animation must
         start back at "animation frame" 1 again.

-------------------------------------------------------------------------
}

procedure UpdateAnim( var TheAnimDelay: byte;
                      MaxAnimDelay: byte;
                      var TheAnimIndex: byte;
                      MaxAnimIndex: byte);
begin
     inc(TheAnimDelay);
     if TheAnimDelay = MaxAnimDelay Then
        Begin
        TheAnimDelay:=1;
        Inc(TheAnimIndex);
        If TheAnimIndex > MaxAnimIndex Then
           TheAnimIndex:=1;
        End;

end;





{
=========================================================================

Update the player's position in the scheme of things

Expects:   WhichPlayer is the actor to be poke'd into the cave map after
           player has moved

           x,y represents player current position in cave

           Anim represents current player animation (Walking Left,
           Walking right, standing still, blinking)

           LastAnim represents the previous animation. This is used
           when the player blinks or taps his foot and the program
           needs to recall the last directional animation taken by
           the player when he decides to move.

           AnimIndex is the animation index: The "anim frame number"
           so to speak.

           DiamondsCollected is obvious.

           Currscore is the current player score.

           CompletedLevelFlag is set to TRUE if the player has enough
           diamonds and he has reached the exit.

           DoMoveUp, DoMoveDown specify whether or not the player
           has pressed the up key, down key etc.

Returns:   Nothing

------------------------------------------------------------------------
}

procedure UpdatePlayer( WhichPlayer: actors;
                        var x,y: byte;
                        var Anim: PlayerAnims;
                        var LastAnim: PlayerAnims;
                        var AnimIndex: byte;
                        var diamondscollected: byte;
                        var currscore: longint;
                        var CompletedLevelFlag : boolean;
                        DoMoveUp,
                        DoMoveDown,
                        DoMoveLeft,
                        DoMoveRight,
                        DoDig,
                        DoAbort : boolean);

var digx, digy: byte;

begin
     if DoAbort then
     begin
          explode(x,y,explosionstage1);         { Let explode routine
                                                  set the dead flags }
          exit;
     end;

     digx:=x;
     digy:=y;

     if DoMoveUp then
        begin
        dec(digy);
        if Anim in [standing, blinking] then
           begin
           Anim:=LastAnim;
           animindex:=1;                { Back to frame 1 of animation }
           end;
        end
     else
         if DoMoveDown then
            begin
            inc(digy);
            if Anim in [standing, blinking] then
               begin
               Anim:= LastAnim;
               animindex:=1;
               end;
            end

         else
             { Digging left ? }

             if DoMoveLeft then
                begin
                dec(digx);

                { Is player facing left? If not, we'll have to make him }

                if Anim <> MovingLeft then
                   begin
                   Anim:=MovingLeft;
                   LastAnim:=Anim;
                   animIndex:=1;
                   end;
                end
             else
                 if DoMoveRight then
                    begin
                    inc(digx);
                    if Anim <> MovingRight then
                    begin
                         Anim:=MovingRight;
                         LastAnim:=Anim;
                         animIndex:=1;
                    end;
                    end
                 else
                     { No key pressed }

                     begin
                     if(random(40)=1) then
                       begin
                       Anim:=Blinking;
                       animIndex:=1;
                       end
                     else
                         Anim:=Standing;        { Not doing anything :) }
                     exit;
                     end;


        { What has player ran into ? }

        case g_PlayField[digx,digy] of
        ord(earth) : g_PlayField[digx,digy]:=ord(empty);

        ord(VisibleLevelExit),
        ord(InvisiblelevelExit) : if diamondscollected >= g_cCaveInfoStruct.m_cDiamondsNeeded then
                                  begin
                                     CompletedLevelFlag:=true;
                                     g_PlayField[x,y]:=ord(empty);
                                     g_PlayField[digx, digy]:=ord(whichplayer);
                                  end;

        ord(diamond) : begin
                            inc(diamondscollected);
                            inc(g_cSharedDiamondCount);


                            if (g_cSharedDiamondCount < g_cCaveInfoStruct.m_cDiamondsNeeded) then
                               inc(currscore,g_cCaveInfoStruct.m_cDiamondValue)
                            else
                                begin
                                inc(currscore, g_cCaveInfoStruct.m_cBonusDiamondValue);

                                { If we've got enough diamonds, flash the
                                  screen }

                                if not g_bEnoughDiamonds then
                                begin
                                     SetRGB(0,255,255,255);
                                     Vwait(2);
                                     SetRGB(0,0,0,0);
                                     g_bEnoughDiamonds:=true;
                                end;

                                end;

                            g_PlayField[digx,digy]:=ord(empty);
                            end;

        { Push a boulder }

        ord(boulder) : if digy = y then { Can't push up :) }
                          case anim of

                          { We need to make it seem as if Rockford is
                            putting some effort into pushing the boulder,
                            therefore the boulder only moves if random
                            (6) is 1. }

                          MovingLeft : if (random(6)=1) and (g_PlayField[digx-1,y] = ord(empty)) then
                                       begin
                                            g_PlayField[digx-1,y]:=ord(boulder);
                                            g_PlayField[digx,y]:=ord(empty);
                                       end;

                          MovingRight: if (random(6)=1) and (g_PlayField[digx+1,y] = ord(empty)) then
                                       begin
                                            g_PlayField[digx+1,y]:=ord(boulder);
                                            g_PlayField[digx,y]:=ord(empty);
                                       end;
                          end;
        End;


        { if the dig keys not down then we move the player }

        if not DoDig then
           begin
           if (g_PlayField[digx,digy] = ord(earth)) or
              (g_PlayField[digx,digy] = ord(empty)) then
              begin
                   g_PlayField[x,y]:=ord(empty);
                   g_PlayField[digx,digy]:=ord(WhichPlayer);
                   x:=digx;
                   y:=digy;
              end
           end;




end;






{
===============================================================


For the demo's purposes, this fakes the key presses of player 1


---------------------------------------------------------------
}

procedure GetFakeKeyPresses(var TheUpKey,
                                TheDownkey,
                                TheLeftKey,
                                TheRightKey,
                                TheDigKey : boolean);
var MoveInstr: byte;

begin
     TheUpKey:=false;
     TheDownKey:=false;
     TheLeftKey:=false;
     TheRightKey:=false;
     TheDigKey:=false;

     If g_cDemoMoveCount = 0 Then
        Begin
        MoveInstr:=DemoData[g_cDemoDataIndx];
        inc(g_cDemoDataIndx);
        g_cDemoMoveCount:=(MoveInstr AND $F0) SHR 4;

        Case MoveInstr and $F of
        { $7 = Right, $B = Left, $D = Down, $E = Up, $F = no movement }
        $7 : g_eDemoDirection:=MovingRight;
        $B : g_eDemoDirection:=MovingLeft;
        $D : g_eDemoDirection:=MovingDown;
        $E : g_eDemoDirection:=MovingUp;
        $F : g_eDemoDirection:=Standing;
        End;
     End;

     Case g_eDemoDirection of
     MovingLeft: TheLeftKey:=true;
     MovingRight: TheRightKey:=true;
     MovingUp: TheUpKey:=true;
     MovingDown: TheDownKey:=true;
     End;

     Dec(g_cDemoMoveCount);
end;







{
=========================================================================

UPDATE ALL OBJECTS

This routine does the donkey work in updating every object in the game.

Expects:     AllowMove specifies whether the cave denizens are allowed
             to move. If AllowMove is set FALSE, they will not move
             but still animate.

-------------------------------------------------------------------------
}



procedure UpdateObjects(AllowMove: boolean);
var across             : byte;
    down               : byte;
    across2            : byte;
    down2              : byte;
    amoebacount        : byte;

    TempUpKey,
    TempDownKey,
    TempLeftKey,
    TempRightKey,
    TempDigKey         : boolean;


begin
     { Player Animations first }

     if g_bIsPlayer1Alive then
        case g_ePlayer1Anim of
               Blinking     : UpdateAnim( g_cPlayer1AnimCount,
                                          PlayerAnimDelay,
                                          g_cPlayer1AnimIndex,
                                          p1BlinkFrames);
               MovingLeft   : UpdateAnim( g_cPlayer1AnimCount,
                                          PlayerAnimDelay,
                                          g_cPlayer1AnimIndex,
                                          P1WalkLeftFrames);
               MovingRight  : UpdateAnim( g_cPlayer1AnimCount,
                                          PlayerAnimDelay,
                                          g_cPlayer1AnimIndex,
                                          P1WalkRightFrames);
        end;



     if g_bIsPlayer2Alive then

     case g_ePlayer2Anim of
        Blinking     : UpdateAnim( g_cPlayer2AnimCount,
                                   PlayerAnimDelay,
                                   g_cPlayer2AnimIndex,
                                   p2BlinkFrames);

        MovingLeft   : UpdateAnim( g_cPlayer2AnimCount,
                                   PlayerAnimDelay,
                                   g_cPlayer2AnimIndex,
                                   P2WalkLeftFrames);

        MovingRight  : UpdateAnim( g_cPlayer2AnimCount,
                                   PlayerAnimDelay,
                                   g_cPlayer2AnimIndex,
                                   P2WalkRightFrames);
     end;


     { Now other actors }

     UpdateAnim(g_cFFlyAnimCount, FFlyAnimDelay, g_cFFlyAnimIndex, FFlyframes);
     UpdateAnim(g_cBFlyAnimCount, BFlyAnimDelay, g_cBFlyAnimIndex, BFlyframes);
     UpdateAnim(g_cDiamondAnimCount, DiamondAnimDelay, g_cDiamondAnimIndex, Diamondframes);
     UpdateAnim(g_cAmoebaAnimCount, AmoebaAnimDelay, g_cAmoebaAnimIndex, Amoebaframes);
     UpdateAnim(g_cPermWallAnimCount, PermWallAnimDelay, g_cPermWallAnimIndex, PermWallframes);
     UpdateAnim(g_cMgcWallAnimCount, MgcWallAnimDelay, g_cMgcWallAnimIndex, MgcWallframes);


     { Only update exit frames if it's visible in the first place }

     if g_bEnoughDiamonds then
        UpdateAnim( g_cVisibleExitAnimCount,
                    VisibleExitAnimDelay,
                    g_cVisibleExitAnimIndex,
                    VisibleExitFrames);



     { Update the magic wall cycle time }

     if g_bMagicwallcycling then
        begin
        dec(g_cCaveInfoStruct.m_wMagicwallcycletime);
        if g_cCaveInfoStruct.m_wMagicwallcycletime = 0 then
           begin
           g_bHasMagicwallcycled:=true;    { Magic wall can never cycle again }
           g_bMagicwallcycling:=false;     { Stop magic wall cycling }
           end;
        end;



     { Wait Cave Delay cycles before allowing any object movement }

     inc(g_cCaveDelayCount);
     if g_cCaveDelayCount < g_cCaveInfoStruct.m_cCaveDelay Then
        exit;

     g_cCaveDelayCount:=1;


     { Update any explosions. These are animations but are in sync
       with the cave movement delay }

     for down:= g_cCaveInfoStruct.m_cCaveHeight-1 downto 2 do
         for across:= 2 to g_cCaveInfoStruct.m_cCaveWidth-1 do
             begin
             case g_PlayField[across,down] and $7F of
             ord(Explosionstage1)..
             ord(Explosionstage4)  : inc(g_PlayField[across,down]);
             ord(Explosionstage5)  : g_PlayField[across,down]:=ord(empty);
             end;
         end;





     { At this point the animations have been updated. However,
       should we allow the cave denizens to keep on moving?
       If AllowMove is set FALSE, no.
     }


     if not AllowMove Then
        exit;



     { Now move the player (s)- if we disable player1 and player2
       but call updateobjects, this allows the cave
       to continue moving as it did before, meaning this routine
       can be used *after* p1/p2 killed or level completed.

     }

     if (g_bIsPlayer1Alive) And (not g_bPlayer1CompletedLevel) then
        begin
        case g_eGameMode of
        Demo : GetFakeKeyPresses( TempUpKey,
                                  TempDownKey,
                                  TempLeftKey,
                                  TempRightKey,
                                  TempDigKey );
        RealGame: begin
                  TempUpKey:=IsPlayer1UpPressed;
                  TempDownKey:=IsPlayer1DownPressed;
                  TempLeftKey:=IsPlayer1LeftPressed;
                  TempRightKey:=IsPlayer1RightPressed;
                  TempDigKey:=IsPlayer1DigPressed;
                  end;
        end;



        UpdatePlayer( Player1,
                      g_cPlayer1X,
                      g_cPlayer1Y,
                      g_ePlayer1Anim,
                      g_ePlayer2LastAnim,
                      g_cPlayer1AnimIndex,
                      g_cPlayer1Diamonds,
                      g_lPlayer1Score,
                      g_bPlayer1CompletedLevel,
                      TempUpKey,
                      TempDownKey,
                      TempLeftKey,
                      TempRightKey,
                      TempDigKey,
                      IsPlayer1AbortPressed
                      );
        End;

     if g_bIsPlayer2Alive And (not g_bPlayer2CompletedLevel) then
        begin
        UpdatePlayer( Player2,
                      g_cPlayer2X,
                      g_cPlayer2Y,
                      g_ePlayer2Anim,
                      g_ePlayer2LastAnim,
                      g_cPlayer2AnimIndex,
                      g_cPlayer2Diamonds,
                      g_lPlayer2Score,
                      g_bPlayer2CompletedLevel,
                      IsPlayer2UpPressed,
                      IsPlayer2DownPressed,
                      IsPlayer2LeftPressed,
                      IsPlayer2RightPressed,
                      IsPlayer2DigPressed,
                      IsPlayer2AbortPressed);
        end;




     { We know the edges of the walls are titanium, so we can skip
       these blocks }

     amoebacount:=0;
     for down:= g_cCaveInfoStruct.m_cCaveHeight-1 downto 2 do
         for across:= 2 to g_cCaveInfoStruct.m_cCaveWidth-1 do
             begin
             case g_PlayField[across,down] of
             { Remove "object has moved" bit from character }

             $7F..$FF:   g_PlayField[across,down]:=
                         g_PlayField[across,down] and $7F;


             ord(boulder)  : check_fall(across,down, boulder, fallingboulder);
             ord(fallingboulder)   : check_movedown(across,down,fallingboulder, boulder);

             ord(diamond)  : check_fall(across,down,diamond,FallingDiamond);
             ord(FallingDiamond)   : check_movedown(across,down, FallingDiamond, diamond);

             ord(fireflyup)     : movefireflyup(across,down);
             ord(fireflydown)   : movefireflydown(across,down);
             ord(fireflyleft)   : movefireflyleft(across,down);
             ord(fireflyright)  : movefireflyright(across,down);

             ord(butterflyup)   : movebutterflyup(across,down);
             ord(butterflydown) : movebutterflydown(across,down);
             ord(butterflyleft) : movebutterflyleft(across,down);
             ord(butterflyright): movebutterflyright(across,down);


             ord(amoeba)        : begin
                                  inc(amoebacount);

                                  { When 225 amoebas are on screen, they all
                                  turn to boulders }

                                  if amoebacount > 224 then
                                     begin
                                     for down2:= 2 to g_cCaveInfoStruct.m_cCaveHeight- 1 do
                                         for across2:=2 to g_cCaveInfoStruct.m_cCaveWidth-1 do
                                             if g_PlayField[across2,down2] =
                                             ord(amoeba) then
                                             g_PlayField[across2,down2] :=
                                             ord(boulder);
                                     end
                                  else
                                      wibble(across,down);
                                  end;


             ord(expandingwall) : begin
                                  if g_PlayField[across-1,down] = ord(empty) then
                                     g_PlayField[across-1,down]:=
                                     ord(expandingwall)
                                  else
                                      if g_PlayField[across+1,down] = ord(empty) then
                                         g_PlayField[across+1,down]:=
                                         ord(expandingwall) or actor_handled;
                                  end;



             ord(p1Appearing1)..
             ord(p1Appearing8) :   inc(g_PlayField[across,down]);
             ord(p1Appearing9) :   begin
                                   g_PlayField[across,down]:=ord(player1);
                                   g_bPlayer1Appeared:=true;
                                   g_bIsPlayer1Alive:=true;
                                   end;

             ord(p2Appearing1)..
             ord(p2Appearing8) :   inc(g_PlayField[across,down]);
             ord(p2Appearing9) :   begin
                                   g_PlayField[across,down]:=ord(player2);
                                   g_bPlayer2Appeared:=true;
                                   g_bIsPlayer2Alive:=true;
                                   end;

             end;
         end;



end;








{
=====================================

Draw view for player <ThePlayer>

If 0, draw both views at once

-------------------------------------
}


procedure DrawPlayerView(ThePlayer: byte);
var ScreenCentreX: integer;
begin
     ScreenCentreX:=g_PlayerViewWidth SHL 4;


     If ThePlayer in [0,1] Then
     Begin
          SetWindow(0,8,ScreenCentreX-8, 199);
          AdjustCamera( g_cPlayer1X,
                        g_cPlayer1Y,
                        g_iPlayer1CameraX,
                        g_iPlayer1CameraY,
                        g_iPlayer1DestCameraX,
                        g_iPlayer1DestCameraY);

          DrawPlayerCaveArea( 1,
                              g_bIsPlayer1Alive,
                              g_iPlayer1CameraX,
                              g_iPlayer1CameraY);
     End;


     If (ThePlayer in [0,2]) And (g_ctGameType <> OnePlayer) Then
     Begin
         SetWindow(ScreenCentreX+6,8,319,199);
         AdjustCamera( g_cPlayer2X,
                       g_cPlayer2Y,
                       g_iPlayer2CameraX,
                       g_iPlayer2CameraY,
                       g_iPlayer2DestCameraX,
                       g_iPlayer2DestCameraY);

          DrawPlayerCaveArea( 2,
                              g_bIsPlayer2Alive,
                              g_iPlayer2CameraX,
                              g_iPlayer2CameraY);

     end;
end;








{
  ================================================================

  From a random starting point (for both players) scroll the start
  screen(s) into view.


  Expects: Player is player number (1 or 2)
           LivesLeft is obvious

           TheCave is 1..25, and represents the ordinal value
           of alphabetical characters A..Z (not in ASCII, the
           routine will add 64 later)

           TheDifficulty is difficulty level (1..5)

           DestX and DestY represent the area of the cave that
           the camera will scroll to.

  Returns: Nothing


}

procedure ScrollViewToPlayersOrigin(     cPlayer,
                                         cLivesLeft,
                                         cTheCave,
                                         cTheDifficulty,
                                         cDestX,
                                         cDesty: byte;

                                     var riTheCameraX,
                                         riTheCameraY,
                                         riTheDestCameraX,
                                         riTheDestCameraY: integer);

var iStartCameraX: integer;
    iStartCameraY: integer;
    cCount       : byte;
    tempstr     : string[3];
    wTemp        : word;
    cWinmaxY     : byte;
    across      : byte;
    down        : byte;

    yblockofs   : integer;
    uncoveredmap: array[1..MAX_CAVE_WIDTH div 2,1..MAX_CAVE_HEIGHT div 2] of boolean;


begin
     InitialiseCamera( cDestX,
                       cDestY,
                       g_cCaveInfoStruct.m_cCaveWidth,
                       g_cCaveInfoStruct.m_cCaveHeight,
                       g_PlayerViewWidth,
                       g_cPlayerViewHeight,
                       16,
                       16,
                       riTheCameraX,
                       riTheCameraY,
                       riTheDestCameraX,
                       riTheDestCameraY);


     fillchar(uncoveredmap, sizeof(uncoveredmap), 0);

     yblockofs:=-5;

     iStartCameraX:=(random(MAX_CAVE_WIDTH-(g_PlayerViewWidth-1))+1) SHL 4;
     iStartCameraY:=(random(MAX_CAVE_HEIGHT-(g_cPlayerViewHeight-1))+1) SHL 4;


     wTemp:=g_PlayerViewWidth SHL 4;

     for cCount:=1 to 72 do
     begin
           vwait(3);

           SetWindow(0,0,319,7);
           Clw;

           if cLivesLeft <>1 then
              TempStr:='MEN'
           else
              TempStr:='MAN';

           BDPrintAt(0,0, 'PLAYER '+chr(48+cPlayer)+
                          ' '+chr(48+cLivesLeft)+' '+TempStr+' '+
                          chr(64+cTheCave)+'/'+chr(48+cTheDifficulty)
                          ,COLOUR_WHITE_INDEX);


           DrawPlayerView(0);


           for down:=0 to g_cPlayerViewHeight-1 do
               for across:=0 to g_PlayerViewWidth-1 do
                   begin
                   if uncoveredmap[across+1,down+1] = false then
                      begin
                      wTemp:=g_PlayerViewWidth SHL 4;

                      { Stop tiles from being blitted to the score area }

                      cWinmaxy:=(down SHL 4) +32;
                      if cWinmaxy > 199 then
                         cWinmaxy:=199;



                      if cPlayer = 1 then
                         SetWindow(across SHL 4,8+down SHL 4,
                         wTemp-8, cWinmaxy )
                      else
                          SetWindow(wTemp+8+(across SHL 4),8+down SHL 4,
                          319,cWinmaxy);

                      ClipBlock(0,yblockofs,ShapeList[TitaniumWall1]^);
                      ClipBlock(0,yblockofs+16,ShapeList[TitaniumWall1]^);
                      if random(10)=1 then uncoveredmap[across+1,down+1]:=true;
                      end;
                   end;

           ShowUsedBitmap;

           UpdateObjects(TRUE);


           yblockofs:=yblockofs-1;
           if yblockofs=-16 then
              yblockofs:=0;


           AdjustCamera (   cDestX,
                            cDestY,
                            iStartCameraX,
                            iStartCameraY,
                            riTheDestCameraX,
                            riTheDestCameraY);
     end;

     DrawPlayerCaveArea(    cPlayer,
                            false,
                            iStartCameraX,
                            iStartCameraY);
     ShowUsedBitmap;

     SetWindow(0,0,319,199);
end;



















{ =========================================================

  This is the actual game engine.

  You must have loaded a cave before calling this function.

  ---------------------------------------------------------
}


function PlayGame: FinalOutCome;


const EXCEPTIONALLY_BAD_PROGRAMMING = 255;


var
    ScreenCentreX                : integer;
    OurStr              : string[3];
    PlayersNotInvolved  : boolean;
    CompletedLevel      : boolean;
    count               : byte;

begin
     InitVGAMode;
     UsePalette(GamePalette);
     UseBitmap(pScratchBmp);
     BDAdviseBitmap(pScratchBmp);


     { Set view dimensions as well, because this is called from the demo }

     g_PlayerViewWidth:=CAMERA_VIEW_BLOCK_WIDTH;
     g_cPlayerViewHeight:=CAMERA_VIEW_BLOCK_HEIGHT;
     If g_ctGameType <> OnePlayer Then
        g_PlayerViewWidth:=g_PlayerViewWidth div 2;

     ScreenCentreX:=g_PlayerViewWidth SHL 4;


     repeat
           SetWindow(0,0,319,199);
           Cls;



{$ifdef DEBUG}
           DebugLoadCave(    g_ctGameType,
                             g_cCurrentCave,
                             g_cDifficulty,
                             g_PlayField,
                             g_cCaveInfoStruct);

{$else}

           LoadCave( GameType,
                     g_cCurrentCave,
                     g_cDifficulty,
                     g_PlayField,
                     g_cCaveInfoStruct);
{$endif}


           OnStartCave;


           if g_ctGameType <> OnePlayer Then
              Block(ScreenCentreX-6,11,g_pPlayer1Panel^);


            { do player stuff before screen displayed }

           g_bIsPlayer1Alive:=false;
           g_cPlayer1X:=g_cCaveInfoStruct.m_cPlayer1X;
           g_cPlayer1Y:=g_cCaveInfoStruct.m_cPlayer1Y;


           g_PlayField[g_cPlayer1X,g_cPlayer1Y]:=ord(p1Appearing1);


           { Now set up Player 2 (if Two player game, that is) }

           if g_ctGameType <> OnePlayer Then
              Begin
              Block(ScreenCentreX-6,8+ShapeHeight(g_pPlayer1Panel^)+8,
              g_pPlayer2Panel^);

              g_bIsPlayer2Alive:=false;
              g_cPlayer2X:=g_cCaveInfoStruct.m_cPlayer2X;
              g_cPlayer2Y:=g_cCaveInfoStruct.m_cPlayer2Y;


              g_PlayField[g_cPlayer2X, g_cPlayer2Y]:=ord(p2Appearing1);
              End;



           { OK, now focus camera on player 1 }

           ScrollViewToPlayersOrigin( 1,
                                      g_cPlayer1Lives,
                                      g_cCurrentCave,
                                      g_cDifficulty,
                                      g_cPlayer1X,
                                      g_cPlayer1Y,
                                      g_iPlayer1CameraX,
                                      g_iPlayer1CameraY,
                                      g_iPlayer1DestCameraX,
                                      g_iPlayer1DestCameraY);


           { Focus camera on player 2 }

           if g_ctGameType <> OnePlayer Then
           ScrollViewToPlayersOrigin( 2,
                                      g_cPlayer2Lives,
                                      g_cCurrentCave,
                                      g_cDifficulty,
                                      g_cPlayer2X,
                                      g_cPlayer2Y,
                                      g_iPlayer2CameraX,
                                      g_iPlayer2CameraY,
                                      g_iPlayer2DestCameraX,
                                      g_iPlayer2DestCameraY);



           { OK, now players are active }

           PlayersNotInvolved:=false;
           CompletedLevel:=false;


           HookKeyboard;

           repeat

                 SetWindow(0,0,319,7);
                 Clw;

                 Str(g_cPlayer1Diamonds:3, OurStr);
                 BDPrintAt(0,0,OurStr+'/',COLOUR_WHITE_INDEX);

                 Str(g_cCaveInfoStruct.m_cDiamondsNeeded:3, OurStr);
                 BDPrintAt(40,0,OurStr,COLOUR_WHITE_INDEX);

                 Str(g_cCaveInfoStruct.m_wCaveTime:3, OurStr);
                 BDPrintAt(132,0,OurStr,COLOUR_WHITE_INDEX);



                 DrawPlayerView(1);
                 if g_ctGameType <> OnePlayer Then
                    DrawPlayerView(2);


                 vwait(1);
                 ShowUsedBitmap;

                 { The game timer ticketh down }

                 inc(tickcount);
                 if tickcount = 75 then { Assuming your monitor is 75hz :( }
                 begin
                      tickcount:=1;
                      dec(g_cCaveInfoStruct.m_wCaveTime);
                 end;


                 UpdateObjects(TRUE);

                 { This is the best place to put the abort keys, methinks }
                 { Abort keys are CTRL + END pressed together}

                 if IsEndGamePressed then
                 begin
                      UnHookKeyboard;
                      PlayGame:=GameAborted;
                      exit;
                 end;


                 { Determine circumstances for this current game finishing }


                 PlayersNotInvolved:=false;

                 If g_bPlayer1Appeared Then
                    PlayersNotInvolved:=
                    ((not g_bIsPlayer1Alive) or
                       g_bPlayer1CompletedLevel);

                 If g_bPlayer2Appeared Then
                    PlayersNotInvolved:=
                    PlayersNotInvolved
                    or
                    ((not g_bIsPlayer2Alive) or
                    g_bPlayer2CompletedLevel);


           { Until players are either dead, or time's run out,
             or they've exited the level. }

           until ((g_bPlayer1Appeared or g_bPlayer2Appeared)
                 and PlayersNotInvolved) or (g_cCaveInfoStruct.m_wCaveTime = 0);


           UnHookKeyboard;



           { Now lets deduce what happened }

           if g_cCaveInfoStruct.m_wCaveTime = 0 Then
           Begin
              SetWindow(0,0,319,7);
              Clw;
              BDPrintAt(0,0,'    OUT OF TIME    ',COLOUR_WHITE_INDEX);


              { Kill players for messing around }

              Explode( g_cPlayer1X,
                       g_cPlayer1Y,
                       ExplosionStage1);

              if g_bIsPlayer2Alive Then
                 Explode( g_cPlayer2X,
                          g_cPlayer2Y,
                          ExplosionStage1);
           End
           Else

           { Depending on the game type, we can be kind or cruel }

               case g_ctGameType of
               TwoPlayerCoop:
                    Begin

                    {
                    If it's a coop game then when one player
                    dies, so does the other!
                    }

                    If g_bIsPlayer1Alive And (Not g_bIsPlayer2Alive) Then
                       Explode( g_cPlayer1X,
                                g_cPlayer1Y,
                                ExplosionStage1)
                    Else
                        If g_bIsPlayer2Alive And
                        (Not g_bIsPlayer1Alive) Then
                             Explode( g_cPlayer2X,
                                      g_cPlayer2Y,
                                      ExplosionStage1);
                    End;

               TwoPlayerCompetitive:
                    Begin

                    {
                    If it's a competitive game then if one player
                    completes the level, the other dies.
                    }

                    If g_bPlayer1CompletedLevel Then
                       Explode( g_cPlayer2X,
                                g_cPlayer2Y,
                                ExplosionStage1)
                    else
                        If g_bPlayer2CompletedLevel Then
                           Explode ( g_cPlayer1X,
                                     g_cPlayer1Y,
                                     ExplosionStage1);

                    End;
               End;





           { Wait 3 seconds }

           for count:=1 to (3 * 75) do
               begin
               DrawPlayerView(1);

               if g_ctGameType <> OnePlayer Then
                  DrawPlayerView(2);

               vwait(1);
               ShowUsedBitmap;
               UpdateObjects(FALSE);
               end;



           { If we're in demo mode then do not decrement any lives,
             this will force the calling routine to return to the
             title page.
           }

           if g_eGameMode = Demo Then exit;



           { If Player 1 has died then decrement his life count }

           If not g_bIsPlayer1Alive Then
              begin
              dec(g_cPlayer1Lives);
              if g_cPlayer1Lives = 0 Then
                 begin
                 PlayGame:=Player1GameOver;
                 exit;
                 end
              end;


           { If player 2 has died then decrement his life count }

           If (g_ctGameType <> OnePlayer) And (not g_bIsPlayer2Alive) Then
              begin
              dec(g_cPlayer2Lives);
              if g_cPlayer2Lives = 0 Then
                 begin
                 PlayGame:=Player2GameOver;
                 exit;
                 end
              end;



           { If either player has completed the level, go to the next
             one.
           }

           if g_bPlayer1CompletedLevel or
           ((g_ctGameType <>OnePlayer) And g_bPlayer2CompletedLevel) Then
           Begin
                inc(g_cCurrentCave);
                if g_cCurrentCave > MAX_CAVES Then
                Begin
                     g_cCurrentCave:=1;
                     Inc(g_cDifficulty);
                     If g_cDifficulty > DIFFICULTY_LEVELS then
                     begin
                          PlayGame:=AllLevelsCompleted;
                          exit;
                     End;
                End;
           End;



     until false;
end;








{ *****************************************************************

                FUNCTIONS CALLED BY MAIN PROGRAM

}






{ ===============================================================

  This procedure allows the user to select a level to begin with,
  then play that level.

  This is NOT the main game engine: PlayGame (see above) handles
  the main game tasks.

  ---------------------------------------------------------------
}

procedure RunGame;
begin
     g_ctGameType:=OnePlayer;
     g_cCurrentCave:=1;
     g_cDifficulty:=1;

     g_cPlayer1Lives:=3;
     g_cPlayer2Lives:=3;
     GameSelect(   g_ctGameType,
                   g_cCurrentCave,
                   g_cDifficulty,
                   g_lPlayer1HiScore,
                   g_lPlayer2HiScore);

     g_eGameMode:=RealGame;

     repeat until PlayGame in [ Player1GameOver,
                                Player2GameOver,
                                AllLevelsCompleted,
                                GameAborted];


end;






{ ==================================================================

  Ask user if he wants to play, edit a map, define keys, or quit.
  Should he select Quit, then this routine returns FALSE to indicate
  that the user did not select any main options, and wishes to
  exit the option screen.

  ------------------------------------------------------------------
}


Function ExecuteUserOption : boolean;
Begin
      case SelectMainOption of

      Play: Begin
            RunGame;
            ExecuteUserOption:=true;
            End;


      Edit: Begin
            ExecuteUserOption:=true;
            End;

      KeyDef: Begin
              ChooseKeys;
              ExecuteUserOption:=true;
              End;

      Quit: ExecuteUserOption:=false;
            End;
End;







{ =============================================================

  Show the title page (the one with Rockford tapping his foot)


  If the user presses ESC on this page, this returns
  value eEscapePressed.

  If the user presses any other key, this returns
  value eContinue.

  -------------------------------------------------------------
}

Function ExecuteTitles : EndTitleTypes;
var ReasonToEndTitle: EndTitleTypes;

begin
     ReasonToEndTitle:= ShowTitle(300);
     While ReasonToEndTitle = eTimeOutExpired do
     Begin
          g_cDemoDataIndx:=1;
          g_eDemoDirection:=Standing;
          LoadCaveFromFile( 'demo.MAP',
                            g_PlayField,
                            g_cCaveInfoStruct);

          g_cPlayer1X:=g_cCaveInfoStruct.m_cPlayer1X;
          g_cPlayer1Y:=g_cCaveInfoStruct.m_cPlayer1Y;

          g_ctGameType:=OnePlayer;
          g_eGameMode:=Demo;
          PlayGame;

          ReasonToEndTitle:= ShowTitle(300);
     End;

     ExecuteTitles:=ReasonToEndTitle;
End;






Procedure InitGraphics;
Begin
     { All game specific stuff first }

     pScratchBmp:=New64KBitmap;

     { And now the game specific GFX }

     LoadShape('p1panel.img',g_pPlayer1Panel);
     LoadShape('p2panel.img',g_pPlayer2Panel);
End;












{ *************************************************************************

                                 MAIN PROGRAM

  *************************************************************************
}



Begin
     { Lets get the variable init out of the way first }

     g_lPlayer1HiScore:=10000;
     g_lPlayer2HiScore:=10000;


     { Note how everything has been moved into a procedure,
       it's to make debugging easier, I can just step over
       the unimportant parts now }

     InitGraphics;

     repeat
           if ExecuteTitles <> eEscapePressed Then
              Begin
              if Not ExecuteUserOption Then
                 break;
              End
           Else
               break;
     until false;


     { Aw! }

     TextMode(CO80);
     Writeln('Thank you for playing boulderdash!');
     Halt;
End.


