var scancode: byte;

begin
     repeat
           asm
           mov ax, $10
           int $16;
           mov scancode,ah
           end;

     writeln('Scan code of key pressed is ',scancode);

     until scancode = 1;
end.