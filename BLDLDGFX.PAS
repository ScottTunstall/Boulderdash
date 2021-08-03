{
FILENAME : BLDLDGFX.PAS

AUTHOR   : SCOTT TUNSTALL

DATE     : 5/3/1999

PURPOSE  : LOADS BOULDERDASH SPRITE DATA INTO MEMORY,
           THIS UNIT WILL BE SHARED WITH THE CONSTRUCTION KIT.
}


unit BLDLDGFX;

interface

uses kojakvga;

{$I defs.inc }




type ShapeListType = Array[1..NumAnimFrames] of pointer;

var GamePalette: PaletteType;
var ShapeList: ShapeListType;



implementation






{ Load Game Palette and sprites into memory }


Procedure LoadGraphics(var ShapeList : ShapeListType);
begin
     { Player 1 }

     LoadShape('p1stand.img',ShapeList[p1stand]);
     LoadShape('p1left1.img',ShapeList[p1walkleft1]);
     LoadShape('p1left2.img',ShapeList[p1walkleft2]);
     LoadShape('p1left3.img',ShapeList[p1walkleft3]);
     LoadShape('p1right1.img',ShapeList[p1walkright1]);
     LoadShape('p1right2.img',ShapeList[p1walkright2]);
     LoadShape('p1right3.img',ShapeList[p1walkright3]);
     LoadShape('p1blink1.img',ShapeList[p1blink1]);
     LoadShape('p1blink2.img',ShapeList[p1blink2]);
     LoadShape('p1marker.img',ShapeList[p1Marker]);

     { Player 2 }

     LoadShape('p2stand.img',ShapeList[p2stand]);
     LoadShape('p2left1.img',ShapeList[p2walkleft1]);
     LoadShape('p2left2.img',ShapeList[p2walkleft2]);
     LoadShape('p2left3.img',ShapeList[p2walkleft3]);
     LoadShape('p2right1.img',ShapeList[p2walkright1]);
     LoadShape('p2right2.img',ShapeList[p2walkright2]);
     LoadShape('p2right3.img',ShapeList[p2walkright3]);
     LoadShape('p2blink1.img',ShapeList[p2blink1]);
     LoadShape('p2blink2.img',ShapeList[p2blink2]);
     LoadShape('p2marker.img',ShapeList[p2Marker]);


     { Non-moving Rockford }

     LoadShape('rockfrd.img', ShapeList[rockford1]);


     { Diamond }

     LoadShape('diamond1.img',ShapeList[Diamondstrobe1]);
     LoadShape('diamond2.img',ShapeList[Diamondstrobe2]);
     LoadShape('diamond3.img',ShapeList[Diamondstrobe3]);
     LoadShape('diamond4.img',ShapeList[Diamondstrobe4]);
     LoadShape('diamond5.img',ShapeList[Diamondstrobe5]);

     { Butterfly }

     LoadShape('buttfly1.img', ShapeList[bflyflap1]);
     LoadShape('buttfly2.img', ShapeList[bflyflap2]);
     LoadShape('buttfly3.img', ShapeList[bflyflap3]);

     { FireFly }

     LoadShape('firefly1.img', ShapeList[fflyflap1]);
     LoadShape('firefly2.img', ShapeList[fflyflap2]);
     LoadShape('firefly3.img', ShapeList[fflyflap3]);
     LoadShape('firefly4.img', ShapeList[fflyflap4]);

     { Amoeba }

     LoadShape('amoeba1.img', ShapeList[Amoebawibble1]);
     LoadShape('amoeba2.img', ShapeList[Amoebawibble2]);
     LoadShape('amoeba3.img', ShapeList[Amoebawibble3]);
     LoadShape('amoeba4.img', ShapeList[Amoebawibble4]);

     { Permeable wall }

     LoadShape('prmwall1.img', ShapeList[Permwallwibble1]);
     LoadShape('prmwall2.img', ShapeList[Permwallwibble2]);
     LoadShape('prmwall3.img', ShapeList[Permwallwibble3]);
     LoadShape('prmwall4.img', ShapeList[Permwallwibble4]);

     { Magic wall }

     LoadShape('magic1.img', ShapeList[MgcWallStrobe1]);
     LoadShape('magic2.img', ShapeList[MgcWallStrobe2]);
     LoadShape('magic3.img', ShapeList[MgcWallStrobe3]);
     LoadShape('magic4.img', ShapeList[MgcWallStrobe4]);

     { Titanium wall }

     LoadShape('titanium.img', ShapeList[TitaniumWall1]);

     { Normal / Expanding wall }

     LoadShape('wall.img', ShapeList[Normalwall1]);

     { boulder }

     LoadShape('boulder.img', ShapeList[Boulder1]);


     { Explosion animations }

     LoadShape('explode1.img', ShapeList[Explosion1]);
     LoadShape('explode2.img', ShapeList[Explosion2]);
     LoadShape('explode3.img', ShapeList[Explosion3]);


     { earth }

     LoadShape('earth.img', ShapeList[Earth1]);

     { Empty space - you can replace this with something more interesting }

     LoadShape('empty.img', ShapeList[Empty1]);


End;




Begin
     LoadPalette('sprites.pal',GamePalette);

     { And now lets load the shared graphics }

     LoadGraphics(ShapeList);


     Writeln('BOULDERDASH SPRITE LOAD ROUTINES');
     Writeln(' (C) 1998 Scott Tunstall.');
     Writeln('This unit is FREEWARE. Please distribute source/compiled code');
     Writeln('freely in it''s original, unaltered state.');
     Writeln;


End.