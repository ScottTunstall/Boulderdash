unit bldOpts;


interface



type MainOptionType = (Play, Edit, KeyDef, Quit);
function SelectMainOption: MainOptionType;


implementation

uses kojakvga, nwkbdint, bouldmsc;



const SCANCODE_UP = 72;
const SCANCODE_DOWN = 80;
const SCANCODE_LEFT = 75;
const SCANCODE_RIGHT = 77;
const SCANCODE_ENTER = 28;
const SCANCODE_SPACE = 57;





{
Does the user want to play or edit a level ?
}

function SelectMainOption: MainOptionType;
var

    pGameOptsBmp: pointer;
    IntroScreen2Palette: PaletteType;
    pScratchBmp: pointer;

    WndRect: WindowType;

    { Tile movement/ blit vars }
    pTileImg: pointer;
    pArrowImg: pointer;
    yoffset: integer;
    across : word;
    down   : word;

    { BDAdviseFont vars }
    w, h   : byte;

    ArrowItem: byte;
    ArrowDelay: byte;


begin
     pScratchBmp:=New64KBitmap;
     pGameOptsBmp:=New64KBitmap;
     UseBitmap(pGameOptsBmp);
     LoadPCX('Intro2.pcx', IntroScreen2Palette);

     { Game select screen tile }

     LoadShape('bluetile.img', pTileImg);
     LoadShape('arrow.img', pArrowImg);

     GetWindowSettings(WndRect);
     InitVGAMode;


     { pScratchBmp will be our back buffer }

     UseBitmap(pScratchBmp);

     Cls;

     UsePalette(IntroScreen2Palette);

     { Advise boulderdash unit where our bitmap is }

     BDAdviseBitmap(GetUsedBitmapAddr);

     yoffset:=0;
     ArrowItem:=1;
     ArrowDelay:=10;

     HookKeyboardInt;

     Repeat
           { Define clipping region so that our tiles won't overwrite walls }

           SetWindow(0,0,318,128);


           { Draw clipped tiles at top of window }

           For across:=0 to 19 do
               ClipBlock(across SHL 4,yoffset,pTileImg^);

           For down:=0 to 8 do
               For across:=0 to 19 do
                   ClipBlock(across SHL 4,yoffset+(down * 16), pTileImg^);

           CopyMaskedBitmap(pGameOptsBmp, pScratchBmp);


           dec(yoffset);
           if yoffset = -16 then yoffset:=0;


           if ArrowDelay MOD 3=0 Then
              Begin

              { Cursor up ? }

              if keydown[SCANCODE_UP] Then
                 begin
                 if Arrowitem = 1 Then
                    ArrowItem:= 4
                 else
                     dec(ArrowItem);
                 end
              else
                  { Cursor down ? }

                  if keydown[SCANCODE_DOWN] Then
                     begin
                     if ArrowItem = 4 Then
                        ArrowItem:= 1
                     else
                         inc(ArrowItem);
                     end;
              End;


           { Should we blit option highlight arrow or not ? }


           SetWindow(0,0,319,199);

           Dec(ArrowDelay);
           if ArrowDelay < 5 Then
              Begin
              Blit(184,128+ArrowItem * 16, pArrowImg^);

              If ArrowDelay = 0 Then
                 ArrowDelay:=10;
              End;



           { Now transfer the back buffer to the main screen }

           Vwait(3);
           ShowAllBitmap(pScratchBmp);


     Until Keydown[SCANCODE_SPACE] or Keydown[SCANCODE_ENTER];
     UnHookKeyboardInt;

     SetWindowEx(WndRect);

     FreeShape(pTileImg);
     FreeShape(pArrowImg);

     FreeBitmap(pScratchBmp);
     FreeBitmap(pGameOptsbmp);


     Case ArrowItem of
     1 : SelectMainOption:=Play;
     2 : SelectMainOption:=Edit;
     3 : SelectMainOption:=KeyDef;
     4 : SelectMainOption:=Quit;
     End;



end;


begin

end.