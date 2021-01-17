defmodule HomeworkWeb.Resolvers.CompaniesResolver do
  alias Homework.Companies

  @doc """
  Get a list of companies
  """
  def companies(_root, args, _info) do
    {:ok, Companies.list_companies(args)}
  end

  @doc """
  Create a new company
  """
  def create_company(_root, args, _info) do
    argsWithAvailableCredit = Map.put(args, :available_credit, Map.get(args, :credit_line))
    case Companies.create_company(argsWithAvailableCredit) do
      {:ok, company} ->
        {:ok, company}

      error ->
        {:error, "could not create company: #{inspect(error)}"}
    end
  end

  @doc """
  Updates a company for an id with args specified.
  """
  def update_company(_root, %{id: id} = args, _info) do
    company = Companies.get_company!(id)

    case Companies.update_company(company, args) do
      {:ok, company} ->
        update_company_available_credit(company, id)

      error ->
        {:error, "could not update company: #{inspect(error)}"}
    end
  end

  @doc """
  Deletes a company for an id
  """
  def delete_company(_root, %{id: id}, _info) do
    company = Companies.get_company!(id)

    case Companies.delete_company(company) do
      {:ok, company} ->
        {:ok, company}

      error ->
        {:error, "could not update company: #{inspect(error)}"}
    end
  end

  @doc """
  Internal method to update company available credit on changes to transactions
  """
  def update_company_available_credit(object, id) do
    case Companies.update_available_credit(id) do
      {:ok, company} ->
        # I'm sure there is a way to determine if the 'object' is of type company, that would be cleaner
        object = Map.put(object, :available_credit, company.available_credit)
        {:ok, object}
      error ->
        {:error, "could not update company available credit #{inspect(error)}"}
    end
  end
end
