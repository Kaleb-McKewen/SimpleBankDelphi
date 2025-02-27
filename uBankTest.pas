{
Bank Test Unit
Used to test and develop the Bank Unit using TDD
Tests were created before class methods were developed
}
unit uBankTest;

interface

uses
  DUnitX.TestFramework, uBank;

type
  [TestFixture]

  TestBank = class
  private
    ObjBank : TBank;
    ObjAccount: TAccount;

  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    //account test
    //creating an account and checking default balance
    [TestCase ('TestCreateAccount', '0')]
    procedure TestCreateAccount(Expected: Currency);


    //deposit tests
    //simple deposit
    [TestCase ('TestSimpleDeposit', '100, 100')]
    //decimal test
    [TestCase ('TestDecimalDeposit', '12.53, 12.53')]
    procedure TestDeposit(DepositAmount, Expected: Currency);
    //multiple deposit test
    [TestCase('TestMultiDeposit','50,60,110')]
    procedure TestDepositMulti(DepositAmount, DepositAmount2, Expected: Currency);
    //negative exception handling test
    [TestCase ('TestNegativeNumberDeposit', '-1,0,Cannot use negative or zero amounts')]
    //zero exception handling test
    [TestCase ('TestZeroDeposit', '0, 0,Cannot use negative or zero amounts')]
    procedure TestErrorDeposit(DepositAmount, Expected: Currency; ExceptionMessage: String);


    //withdrawal tests
    //simple withdrawal test
    [TestCase ('TestSimpleWithdrawal', '200, 100, 100')]
    //decimal test
    [TestCase ('TestDecimalWithdrawal', '53.1, 12.53, 40.57')]
    procedure TestWithdrawal(OpeningAmount,WithdrawalAmount, Expected: Currency);
    //multiple withdrawal test
    [TestCase('TestMultiWithdrawal','150,60,50,40')]
    procedure TestWithdrawalMulti(OpeningAmount, WithdrawalAmount, WithdrawalAmount2, Expected: Currency);
    //negative exception handling test
    [TestCase ('TestNegativeNumberWithdrawal', '100,-1,100,Cannot use negative or zero amounts')]
    //zero exception handling test
    [TestCase ('TestZeroWithdrawal', '100, 0, 100,Cannot use negative or zero amounts')]
    //overdraw exception handing test
    [TestCase ('TestOverdrawal', '1,200,1,Cannot process due to insufficient funds')]
    procedure TestErrorWithdrawal(OpeningAmount,WithdrawalAmount,Expected: Currency; ExceptionMessage: String);


    //transaction tests
    //simple statement test
    [TestCase ('TestMiniStatementOutput', '100,TransactionID:1 Starting:0 Amount:100 Type:Depositing Ending:100')]
    procedure TestMiniStatementOutput(DepositAmount: Currency; Expected:String);
    //empty test
    [TestCase ('TestEmptyMiniStatementOutput', '')]
    procedure TestEmptyMiniStatementOutput(Expected:String);
    //deposit and withdraw statement test
    [TestCase ('TestMultiMiniStatementOutput', '51.31,50.2,TransactionID:1 Starting:0 Amount:51.31 Type:Depositing Ending:51.31;TransactionID:2 Starting:51.31 Amount:50.2 Type:Withdrawing Ending:1.11')]
    procedure TestMultiMiniStatementOutput(DepositAmount, WithdrawalAmount: Currency; Expected:String);
    //negative exception handing statement test
    [TestCase ('TestNegativeMiniStatementOutput', '5,-10,Cannot use negative or zero amounts,TransactionID:1 Starting:0 Amount:5 Type:Depositing Ending:5')]
    //overdraw exception handing statement test
    [TestCase ('TestOverDrawMiniStatementOutput', '70,100,Cannot process due to insufficient funds,TransactionID:1 Starting:0 Amount:70 Type:Depositing Ending:70')]
    procedure TestMultiMiniStatementErrorOutput(DepositAmount, WithdrawalAmount: Currency; ExceptionMessage, Expected:String);

  end;

implementation

procedure TestBank.Setup;
begin
  ReportMemoryLeaksOnShutdown := True;
  ObjBank := TBank.create;
  ObjAccount :=ObjBank.CreateAccount();
end;

procedure TestBank.TearDown;
begin
  ObjAccount.Free;
  ObjBank.Free;
end;


//test if an account can be made and check starting balance
procedure TestBank.TestCreateAccount(Expected: Currency);
begin
    Assert.AreEqual(ObjAccount.getBalance, Expected);
end;



//test if an account can be deposited to by checking balance
procedure TestBank.TestDeposit(DepositAmount: Currency; Expected: Currency);
begin
   ObjAccount.deposit(DepositAmount);
   Assert.AreEqual(ObjAccount.getBalance, Expected);
end;

//test if an account can be deposited to multiple times by checking balance
procedure TestBank.TestDepositMulti(DepositAmount, DepositAmount2: Currency; Expected: Currency);
begin
   ObjAccount.deposit(DepositAmount);
   ObjAccount.deposit(DepositAmount2);
   Assert.AreEqual(ObjAccount.getBalance, Expected);
end;

//test zero handling and expected balance after error
procedure TestBank.TestErrorDeposit(DepositAmount, Expected: Currency; ExceptionMessage: String);
begin
   Assert.WillRaiseWithMessage(procedure
    begin
   ObjAccount.deposit(DepositAmount)
   end, nil, ExceptionMessage);
   Assert.AreEqual(ObjAccount.getBalance, Expected);
end;


//test if an account can be deposited to then withdrawn from by checking balance
procedure TestBank.TestWithdrawal(OpeningAmount: Currency; WithdrawalAmount: Currency; Expected: Currency);
begin
    ObjAccount.deposit(OpeningAmount);
    ObjAccount.withdrawal(WithdrawalAmount);
    Assert.AreEqual(ObjAccount.getBalance, Expected);
end;

//test if an account can be deposited to then withdrawn from multiple times by checking balance
procedure TestBank.TestWithdrawalMulti(OpeningAmount: Currency; WithdrawalAmount: Currency; WithdrawalAmount2: Currency; Expected: Currency);
begin
  ObjAccount.deposit(OpeningAmount);
  ObjAccount.withdrawal(WithdrawalAmount);
  ObjAccount.withdrawal(WithdrawalAmount2);
  Assert.AreEqual(ObjAccount.getBalance, Expected);
end;

//test withdrawn, zero handling and expected balance after error
procedure TestBank.TestErrorWithdrawal(OpeningAmount: Currency; WithdrawalAmount: Currency; Expected: Currency; ExceptionMessage: string);
begin
   ObjAccount.deposit(OpeningAmount);
   Assert.WillRaiseWithMessage(procedure
    begin
   ObjAccount.withdrawal(WithdrawalAmount)
   end, nil, ExceptionMessage);
end;


//test if an account can be deposited to and a mini statement can be generated with an expected value
procedure TestBank.TestMiniStatementOutput(DepositAmount: Currency; Expected: string);
begin
   ObjAccount.deposit(DepositAmount);
   Assert.AreEqual(ObjAccount.miniStatement, Expected);
end;

//test to ensure an empty transaction prints an empty output
procedure TestBank.TestEmptyMiniStatementOutput(Expected: string);
begin
  Assert.AreEqual(ObjAccount.miniStatement,'');
end;

//test if an account can be deposited to then withdrawn from and a mini statement can be generated with an expected value
procedure TestBank.TestMultiMiniStatementOutput(DepositAmount: Currency; WithdrawalAmount: Currency; Expected: string);
begin
  ObjAccount.deposit(DepositAmount);
  ObjAccount.withdrawal(WithdrawalAmount);
  Assert.AreEqual(ObjAccount.miniStatement, Expected);

end;

//test if a mini statement can be generated with an expected value after generating an exception during withdraw
procedure TestBank.TestMultiMiniStatementErrorOutput(DepositAmount: Currency; WithdrawalAmount: Currency; ExceptionMessage, Expected: string);
begin
   ObjAccount.deposit(DepositAmount);
   Assert.WillRaiseWithMessage(procedure
    begin
   ObjAccount.withdrawal(WithdrawalAmount)
   end, nil, ExceptionMessage);
   Assert.AreEqual(ObjAccount.miniStatement, Expected);
end;

initialization
  TDUnitX.RegisterTestFixture(TestBank);
end.

