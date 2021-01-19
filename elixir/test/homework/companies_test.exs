defmodule Homework.CompaniesTest do
  use Homework.DataCase

  alias Homework.Companies

  describe "companies" do
    alias Homework.Companies.Company

    @valid_attrs %{
      name: "some name",
      description: "some description",
      credit_line: 500,
      available_credit: 500
    }
    @update_attrs %{
      name: "some updated name",
      description: "some updated description",
      credit_line: 501,
      available_credit: 501
    }
    @invalid_attrs %{
      name: nil,
      description: nil,
      credit_line: nil,
      available_credit: nil
    }

    def company_fixture(attrs \\ %{}) do
      {:ok, company} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Companies.create_company()

      company
    end

    test "list_companies/1 returns all companies" do
      company = company_fixture()
      assert Companies.list_companies([]) == [company]
    end

    test "get_company!/1 returns the company with given id" do
      company = company_fixture()
      assert Companies.get_company!(company.id) == company
    end

    test "create_company/1 with valid data creates a company" do
      assert {:ok, %Company{} = company} = Companies.create_company(@valid_attrs)
      assert company.name == @valid_attrs.name
      assert company.description == @valid_attrs.description
      assert company.credit_line == @valid_attrs.credit_line
      assert company.available_credit == @valid_attrs.available_credit
    end

    test "create_company/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Companies.create_company(@invalid_attrs)
    end

    test "update_company/2 with valid data updates the company" do
      company = company_fixture()
      assert {:ok, %Company{} = company} = Companies.update_company(company, @update_attrs)
      assert company.name == @update_attrs.name
      assert company.description == @update_attrs.description
      assert company.credit_line == @update_attrs.credit_line
      assert company.available_credit == @update_attrs.available_credit
    end

    test "update_company/2 with invalid data returns error changeset" do
      company = company_fixture()
      assert {:error, %Ecto.Changeset{}} = Companies.update_company(company, @invalid_attrs)
      assert company == Companies.get_company!(company.id)
    end

    test "delete_company/1 deletes the company" do
      company = company_fixture()
      assert {:ok, %Company{}} = Companies.delete_company(company)
      assert_raise Ecto.NoResultsError, fn -> Companies.get_company!(company.id) end
    end

    test "change_company/1 returns a company changeset" do
      company = company_fixture()
      assert %Ecto.Changeset{} = Companies.change_company(company)
    end

    # I would like to test this method here, but I am not seeing a good way to do it.
    # My first thought was to load in a few companies and transactions into a setup function,
    # then call the update function and assert the correct available_credit values, but that
    # would require at least calling create_company/1 in the setup function, which seems like
    # bad practice. In transactions_test they are able to initialize all upstream objects and
    # then initialize the transactions within each test, we can't do that here because you need
    # company_id to create a transaction. Maybe a separate file for integration tests would be
    # better suited.
    #    test "update_available_credit/1 returns company with updated available_credit" do
    #      company = company_fixture()
    #      assert {:ok, %Company{} = _company} = Companies.update_available_credit(company.id)
    #    end

  end
end
