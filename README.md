
### UCR framework - Unit Circular References

---

Here, the usage notes from `UnitCircularReferencesFree.pas`.

```
//  Usage of UCR framework means to move unit initialization/finalization
//  code to a function and let UCR check the dependencies.
//  Adjust the behaviour with configurations:
//    'Config_Disable', 'Config_NoLog', 'Config_RaiseErr',
//    or 'Config_ContinueAsOptimisticAsDelphiCompiler'.
//  See the usage hints below.
//  For 'AfterInitialize' see 'UnitCircularReferencesFree.pas'.
//  It could be ignored or call it to free the resources:
//    'array[number of units] of TUCRClass', 'array of Status',
//    and 'TList' for all not initialized units (circular references).
//  AfterInitialize should be the initialized last - last unit in the project.
//  (Alternative, a unit which uses all other units will be initialized last).
```

---

And output from the demo console app:

```
UnitCircularReferences: initialization
UnitCircularReferences: Dependencies
UnitCircularReferences: DoInitialize
UnitCCC: initialization
UnitBB: initialization
UnitA: initialization by UnitBB
UnitBB: initialization by UnitA
UnitA: Circular reference UnitBB from/to UnitA.
UnitBB: Added InitRequest for UnitA
UnitA: Added InitRequest for UnitBB
UnitA: initialization
UnitBB: Circular reference UnitA from/to UnitBB.
UnitCircularReferences: Not initialized - UnitBB and 1 dependant units: UnitA,
UnitCircularReferences: Not initialized - UnitA and 1 dependant units: UnitBB,
Done.

UnitA: finalization
UnitA: Not initialized.
UnitBB: finalization
UnitBB: Not initialized.
UnitCCC: finalization
UnitCCC: Not initialized.
UnitCircularReferences: finalization
UnitCircularReferences: Not initialized.
```
