//******************************************************************************
// UCR framework, file: UnitCircularReferences.pas
// https://github.com/plamenjm/UCR-framework
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v.2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at: https://mozilla.org/MPL/2.0/.
//******************************************************************************

unit UnitCircularReferences;

//  Usage of UCR framework means to move unit initialization/finalization
//  code to a function and let UCR check the dependencies.
//  Adjust the behaviour with configurations. See the usage hints below.
//  For 'AfterInitialize' see 'UnitCircularReferencesFree.pas'.
//  It could be ignored or call it to free the resources:
//    'array[number of units] of TUCRClass', 'array of Status',
//    and 'TList' for all not initialized units (circular references).
//  AfterInitialize should be the initialized last - last unit in the project.
//  (Alternative, a unit which uses all other units will be initialized last).

{$INCLUDE UnitCircularReferencesDef.inc}

interface

uses
  System.Classes;

type
  TUnitCircularReferences = class;
  TUnitCircularReferencesClass = class of TUnitCircularReferences;
  TUCRClass = TUnitCircularReferencesClass;
  TUCRDepsArr = array of TUCRClass;
  TUnitCircularReferences = class
  private
    class var Config_Disable: Boolean;
    class var Config_NoLog: Boolean;
    class var Config_RaiseErr: Boolean;
    class var Config_ContinueAsOptimisticAsDelphiCompiler: Boolean;
    class var Units: array of TUCRClass;
    class var Status: array of (ucrNone, ucrInit, ucrFree);
    class var Requests: array of TList;
    class procedure RequestRemove(UnitIndex: Integer; UnitClass: TUCRClass);
    class function IndexOf(UnitClass: TUCRClass): Integer;
    class function InitRequest(FromUnit: TUCRClass; var AnyNewInit: Boolean): Boolean;
  protected
    class procedure Log(const Msg: string);
  public
    class procedure AfterInitialize; virtual;                      // Usage hint 6: free the resources - UnitCircularReferencesFree.pas
  protected
    class function Initialize(const LogMsg: string = ''): Boolean; // Usage hint 3: call from unit initialization
    class procedure Finalize;                                      // Usage hint 3: call from unit finalization
    class function Dependencies: TUCRDepsArr; virtual;
    class procedure DoInitialize; virtual;                         // Usage hint 2: your initialization code
    class procedure DoFinalize; virtual;                           // Usage hint 2: your finalization code
  end;

//--- Usage hint 1: add to unit interface.
//{$INCLUDE UnitCircularReferencesInt.inc}
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
//--- Usage hint 1: add to unit interface.

implementation

uses
  System.SysUtils;

{ TUnitCircularReferences }

class procedure TUnitCircularReferences.Log(const Msg: string);
begin
  if Config_NoLog then Exit;

  Writeln(Self.UnitName + ': ' + Msg); // Usage hint 5: replace with your log function
end;

class procedure TUnitCircularReferences.AfterInitialize;
begin
  for var unitIdx := Low(Units) to High(Units) do begin
    if not Assigned(Requests[unitIdx]) then Continue;
    var list := '';
    for var item in Requests[unitIdx] do begin
      const unitClass = TUCRClass(item);
      list := list + unitClass.UnitName + ', ';
    end;
    Log(Format('Not initialized - %s and %d dependant units: %s', [Units[unitIdx].UnitName, Requests[unitIdx].Count, list]));
    FreeAndNil(Requests[unitIdx]);
  end;
  SetLength(Units, 0);
  SetLength(Status, 0);
  SetLength(Requests, 0);
end;

class function TUnitCircularReferences.IndexOf(UnitClass: TUCRClass): Integer;
begin
  Result := -1;
  for var idx := Low(Units) to High(Units) do
    if Units[idx] = UnitClass then begin
      Result := idx;
      Break;
    end;

  if Result = -1 then begin
    Result := Length(Units);
    SetLength(Units, Result + 1);
    SetLength(Status, Result + 1);
    SetLength(Requests, Result + 1);
    Units[Result] := UnitClass;
  end;
end;

class procedure TUnitCircularReferences.RequestRemove(UnitIndex: Integer; UnitClass: TUCRClass);
begin
  if not Assigned(Requests[UnitIndex]) then Exit;
  Requests[UnitIndex].Remove(UnitClass);
  if Requests[UnitIndex].Count = 0 then
    FreeAndNil(Requests[UnitIndex]);
end;

class function TUnitCircularReferences.InitRequest(FromUnit: TUCRClass; var AnyNewInit: Boolean): Boolean;
begin
  var unitIdx := IndexOf(Self);
  if Status[unitIdx] = ucrInit then Exit(True);

  if not Assigned(Requests[unitIdx]) then
    Requests[unitIdx] := TList.Create
  else if Requests[unitIdx].IndexOf(FromUnit) >= 0 then begin
    const msg = Format('Circular reference %s from/to %s.', [FromUnit.UnitName, Self.UnitName]);
    if Config_RaiseErr then raise Exception.Create(Self.UnitName + ': ' + msg);
    Log(msg);
    Exit(False);
  end;

  Requests[unitIdx].Add(FromUnit);
  try
    Result := Initialize(' by ' + FromUnit.UnitName); // FromUnit depends of Self.
    AnyNewInit := AnyNewInit or Result;
  finally
    if Result then
      RequestRemove(unitIdx, FromUnit)
    else // Unsatisfied dependencies. FromUnit will be init after Self.
      Log('Added InitRequest for ' + FromUnit.UnitName);
  end;
end;

class function TUnitCircularReferences.Initialize(const LogMsg: string = ''): Boolean;
begin
  Log('initialization' + LogMsg);
  if Config_Disable then begin
    DoInitialize;
    Exit(True);
  end;

  var unitIdx := IndexOf(Self);
  if Status[unitIdx] = ucrInit then Exit(False);
  if Status[unitIdx] = ucrFree then Log('Initialize Again.');

  Result := False;
  while not Result do begin // init Self dependencies
    var anyNewInit := False;
    Result := True;
    for var unitClass in Dependencies do begin
      if not Assigned(unitClass) then Continue;
      const res = unitClass.InitRequest(Self, anyNewInit);
      Result := Result and res;
    end;
    if not anyNewInit then Break;
  end;

  if Config_ContinueAsOptimisticAsDelphiCompiler then Result := True;
  if not Result then Exit;

  Status[unitIdx] := ucrInit; // Self done
  for var uIdx := Low(Units) to High(Units) do // remove Self requests
    RequestRemove(uIdx, Self);
  DoInitialize;

  if not Assigned(Requests[unitIdx]) then Exit;
  var done := False;
  while not done do begin // init Self dependants
    var anyNewInit := False;
    done := True;
    for var item in Requests[unitIdx] do begin
      const unitClass = TUCRClass(item);
      const res = unitClass.InitRequest(Self, anyNewInit);
      done := done and res;
      if not Assigned(Requests[unitIdx]) then Break; // if cleared in InitRequest
    end;
    if not anyNewInit then Break;
  end;
  if done then FreeAndNil(Requests[unitIdx]);
end;

class procedure TUnitCircularReferences.Finalize;
begin
  Log('finalization');
  if Config_Disable then begin
    DoFinalize;
    Exit;
  end;

  var unitIdx := IndexOf(Self);
  FreeAndNil(Requests[unitIdx]);

  if Status[unitIdx] = ucrFree then
    Log('Already finalized.') // no exceptions in destructor
  else if Status[unitIdx] <> ucrInit then
    Log('Not initialized.')   // no exceptions in destructor
  else begin
    Status[unitIdx] := ucrFree;
    DoFinalize;
  end;
end;

class function TUnitCircularReferences.Dependencies: TUCRDepsArr;
begin
  Result := [];
  Log('Dependencies');
end;

class procedure TUnitCircularReferences.DoInitialize;
begin
  Log('DoInitialize');
end;

class procedure TUnitCircularReferences.DoFinalize;
begin
  Log('DoFinalize');
end;



//--- Usage hint 3: add to unit implementation.
{$ifNdef UCR_ONLY}
... all lines after 'implementation uses' and before 'TInit'
{$endif UCR_ONLY}

{ TInit }

class function TInit.Dependencies: TUCRDepsArr;
begin
  inherited;
  Result := [
    //DependencyUnitName.TInit, // Usage hint 4: list of units which should be initialized in advance.
    nil];
end;

class procedure TInit.DoInitialize;
begin
  inherited;
{$ifNdef UCR_ONLY}
... // Usage hint 2: move your initialization code here.
{$endif UCR_ONLY}
end;

class procedure TInit.DoFinalize;
begin
  inherited;
{$ifNdef UCR_ONLY}
... // Usage hint 2: move your finalization code here.
{$endif UCR_ONLY}
end;

//{$INCLUDE UnitCircularReferencesImpl.inc}
initialization
  // Usage hint 5: adjust settings here, do not add settings to unit implementation.
{$ifNdef UCR_ONLY}
  TUnitCircularReferences.Config_Disable := True;
{$endif UCR_ONLY}
  //TUnitCircularReferences.Config_NoLog := True;
  //TUnitCircularReferences.Config_RaiseErr := True;
  //TUnitCircularReferences.Config_ContinueAsOptimisticAsDelphiCompiler := True;

{$ifdef UCR_DEMO}
  TInit.Initialize;
{$endif UCR_DEMO}

finalization
{$ifdef UCR_DEMO}
  TInit.Finalize;
  Readln;
{$endif UCR_DEMO}
//--- Usage hint 3: add to unit implementation.

end.

