unit UnitCircularReferencesFree;

interface

implementation

uses
//  AfterInitialize should be the initialized last - last unit in the project.
//  (Alternative, a unit which uses all other units will be initialized last).
  UnitA, UnitBB, UnitCCC, // Usage hint 6
  UnitCircularReferences;

initialization
  TUnitCircularReferences.AfterInitialize;

end.
