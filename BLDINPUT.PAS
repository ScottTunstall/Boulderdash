Unit BldInput;

interface



{ These routines can treat the joystick just like keys }

procedure HookKeyboard;
procedure UnHookKeyboard;

function IsPlayer1UpPressed: boolean;
function IsPlayer1DownPressed: boolean;
function IsPlayer1LeftPressed: boolean;
function IsPlayer1RightPressed: boolean;
function IsPlayer1DigPressed: boolean;
function IsPlayer1AbortPressed: boolean;

function IsPlayer2UpPressed: boolean;
function IsPlayer2DownPressed: boolean;
function IsPlayer2LeftPressed: boolean;
function IsPlayer2RightPressed: boolean;
function IsPlayer2DigPressed: boolean;
function IsPlayer2AbortPressed: boolean;

function IsEndGamePressed: boolean;


procedure ChooseKeys;

implementation

uses kojakvga, bouldmsc, nwkbdint, crt;


type KeyInfoRec = record
     P1UpKeyScanCode,
     P1DownKeyScanCode,
     P1LeftKeyScanCode,
     P1RightKeyScanCode,
     P1DigKeyScanCode,
     P1AbortKeyScanCode,
     P2UpKeyScanCode,
     P2DownKeyScanCode,
     P2LeftKeyScanCode,
     P2RightKeyScanCode,
     P2DigKeyScanCode,
     p2AbortKeyScanCode : byte;

end;



var KeyInfo : KeyInfoRec;





{
=======================================

Load key definitions from file KEYS.DAT

---------------------------------------
}


function LoadKeysFromFile : boolean;
var F: File of KeyInfoRec;
begin
     Assign(F,'KEYS.DAT');
     {$i-}
     Reset(F);
     {$i+}
     if IoResult <>0 Then
     begin
          LoadKeysFromFile:=false;
          exit;
     end
     else
         begin
         read(f,KeyInfo);
         close(f);
         LoadKeysFromFile:=true;
         end;
end;




procedure ResetToDefaultKeys;
begin
     Keyinfo.P1UpKeyScanCode:= 17;      { W }
     Keyinfo.P1DownKeyScanCode:= 45;    { X }
     Keyinfo.P1LeftKeyScanCode:= 30;    { A }
     Keyinfo.P1RightKeyScanCode:= 32;   { D }
     Keyinfo.P1DigKeyScanCode:= 57;     { SPACE }
     KeyInfo.P1AbortKeyScanCode:=59;    { F1 }

     Keyinfo.P2UpKeyScanCode:= 72;      { UP }
     Keyinfo.P2DownKeyScanCode:= 80;    { DOWN }
     Keyinfo.P2LeftKeyScanCode:= 75;    { LEFT }
     Keyinfo.P2RightKeyScanCode:= 77;   { RIGHT }
     Keyinfo.P2DigKeyScanCode:= 28;     { ENTER }
     KeyInfo.P2AbortKeyScanCode:=88;    { F12 }
end;







{
==========================================================================

Wait for a keypress, display the key pressed, then return
the scancode of the key.

Expects: y is the coordinate of the line on which to draw the key pressed.

Returns: Scancode of key pressed.

--------------------------------------------------------------------------
}

Function GetKeyboard(y : integer) : byte;
var  ASCII : char;
     scancode: byte;
     strkey: string[5];

begin
     asm
     mov ax, $10
     int $16;
     mov scancode,ah
     mov ASCII,al
     end;


     if ASCII in ['a'..'z', 'A'..'Z', '0'..'9', '/', ':', '@','$'] then
        BDPrintAt(208,y,upcase(ASCII),255)
     else
         begin
         strKey:='     ';
         case scancode of

         28: strKey:='ENTER';
         57: strKey:='SPACE';
         72: strKey:='UP';
         80: strKey:='DOWN';
         75: strKey:='LEFT';
         77: strKey:='RIGHT';
         71: strKey:='HOME';
         73: strKey:='PGUP';
         79: strKey:='END';
         81: strKey:='PGDN';
         82: strKey:='INS';
         83: strKey:='DEL';
         end;

         BDPrintAt(204, y, strKey,255);
         end;

     GetKeyboard:=scancode;
end;






{
************************************************************************

KEY DEFINE SCREEN

------------------------------------------------------------------------
}

procedure ChooseKeys;

var  KeyDefPalette : PaletteType;
     f: File Of KeyinfoRec;

begin

     BDAdviseBitmap(VGA_ADDR);
     UseBitmap(VGA_ADDR);

     LoadPalette('sprites.pal', KeyDefPalette);


     InitVGAMode;
     UsePalette(KeyDefPalette);


     BDPrintAt(64,8,'DEFINE KEYS',255);


     BDPrintAt(40,32, 'P1 UP    :',254);
     KeyInfo.P1UpKeyScanCode:=GetKeyBoard(32);

     BDPrintAt(40,40, 'P1 DOWN  :',254);
     KeyInfo.P1DownKeyScanCode:=GetKeyBoard(40);

     BDPrintAt(40,48, 'P1 LEFT  :',254);
     KeyInfo.P1LeftKeyScanCode:=GetKeyBoard(48);

     BDPrintAt(40,56, 'P1 RIGHT :',254);
     KeyInfo.P1RightKeyScanCode:=GetKeyBoard(56);

     BDPrintAt(40,64, 'P1 DIG   :',254);
     KeyInfo.P1DigKeyScanCode:=GetKeyBoard(64);

     BDPrintAt(40,72, 'P1 ABORT :',254);
     KeyInfo.P1AbortKeyScanCode:=GetKeyBoard(72);


     BDPrintAt(40,88, 'P2 UP    :',254);
     KeyInfo.P2UpKeyScanCode:=GetKeyBoard(88);

     BDPrintAt(40,96, 'P2 DOWN  :',254);
     KeyInfo.P2DownKeyScanCode:=GetKeyBoard(96);

     BDPrintAt(40,104, 'P2 LEFT  :',254);
     KeyInfo.P2LeftKeyScanCode:=GetKeyBoard(104);

     BDPrintAt(40,112, 'P2 RIGHT :',254);
     KeyInfo.P2RightKeyScanCode:=GetKeyBoard(112);

     BDPrintAt(40,120, 'P2 DIG   :',254);
     KeyInfo.P2DigKeyScanCode:=GetKeyBoard(120);

     BDPrintAt(40,128, 'P2 ABORT :',254);
     KeyInfo.P2AbortKeyScanCode:=GetKeyBoard(128);


     Assign(f,'KEYS.DAT');
     Rewrite(f);
     Write(f,Keyinfo);
     Close(f);


     BDPrintAt(72,144,'KEYS SAVED',253);

     ReadKey;
end;










{ ==================================================================

  TAKE OVER/ RELINQUISH CONTROL OF KEYBOARD

  ------------------------------------------------------------------
}



procedure HookKeyboard;
begin
     HookKeyboardInt;
end;



procedure UnHookKeyboard;
begin
     UnHookKeyboardInt;
end;




{ ==================================================================

  PLAYER 1 KEYS

  ------------------------------------------------------------------
}


function IsPlayer1UpPressed: boolean;
begin
     IsPlayer1UpPressed:=keydown[KeyInfo.P1UpKeyScanCode];
end;


function IsPlayer1DownPressed: boolean;
begin
     IsPlayer1DownPressed:=keydown[KeyInfo.P1DownKeyScanCode];
end;


function IsPlayer1LeftPressed: boolean;
begin
     IsPlayer1LeftPressed:=keydown[KeyInfo.P1LeftKeyScanCode];
end;


function IsPlayer1RightPressed: boolean;
begin
     IsPlayer1RightPressed:=keydown[KeyInfo.P1RightKeyScanCode];
end;


function IsPlayer1DigPressed: boolean;
begin
     IsPlayer1DigPressed:=keydown[KeyInfo.P1DigKeyScanCode];
end;


function IsPlayer1AbortPressed: boolean;
begin
     IsPlayer1AbortPressed:=keydown[KeyInfo.P1AbortKeyScanCode];
end;




{ ==================================================================

  PLAYER 2 KEYS

  ------------------------------------------------------------------
}


function IsPlayer2UpPressed: boolean;
begin
     IsPlayer2UpPressed:=keydown[Keyinfo.P2UpKeyScanCode];
end;


function IsPlayer2DownPressed: boolean;
begin
     IsPlayer2DownPressed:=keydown[Keyinfo.P2DownKeyScanCode];
end;


function IsPlayer2LeftPressed: boolean;
begin
     IsPlayer2LeftPressed:=keydown[Keyinfo.P2LeftKeyScanCode];
end;


function IsPlayer2RightPressed: boolean;
begin
     IsPlayer2RightPressed:=keydown[Keyinfo.P2RightKeyScanCode];
end;


function IsPlayer2DigPressed: boolean;
begin
     IsPlayer2DigPressed:=keydown[Keyinfo.P2DigKeyScanCode];
end;


function IsPlayer2AbortPressed: boolean;
begin
     IsPlayer2AbortPressed:=keydown[KeyInfo.P2AbortKeyScanCode];
end;




{ ======================================================================

  MISC KEY INPUT FUNCTIONS

  ----------------------------------------------------------------------
}


{ Has CTRL + END been pressed? }

function IsEndGamePressed: boolean;
begin
     IsEndGamePressed:=(keydown[29] and keydown[79]);
end;










begin
     if not LoadKeysFromFile Then
        ResetToDefaultKeys;

     Writeln('BOULDERDASH KEYBOARD INPUT ROUTINES');
     Writeln(' (C) 1999 Scott Tunstall.');
     Writeln('This unit is FREEWARE. Please distribute source/compiled code');
     Writeln('freely in it''s original, unaltered state.');
     Writeln;
end.