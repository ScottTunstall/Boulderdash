unit bldcam;



interface


Procedure InitialiseCamera( PlayerX,
                            PlayerY,
                            PlayFieldWidth,
                            PlayFieldHeight,
                            ViewWidth,
                            ViewHeight      : integer;
                            BlockWidth,
                            BlockHeight     : byte;

                            var CameraX,
                                CameraY,
                                DestCameraX,
                                DestCameraY : integer);



Procedure AdjustCamera    ( PlayerX,
                            PlayerY: byte;
                            var CameraX,
                            CameraY,
                            DestCameraX,
                            DestCameraY : integer);





implementation


var
   m_PlayFieldWidth          : byte;
   m_PlayFieldHeight         : byte;
   m_ViewWidth          : byte;
   m_ViewHeight         : byte;


{
====================================================================

Whenever the player moves, this is called. Basically it ensures that
the "camera" centres the view around the player.

PlayerX and PlayerY tell the camera which block the camera should
focus on.


--------------------------------------------------------------------
}


Procedure InitialiseCamera( PlayerX,
                            PlayerY,
                            PlayFieldWidth,
                            PlayFieldHeight,
                            ViewWidth,
                            ViewHeight      : integer;
                            BlockWidth,
                            BlockHeight     : byte;

                            var CameraX,
                                CameraY,
                                DestCameraX,
                                DestCameraY : integer);
begin
     m_PlayFieldWidth:=PlayFieldWidth;
     m_PlayFieldHeight:=PlayFieldHeight;

     m_ViewWidth:=ViewWidth;
     m_Viewheight:=ViewHeight;


     CameraX:=(PlayerX-(ViewWidth div 2))+1;
     if CameraX < 1 Then
        CameraX:=1
     else
         if CameraX+ViewWidth>PlayFieldWidth Then
            CameraX:=PlayFieldWidth - (ViewWidth-1);

     CameraX:=CameraX * BlockWidth;


     CameraY:=(PlayerY-ViewHeight DIV 2);

     if CameraY < 1 Then
        CameraY:=1
     else
         if CameraY+ViewHeight>PlayFieldHeight Then
            CameraY:=PlayFieldHeight - (ViewHeight-1);

     CameraY:=CameraY * BlockHeight;

     DestCameraX:=CameraX;      { No scrolling at the start }
     DestCameraY:=CameraY;
end;





{
========================================

Pan camera to centre on PlayerX, PlayerY

----------------------------------------
}



Procedure AdjustCamera ( PlayerX,
                         PlayerY: byte;
                         var CameraX,
                             CameraY,
                             DestCameraX,
                             DestCameraY : integer);
Begin

     DestCameraX:=PlayerX-(m_ViewWidth div 2);
     if DestCameraX < 1 Then
        DestCameraX:=1
     else
         if DestCameraX+m_ViewWidth>(m_PlayFieldWidth+1) Then
            DestCameraX:=(m_PlayFieldWidth+1) - m_ViewWidth;

     DestCameraX:=(DestCameraX * 16)+8;


     DestCameraY:=(PlayerY-m_ViewHeight DIV 2);

     if DestCameraY < 1 Then
        DestCameraY:=1
     else
         if DestCameraY+m_ViewHeight>(m_PlayFieldHeight+1) Then
            DestCameraY:=(m_PlayFieldHeight+1) - m_ViewHeight;

     DestCameraY:=(DestCameraY * 16)+8;


     if CameraX < DestCameraX then
        inc(CameraX,2)
     else
         if CameraX > DestCameraX then
            dec(CameraX,2);

     if CameraY < DestCameraY then
        inc(CameraY,2)
     else
         if CameraY > DestCameraY then
            dec(CameraY,2);


End;





begin
     Writeln('Boulderdash camera routines');
     Writeln('(C) 1999 Scott Tunstall.');
     Writeln;
     Writeln('All rights reserved.');
end.