unit UnitBB;

{$INCLUDE UnitCircularReferencesDef.inc}

interface

uses
  {$ifdef UCR_DepsNext} UnitCCC, {$endif UCR_DepsNext}
//
  UnitCircularReferences;

type
  TInit = class(TUnitCircularReferences)
  protected
    class function Dependencies: TUCRDepsArr; override;
    class procedure DoInitialize; override;
    class procedure DoFinalize; override;
  end;

{$ifNdef UCR_ONLY}
... all lines after 'interface TInit' and before 'implementation'
{$endif UCR_ONLY}

implementation

uses
//
//
  {$ifdef UCR_DepsPrev} UnitA  , {$endif UCR_DepsPrev}
//
  System.Types; // dummy

{$ifNdef UCR_ONLY}
... all lines after 'implementation uses' and before 'TInit'
{$endif UCR_ONLY}

{ TInit }

class function TInit.Dependencies: TUCRDepsArr;
begin
  Result := [

    {$ifdef UCR_DepsNext} UnitCCC.TInit, {$endif UCR_DepsNext}
    {$ifdef UCR_DepsPrev} UnitA  .TInit, {$endif UCR_DepsPrev}

    nil]; // dummy
end;

class procedure TInit.DoInitialize;
begin
{$ifNdef UCR_ONLY}
... // Usage hint 2: move your initialization code here.
{$endif UCR_ONLY}
end;

class procedure TInit.DoFinalize;
begin
{$ifNdef UCR_ONLY}
... // Usage hint 2: move your finalization code here.
{$endif UCR_ONLY}
end;

initialization
  TInit.Initialize;

finalization
  TInit.Finalize;

end.

