{
AUTHOR          : SCOTT TUNSTALL B.Sc
EMAIL           : tunstals@email.msn.com
                  tunstals@hotmail.com

CREATION DATE   : 20th AUGUST 1998

PURPOSE         : Miscellaneous routines for the boulderdash game.
}


Unit Bouldmsc;

Interface

procedure BDAdviseBitmap(BmapPtr: pointer);
Procedure BDPrintAt(x,y: Integer; txt:string; colour: byte);

Implementation

uses kojakvga;



var
    { Points to where text will be outputted, set by BDAdviseBitmap }

    CurrentBitmapPtr: pointer;

    { This contains the character set }

    CharData : array [0..7,0..47] of byte;




{ I made this a procedure instead of putting it into the initialisation
  simply so that variable f would not be made global }

procedure BDLoadFont;
var f: File;

begin
     Assign(f, 'Font.dta');
     Reset(f, sizeof(charData));
     BlockRead(f, CharData,1);
     Close(f);
end;





{ The pointer offset is always set to 0 anyway }

procedure BDAdviseBitmap(BmapPtr: pointer);
begin
     CurrentBitmapPtr:=BMapPtr;
end;




{
Output text <txt> at position x,y on the bitmap pointed to by
<CurrentBitmapSegment, CurrentBitmapOffset>

I got rid of the assembler because, to be quite frank, it didn't
fit in with the rest of the game.

I know Pascal isn't that fast, but hey you can convert it back
to asm if you want ;)

Christ! I just realised: I'm still using seg and ofs!
}

{ 0123456789:;//// ABCDEFGHIJKLMNOPQRSTUVWXYZ(D)R_ }



procedure BDPrintAt(x,y: Integer; txt:string; colour: byte);
var wColour     : word;
    PrevBitmap  : pointer;

    latch,
    x1,
    y1          : integer;
    count,
    do1,
    ac1         : byte;
    ch          : char;
    ndx         : byte;

begin
     wColour:=(colour SHL 8) + colour;


     PrevBitmap:=GetUsedBitmapAddr;
     UseBitmap(CurrentBitmapPtr);

     latch:=x;

     for count:=1 to length(txt) do
     begin
          x1:=latch;
          y1:=y;
          ch:=txt[count];  { OH GOD NO! THIS IS KID'S STUFF!!! }

          case ch of
          'a'..'z','A'..'Z' : ndx:=(byte(ch) and 31)+16;
          '0'..'9'          : ndx:=(byte(ch) - 48);
          ' ' : ndx:=16;
          ':' : ndx:=10;
          ';' : ndx:=11;
          '/' : ndx:=12;
          '(' : ndx:=43;
          ')' : ndx:=45;
          '$' : ndx:=44;  { Diamond }
          '@' : ndx:=46;  { rockfords face }
          '_' : ndx:=47;
          end;

          for do1:=0 to 7 do
          Begin
              for ac1:=0 to 7 do
                 begin
                 if (CharData[do1,ndx] and (1 SHL ac1)) <> 0 Then
                    Begin
                    PutPixel(x1,y1,colour);
                    PutPixel(x1+1,y1,colour);

                    End;

                 inc(x1,2);
                 End;
             x1:=latch;
             inc (y1);
          End;

          inc(latch,16);

     end;

     UseBitmap(PrevBitmap);
end;







Begin
     BDLoadFont;

     Writeln('BOULDERDASH TEXT OUTPUT ROUTINES (486 enhanced) ');
     Writeln(' (C) 1998 Scott Tunstall.');
     Writeln('This unit is FREEWARE. Please distribute source/compiled code');
     Writeln('freely in it''s original, unaltered state.');
     Writeln;
End.