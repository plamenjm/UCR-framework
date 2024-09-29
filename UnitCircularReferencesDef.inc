
{$define UCR_ONLY}
{$define UCR_DEMO}



//{$define UCR_TestCase1}
//{$define UCR_TestCase2}
//{$define UCR_TestCase3}
{$define UCR_TestCase4}
//{$define UCR_TestCase6}
//{$define UCR_TestCase7}
//{$define UCR_TestCase8}
// Any other use cases?

{$ifdef UCR_TestCase1}
  // EXPECT: A, BB, CCC
  //{$define UCR_DepsNext}
  //{$define UCR_DepsPrev}
  //{$define UCR_DepsCircular}
{$else UCR_TestCase1}
{$ifdef UCR_TestCase2}
  // EXPECT: CCC, BB, A
  {$define UCR_DepsNext}
  //{$define UCR_DepsPrev}
  //{$define UCR_DepsCircular}
{$else UCR_TestCase2}
{$ifdef UCR_TestCase3}
  // EXPECT: CCC, A, BB
  //{$define UCR_DepsNext}
  {$define UCR_DepsPrev}
  //{$define UCR_DepsCircular}
{$else UCR_TestCase3}
{$ifdef UCR_TestCase4}
  // EXPECT: CCC, BB, A(BB), BB(A), dup BB>A, A, dup A>BB; pending BB+A, A+BB
  {$define UCR_DepsNext}
  {$define UCR_DepsPrev}
  //{$define UCR_DepsCircular}
{$else UCR_TestCase4}
{$ifdef UCR_TestCase6}
  // EXPECT: CCC, A(CCC), BB(A), CCC(BB), dup CCC>A, BB, dup BB>CCC, A, dup A>BB; pending CCC+BB, A+CCC, BB+A
  {$define UCR_DepsNext}
  //{$define UCR_DepsPrev}
  {$define UCR_DepsCircular}
{$else UCR_TestCase6}
{$ifdef UCR_TestCase7}
  // EXPECT: BB, A(BB), CCC(A), BB(CCC), dup BB>A, CCC, dup CCC>BB, A, dup A>CCC; pending BB+CCC, A+BB, CCC+A
  //{$define UCR_DepsNext}
  {$define UCR_DepsPrev}
  {$define UCR_DepsCircular}
{$else UCR_TestCase7}
{$ifdef UCR_TestCase8}
  // EXPECT: CCC, A(CCC), BB(A), CCC(BB), dup CCC>A, BB(CCC), dup BB>CCC, A(BB), dup A>BB, CCC(A), dup CCC>A, dup CCC>B
  // EXPECT: dup BB>A, dup A>CCC, dup CCC>BB, dup BB>CCC, dup BB>A, A, dup A>BB, dup A>CCC; pending CCC+BB+A, A+CCC+BB, BB+A+CCC
  {$define UCR_DepsNext}
  {$define UCR_DepsPrev}
  {$define UCR_DepsCircular}
{$endif UCR_TestCase8} {$endif UCR_TestCase7} {$endif UCR_TestCase6} {$endif UCR_TestCase4} {$endif UCR_TestCase3} {$endif UCR_TestCase2}
{$endif UCR_TestCase1}

