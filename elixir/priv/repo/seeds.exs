alias Homework.Repo
alias Homework.Companies.Company
alias Homework.Companies
alias Homework.Users.User
alias Homework.Merchants.Merchant
alias Homework.Transactions.Transaction


# Companies
%{id: company_one_id} = Repo.insert!(
  %Company{name: "Company One", description: "Company one description", credit_line: 1000, available_credit: 1000}
)
%{id: company_two_id} = Repo.insert!(
  %Company{name: "Company Two", description: "Company two description", credit_line: 30000, available_credit: 30000}
)
%{id: company_three_id} = Repo.insert!(
  %Company{name: "Company Three", description: "Company three description", credit_line: 0, available_credit: 0}
)

# Users
user_one = Repo.insert!(
  %User{first_name: "John", last_name: "Doe", dob: "01/17/2020", company_id: company_one_id}
)

user_two = Repo.insert!(
  %User{first_name: "Jane", last_name: "Doe", dob: "01/01/2018", company_id: company_one_id}
)

user_three = Repo.insert!(
  %User{first_name: "Ty", last_name: "Tidwell", dob: "08/21/1991", company_id: company_two_id}
)

# Merchants
%{id: merchant_one_id} = Repo.insert!(
  %Merchant{name: "Merchant_one", description: "Merchant one description"}
)

%{id: merchant_two_id} = Repo.insert!(
  %Merchant{name: "Merchant_two", description: "Merchant two description"}
)

%{id: merchant_three_id} = Repo.insert!(
  %Merchant{name: "Merchant_three", description: "Merchant three description"}
)

# Transactions
Repo.insert!(
  %Transaction{
    amount: 400,
    credit: true,
    debit: false,
    description: "Transaction one description",
    company_id: user_one.company_id,
    user_id: user_one.id,
    merchant_id: merchant_one_id
  }
)

Repo.insert!(
  %Transaction{
    amount: 200,
    credit: true,
    debit: false,
    description: "Transaction two description",
    company_id: user_one.company_id,
    user_id: user_one.id,
    merchant_id: merchant_two_id
  }
)

Repo.insert!(
  %Transaction{
    amount: 7000,
    credit: true,
    debit: false,
    description: "Transaction three description",
    company_id: user_three.company_id,
    user_id: user_three.id,
    merchant_id: merchant_three_id
  }
)

# Update available credit for all companies
Companies.update_available_credit(company_one_id)
Companies.update_available_credit(company_two_id)
Companies.update_available_credit(company_three_id)





