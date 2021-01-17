defmodule HomeworkWeb.Resolvers.TransactionsResolver do
  alias Homework.Merchants
  alias Homework.Transactions
  alias Homework.Users
  alias HomeworkWeb.Resolvers.CompaniesResolver

  @doc """
  Get a list of transactions
  """
  def transactions(_root, args, _info) do
    {:ok, Transactions.list_transactions(args)}
  end

  @doc """
  Get a list of transactions between min and max
  """
  def transactions_between(_root, %{max: max, min: min}, _info) do
    {:ok, Transactions.list_transactions_between(max, min)}
  end

  @doc """
  Get the user associated with a transaction
  """
  def user(
        _root,
        _args,
        %{
          source: %{
            user_id: user_id
          }
        }
      ) do
    {:ok, Users.get_user!(user_id)}
  end

  @doc """
  Get the merchant associated with a transaction
  """
  def merchant(
        _root,
        _args,
        %{
          source: %{
            merchant_id: merchant_id
          }
        }
      ) do
    {:ok, Merchants.get_merchant!(merchant_id)}
  end

  @doc """
  Create a new transaction
  """
  def create_transaction(_root, args, _info) do
    case Transactions.create_transaction(args) do
      {:ok, transaction} ->
        # could we get the change in credit here to avoid querying all transactions on each update?
        # is this what changesets are for? Are they describing what is changing?
        # could definitely be slow once transactions list gets long
        CompaniesResolver.update_company_available_credit(transaction, Map.get(args, :company_id))

      error ->
        {:error, "could not create transaction: #{inspect(error)}"}
    end
  end

  @doc """
  Updates a transaction for an id with args specified.
  """
  def update_transaction(_root, %{id: id, company_id: company_id} = args, _info) do
    transaction = Transactions.get_transaction!(id)

    case Transactions.update_transaction(transaction, args) do
      {:ok, transaction} ->
        # Similar to create_transaction, could we determine if amount is being updated and
        # only updated available_credit when it is necessary?
        CompaniesResolver.update_company_available_credit(transaction, company_id)
      error ->
        {:error, "could not update transaction: #{inspect(error)}"}
    end
  end

  @doc """
  Deletes a transaction for an id
  """
  def delete_transaction(_root, %{id: id}, _info) do
    transaction = Transactions.get_transaction!(id)

    case Transactions.delete_transaction(transaction) do
      {:ok, transaction} ->
        # This process could be improved by instead of querying all transactions, just
        # directly reducing the available_credit on the given company
        CompaniesResolver.update_company_available_credit(transaction, transaction.company_id)
      error ->
        {:error, "could not update transaction: #{inspect(error)}"}
    end
  end
end
