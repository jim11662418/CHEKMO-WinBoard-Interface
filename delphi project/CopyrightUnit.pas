unit CopyrightUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, VrControls, VrLabel, ExtCtrls, VrButtons, Buttons;

type
  TCopyrightForm = class(TForm)
    Panel1: TPanel;
    lbDescription: TLabel;
    lbVersion: TLabel;
    lbCopyright: TLabel;
    OKButton: TBitBtn;
    Image1: TImage;
    procedure FormCreate(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CopyrightForm: TCopyrightForm;

implementation

{$R *.dfm}

procedure TCopyrightForm.FormCreate(Sender: TObject);
const
    InfoNum = 10;
    InfoStr: array[1..InfoNum] of string = ('CompanyName', 'FileDescription', 'FileVersion', 'InternalName', 'LegalCopyright', 'LegalTradeMarks', 'OriginalFileName', 'ProductName', 'ProductVersion', 'Comments');
var
    CompanyName,FileDescription,FileVersion,InternalName,LegalCopyright,LegalTradeMarks,OriginalFileName,ProductName,ProductVersion,Comments: string;
    S: string;
    n, Len, i: DWORD;
    Buf, Value: PChar;

begin
    S := Application.ExeName; //this application's EXE filename
    n := GetFileVersionInfoSize(PChar(S), n); // the return value is the size in bytes of the file's version information.
    if n > 0 then
       begin
          Buf := AllocMem(n); // allocate the needed amount of memory into the buffer
          GetFileVersionInfo(PChar(S), 0, n, Buf); // store the file version information in the memory buffer. it stores all of the values listed in the InfoStr array.
          for i := 1 to InfoNum do
                if VerQueryValue(Buf, PChar('StringFileInfo\040904E4\' + InfoStr[i]), Pointer(Value), Len) then
                     if trim(lowerCase(InfoStr[i])) = 'companyname' then
                         CompanyName := Value
                     else if trim(lowerCase(InfoStr[i])) = 'filedescription' then
                         FileDescription := Value
                     else if trim(lowerCase(InfoStr[i])) = 'fileversion' then
                         FileVersion := Value
                     else if trim(lowerCase(InfoStr[i])) = 'internalname' then
                         InternalName := Value
                     else if trim(lowerCase(InfoStr[i])) = 'legalcopyright' then
                         LegalCopyright := Value
                     else if trim(lowerCase(InfoStr[i])) = 'legaltrademarks' then
                         LegalTrademarks := Value
                     else if trim(lowerCase(InfoStr[i])) = 'originalfilename' then
                         OriginalFileName := Value
                     else if trim(lowerCase(InfoStr[i])) = 'productname' then
                         ProductName := Value
                     else if trim(lowerCase(InfoStr[i])) = 'productversion' then
                         ProductVersion := Value
                     else if trim(lowerCase(InfoStr[i])) = 'comments' then
                         Comments := Value;
                FreeMem(Buf, n); // free the memory we stored in the buffer.
       end;
   lbVersion.Caption := 'Version: '+FileVersion;
   lbVersion.Alignment := taCenter; 
   lbDescription.Caption := FileDescription;
   lbCopyright.Caption := LegalCopyright;
end;

procedure TCopyrightForm.OKButtonClick(Sender: TObject);
begin
   ModalResult := mrOK;
end;

end.
