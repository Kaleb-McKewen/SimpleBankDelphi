{
Banking Unit for
 a simple banking server,
allowing account creation, withdraw, deposit and mini summary
}
unit uBank;

interface

uses Generics.Collections, SysUtils, RTTI;

type
  {
  TransactionType Enum Class
  Used to set constraints on Transaction Types allowed
  Only depositing and withdrawing values allowed
  }
  TTransactionType = (depositing, withdrawing);

  {
  Transaction Class
  Used for storing details for a single transaction of a bank account
  }
  TTransaction = class
    private
      FTransactionId: integer;
      FStartingAmount: Currency;
      FEndingAmount: Currency;
      FAmount: Currency;
      FType: TTransactionType;

    protected
      constructor Create(TransactionId: integer; StartingAmount,EndingAmount,Amount: Currency; _Type: TTransactionType);
      destructor Destroy; override;

    public
      function output:String;
  end;


  {
  Account Class
  Used for storing attributes for a single account in a bank
  Holds the ID, balance and list of transactions
  }
  TAccount = class
  private
    FAccountId: integer;
    FBalance: currency;
    FTransactions: TList<TTransaction>;


  protected
    constructor Create(accoundId: integer);
    destructor Destroy; override;

  public
    function getBalance: Currency;
    procedure deposit(amount: Currency);
    procedure withdrawal(amount: Currency);
    function miniStatement: String;
  end;


  {
  Bank Class
  Represents a single bank that may include many accounts
  When the bank is destroyed so are the associated accounts
  Accounts can be instantiated through the bank class
  }
  TBank = class
    private FAccounts: TList<TAccount>;

    public
      constructor Create;
      destructor Destroy; override;
      function CreateAccount: TAccount;
  end;



implementation

  //Transaction Class Implementation Section
  constructor TTransaction.Create(TransactionId: Integer; StartingAmount: Currency; EndingAmount: Currency; Amount: Currency; _Type: TTransactionType);
  begin
      self.FTransactionId := TransactionId;
      self.FStartingAmount := StartingAmount;
      self.FEndingAmount := EndingAmount;
      self.FAmount := Amount;
      self.FType := _Type;
  end;

  destructor TTransaction.Destroy;
    begin
      inherited;
    end;

    //used to output all attributes to readable string
  function TTransaction.output: string;
    begin
      Result:= ('TransactionID:'+IntToStr(self.FTransactionId)+' Starting:'+CurrToStr(self.FStartingAmount)+' Amount:'+CurrToStr(self.FAmount)+' Type:'+TRttiEnumerationType.GetName(self.FType)+' Ending:'+CurrToStr(self.FEndingAmount));
    end;



  //Account Class Implementation Section
  constructor TAccount.Create(accoundId: Integer);
  begin
      self.FAccountId := accoundId;
      self.FTransactions := TList<TTransaction>.Create;
      //default balance
      self.FBalance := 0;
  end;

  destructor TAccount.Destroy;
    var i : integer;
    begin
      //free memory of each transactions associated
      For i := 0 to self.FTransactions.count-1 do
      begin
           self.FTransactions[i].free;
      end;
      self.FTransactions.Free;

      inherited;
    end;

    //function to retrieve the account balance
    function TAccount.getBalance: Currency;
    begin
      Result := self.FBalance;
    end;

    {
    procedure to deposit/add to balance
    accepts amount: Currency (positive)
    }
    procedure TAccount.deposit(amount: Currency);
    var originalAmount: Currency;
    var createdTransaction: TTransaction;

    begin
    //ensure amount is not negative or zero to prevent math error
      if amount <= 0 then raise Exception.Create('Cannot use negative or zero amounts');
      originalAmount := self.FBalance;
      //update balance
      self.FBalance := self.FBalance + amount;
      //create and save transaction
      createdTransaction := TTransaction.Create(self.FTransactions.Count+1, originalAmount, self.FBalance, amount, depositing);
      self.FTransactions.add(createdTransaction);
    end;

    {
    procedure to withdraw/remove from balance
    accepts amount: Currency (positive)
    }
    procedure TAccount.withdrawal(amount: Currency);
    var originalAmount: Currency;
    var createdTransaction: TTransaction;
    begin
      //ensure amount is not negative or zero to prevent math error
      if amount <= 0 then raise Exception.Create('Cannot use negative or zero amounts');
      //ensure there is enough balance avaliable for withdrawal, if not throw exception
      if self.FBalance - amount < 0 then raise Exception.Create('Cannot process due to insufficient funds');
      originalAmount := self.FBalance;
      //update balance
      self.FBalance := self.FBalance - amount;
       //create and save transaction
      createdTransaction:=TTransaction.Create(self.FTransactions.Count+1, originalAmount, self.FBalance, amount, withdrawing);
      self.FTransactions.add(createdTransaction);
    end;

    {
    function to generate a mini statement of all transactions in string form seperated by semicolon
    }
    function TAccount.miniStatement: string;
    var outputStr: String;
    var i: integer;
    begin
      //for loop to go through each transaction
      For i := 0 to self.FTransactions.count-1 do
      begin
          outputStr := outputStr + self.FTransactions[i].output + ';'
      end;
      //remove excess
      delete(outputStr, length(outputStr),1);
      Result := outputStr
    end;


  //Bank Class Implementation Section
  constructor TBank.Create;
  begin
    self.FAccounts := TList<TAccount>.Create;
  end;

  destructor TBank.Destroy;
    begin
      //free memory of accounts associated
      self.FAccounts.Free;
      inherited;
    end;

  {
  function to create an account with unique ID
  Returns associated account to be used
  }
  function TBank.CreateAccount: TAccount;
  var
    createdAccount: TAccount;
  begin
      createdAccount:=TAccount.Create(self.FAccounts.Count+1);
      self.FAccounts.add(createdAccount);
      Result := createdAccount;

  end;

end.


