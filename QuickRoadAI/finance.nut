
function GetBalance(){
    return AICompany.GetBankBalance(AICompany.COMPANY_SELF);
}

function GetLoaned() {
    return AICompany.GetLoanAmount();
}

function GetLoanable() {
    return AICompany.GetMaxLoanAmount() - GetLoaned();
}

function GetAcquireableBalance() {
    return GetBalance() + GetLoanable();
}

function AcquireBalance(money) {
    // if we cannot loan this amount, fail
    if (GetAcquireableBalance() <= money)
        return false;
    
    // if we already have this amount, return success without doing anything
    if (GetBalance() > money)
        return true;
    
    // Get how much additional money we need
    local required_additional_money = money - GetBalance();
    // Add it to our current loan to get our required loaned amount
    local required_loan_amount = required_additional_money + GetLoaned();
    // Since we need a loan at least this large, calculate the loan one step above this
    local over_bracket = required_loan_amount % AICompany.GetLoanInterval();
    local loan = required_loan_amount - over_bracket + AICompany.GetLoanInterval();
    // Take out the loan
    AILog.Info("[Loan] Loaning " + loan + " to get required amount " + money);
    return AICompany.SetLoanAmount(loan);
}
