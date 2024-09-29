program DemoCircularReferences;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  UnitCircularReferences in 'UnitCircularReferences.pas',
  UnitCircularReferencesFree in 'UnitCircularReferencesFree.pas',
  UnitA in 'UnitA.pas',
  UnitBB in 'UnitBB.pas',
  UnitCCC in 'UnitCCC.pas';

begin
  Writeln('Done.');
  Readln;
end.
