// ENRUPT-512, вариант алгоритмов XXTEA/XTEA, усиленный и ускоренный Ruptor'ом
// Реализация на языке Delphi - А.В.Мясников, г.Кольчигино Владимирской обл., Россия

unit cu;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

var key: array [0..15] of longint= (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);

type longwordarray = array [0..15] of longword;
type plongwordarray = ^longwordarray;

function lrotr(N:longword; Num:longword):longword; stdcall;
asm
MOV EAX, DWORD PTR [ESP+4]
MOV ECX, DWORD PTR [ESP+8]
ROR EAX, CL
end;

function rupt(x0, x2, k, r: longword): longword;
begin
{$Q-}
result:=  longword(lrotr(longword(2*x0 xor x2 xor k xor r),8)*9);
end;

procedure  rupt1(x0: longword;var x1:longword;x2,k,r: longword);
begin
x1:=x1 xor (rupt(x0,x2,k,r)xor k);
end;

function enRUPT(x, k: plongwordarray; xw, kw, r: longword): integer;
begin

for r:=1 to 8*(xw)+4*kw
do begin

 rupt1 (x[(r-1) mod (xw)],x[r mod (xw)],x[(r+1) mod (xw)],k[r mod (kw)],r);

end;
result:=0;
end;


function unRUPT(x, k: plongwordarray; xw, kw, r: longword): integer;
begin

for r:=8*(xw)+4*(kw) downto 1
do begin

 rupt1 (x[(r-1) mod (xw)],x[r mod (xw)],x[(r+1) mod (xw)],k[r mod (kw)],r);

end;

result:=0;
end;


function setup (ap: pointer) : longint; export; stdcall;
begin
move (ap^, key, 64);
result:=0;
end; 

var pwd: array [0..15] of longint;

var din:array [0..15] of longint;
var dc:array [0..15] of longint;

procedure TForm1.Button1Click(Sender: TObject);
var i: integer;  error: boolean;r: longword;
begin

randomize();


for i:=0 to 15 do
begin
din[i]:=random(maxlongint);
dc[i]:=din[i];
end;
for i:=0 to 15 do pwd[i]:=random(maxlongint);

setup(@pwd);
enRUPT(@din,@key,16,16,r);
unRUPT(@din,@key,16,16,r);
memo1.Lines.Clear;

memo1.Lines.Add('Key:');
for i:=0 to 15 do begin
memo1.Text:=memo1.Text+(format('%u ',[key[i]]));
end;


memo1.Lines.Add(#13#10+'Orignal data:'+#13#10);
for i:=0 to 15 do begin
memo1.Text:=memo1.Text+(format('%u ',[dc[i]]));
end;



memo1.Lines.Add(#13#10+'Decoded data:'+#13#10);
for i:=0 to 15 do begin
memo1.Text:=memo1.Text+(format('%u ',[din[i]]));
end;


error:=false;
for i:=0 to 15 do begin
if din[i]<>dc[i] then
begin
memo1.Lines.Add(format('incorrect value %u',[i]));
error:=true;
end;
end;

memo1.Lines.Add(#13#10);

if not error then begin
memo1.Lines.Add(format('Cipher test passed OK!',[]));
end else begin
memo1.Lines.Add(format('Cipher test failed!',[]));
end;

end;
end.
