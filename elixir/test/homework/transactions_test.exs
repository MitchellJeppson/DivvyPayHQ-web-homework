defmodule Homework.TransactionsTest do
  use Homework.DataCase

  alias Ecto.UUID
  alias Homework.Merchants
  alias Homework.Transactions
  alias Homework.Users
  alias Homework.Companies

  describe "transactions" do
    alias Homework.Transactions.Transaction

    setup do
      {:ok, merchant1} =
        Merchants.create_merchant(%{description: "some description", name: "some name"})

      {:ok, merchant2} =
        Merchants.create_merchant(
          %{
            description: "some updated description",
            name: "some updated name"
          }
        )

      {:ok, company1} =
        Companies.create_company(
          %{
            name: "company one",
            description: "company one description",
            credit_line: 500,
            available_credit: 500
          }
        )

      {:ok, company2} =
        Companies.create_company(
          %{
            name: "company two",
            description: "company two description",
            credit_line: 1000,
            available_credit: 1000
          }
        )

      {:ok, user1} =
        Users.create_user(
          %{
            dob: "some dob",
            first_name: "some first_name",
            last_name: "some last_name",
            company_id: company1.id
          }
        )

      {:ok, user2} =
        Users.create_user(
          %{
            dob: "some updated dob",
            first_name: "some updated first_name",
            last_name: "some updated last_name",
            company_id: company2.id
          }
        )

      valid_attrs = %{
        amount: 40,
        credit: true,
        debit: true,
        description: "some description",
        merchant_id: merchant1.id,
        user_id: user1.id,
        company_id: company1.id
      }

      update_attrs = %{
        amount: 50,
        credit: false,
        debit: false,
        description: "some updated description",
        merchant_id: merchant2.id,
        user_id: user2.id,
        company_id: company2.id
      }

      invalid_attrs = %{
        amount: nil,
        credit: nil,
        debit: nil,
        description: nil,
        merchant_id: nil,
        user_id: nil,
        company_id: nil
      }

      {
        :ok,
        %{
          valid_attrs: valid_attrs,
          update_attrs: update_attrs,
          invalid_attrs: invalid_attrs,
          merchant1: merchant1,
          merchant2: merchant2,
          user1: user1,
          user2: user2,
          company1: company1,
          comapny2: company2
        }
      }
    end

    def transaction_fixture(valid_attrs, attrs \\ %{}) do
      {:ok, transaction} =
        attrs
        |> Enum.into(valid_attrs)
        |> Transactions.create_transaction()

      transaction
    end

    test "list_transactions/1 returns all transactions", %{valid_attrs: valid_attrs} do
      transaction = transaction_fixture(valid_attrs)
      assert Transactions.list_transactions([]) == [transaction]
    end

    test "list_transactions_between/2", %{valid_attrs: valid_attrs, update_attrs: update_attrs} do
      transaction1 = transaction_fixture(valid_attrs)
      # update_attrs is being used as an ordinary second transaction, not an update
      transaction2 = transaction_fixture(update_attrs)

      assert Transactions.list_transactions_between(transaction1.amount, transaction1.amount) == [transaction1]
      assert Transactions.list_transactions_between(transaction2.amount, transaction2.amount) == [transaction2]
      assert Transactions.list_transactions_between(100, 90) == []
      # This assertion assumes transaction2.amount is greater than transaction1.amount
      assert Transactions.list_transactions_between(transaction2.amount + 5, transaction1.amount - 5) == [transaction1, transaction2]
    end

    test "get_transaction!/1 returns the transaction with given id", %{valid_attrs: valid_attrs} do
      transaction = transaction_fixture(valid_attrs)
      assert Transactions.get_transaction!(transaction.id) == transaction
    end

    test "create_transaction/1 with valid data creates a transaction", %{
      valid_attrs: valid_attrs,
      merchant1: merchant1,
      user1: user1
    } do
      assert {:ok, %Transaction{} = transaction} = Transactions.create_transaction(valid_attrs)
      assert transaction.amount == valid_attrs.amount
      assert transaction.credit == valid_attrs.credit
      assert transaction.debit == valid_attrs.debit
      assert transaction.description == valid_attrs.description
      assert transaction.merchant_id == merchant1.id
      assert transaction.user_id == user1.id
      assert transaction.company_id == valid_attrs.company_id
    end

    test "create_transaction/1 with invalid data returns error changeset", %{
      invalid_attrs: invalid_attrs
    } do
      assert {:error, %Ecto.Changeset{}} = Transactions.create_transaction(invalid_attrs)
    end

    test "update_transaction/2 with valid data updates the transaction", %{
      valid_attrs: valid_attrs,
      update_attrs: update_attrs,
      merchant2: merchant2,
      user2: user2
    } do
      transaction = transaction_fixture(valid_attrs)

      assert {:ok, %Transaction{} = transaction} =
               Transactions.update_transaction(transaction, update_attrs)

      assert transaction.amount == update_attrs.amount
      assert transaction.credit == update_attrs.credit
      assert transaction.debit == update_attrs.debit
      assert transaction.description == update_attrs.description
      assert transaction.merchant_id == merchant2.id
      assert transaction.user_id == user2.id
      assert transaction.company_id == update_attrs.company_id
    end

    test "update_transaction/2 with invalid data returns error changeset", %{
      valid_attrs: valid_attrs,
      invalid_attrs: invalid_attrs
    } do
      transaction = transaction_fixture(valid_attrs)

      assert {:error, %Ecto.Changeset{}} =
               Transactions.update_transaction(transaction, invalid_attrs)

      assert transaction == Transactions.get_transaction!(transaction.id)
    end

    test "delete_transaction/1 deletes the transaction", %{valid_attrs: valid_attrs} do
      transaction = transaction_fixture(valid_attrs)
      assert {:ok, %Transaction{}} = Transactions.delete_transaction(transaction)
      assert_raise Ecto.NoResultsError, fn -> Transactions.get_transaction!(transaction.id) end
    end

    test "change_transaction/1 returns a transaction changeset", %{valid_attrs: valid_attrs} do
      transaction = transaction_fixture(valid_attrs)
      assert %Ecto.Changeset{} = Transactions.change_transaction(transaction)
    end
  end
end
