program Cavedata;

const
     defaultbredde = 39;
     defaulthojde = 24;

type
    cavepost = record
             cave:array[0..defaultbredde,0..defaulthojde] of byte;
             palet:array[0..15,0..47] of byte;
             cavetype:byte;
             cavebredde:byte;
             cavehojde:byte;

             cavedelay:byte;
             cavetime:word;
             diamondsneeded:word;
             diamondvalue:byte;
             bonusdiamondvalue:byte;
             slimepermeability:byte;
             amoebiagrowth:word;
             millingtime:word;

             hulenavn:string[20];
             huleinformation:string[20];
             mereinfo:string[252];
             kobling,exitx,exity:byte;
    end;




procedure GotoXY(x,y:byte);
begin
     asm
	mov ah,2;
        mov bh,0;
        mov dh,y;
        mov dl,x;
        dec dh;
        dec dl;

        int $10;
     end;
end;



procedure SetVideoMode(vm:byte);
begin
     asm
        mov ah,0;
        mov al,vm;

        int $10;
     end;
end;



var
   cave:file of cavepost;
   caveind:cavepost;
   var x,y:byte;
begin
     assign(cave,paramstr(1));
     reset(cave);
     read(cave,caveind);
     close(cave);
     setvideomode(93);
     with caveind do
          begin
               for y := 0 to defaulthojde do
                   begin
                        for x := 0 to defaultbredde do
                            begin
                                 if cave[x,y] < 10 then write(' ');
                                 write(cave[x,y],' ');
                            end;
                        writeln;
                   end;

               x := 5;
               y := 30;
               gotoxy(x,y);write('Cave type:              ',cavetype);
               gotoxy(x,y+1);write('Cave width:             ',cavebredde);
               gotoxy(x,y+2);write('Cave height:            ',cavehojde);
               gotoxy(x,y+3);write('Cave delay:             ',cavedelay);
               gotoxy(x,y+4);write('Cave time:              ',cavetime);
               gotoxy(x,y+5);write('Diamonds needed:        ',diamondsneeded);
               gotoxy(x,y+6);write('Bonus diamond value:    ',bonusdiamondvalue);
               gotoxy(x,y+7);write('Slime permeability:     ',slimepermeability);
               gotoxy(x,y+8);write('Amoebia time of growth: ',amoebiagrowth);
               gotoxy(x,y+9);write('Wall milling time:      ',millingtime);
               gotoxy(x,y+10);write('Cave name:              ',hulenavn);
               gotoxy(x,y+11);write('Cave info:              ',huleinformation);
               gotoxy(x,y+12);write('Additional info:        ',mereinfo);
               gotoxy(x,y+13);write('Extra feature:          ',kobling);
               gotoxy(x,y+14);write('Exit X:                 ',exitx);
               gotoxy(x,y+15);write('Exit Y:                 ',exity);
          end;
     readln;
end.