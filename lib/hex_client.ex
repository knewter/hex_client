defmodule HexClient do
  use HTTPoison.Base

  @base_url "https://hex.pm/api/"
  @packages_sort "name"

  @doc """
    Will fetch all packages from hex ordered by name.

    Returns: A list of Packages.
  """
  def packages do
    packages_stream |> Enum.to_list
  end

  # Helper for newest packages.
  def packages_newest(amount \\ 100) do
    packages_stream("inserted_at") |> Enum.take(amount)
  end

  # Helper for most downloaded.
  def packages_most_downloaded(amount \\ 100) do
    packages_stream("downloads") |> Enum.take(amount)
  end

  @doc """
    Will fetch the packages from hex ordered by given sort key.

    Sortable by:
      name downloads inserted_at updated_at

    Returns: A Stream of Packages.
  """
  def packages_stream(sort \\ @packages_sort) do
    # Starting from page number 1 up,
    # asking the API till we reach first empty page.
    Stream.unfold(1, fn page ->
      case packages_page(page, sort) do
        # No more packages
        [] -> nil
        # Error occured
        nil -> nil
        # Request next page with next unfold
        body -> {body, page+1}
      end
    end)
    |> Stream.flat_map(fn x -> x end)
  end

  @doc """
    Will fetch a package by name.

    Returns: The data for the package or nil.
  """
  def package(name) do
    package_path(name) |> get_body
  end

  @doc """
    Will fetch info for a package version.

    Returns: The data for the package version or nil.
  """
  def package(name, version) do
    package_path(name, version) |> get_body
  end

  @doc """
    Will fetch the url for downloading docs.

    Returns: The data for the package version or nil.
  """
  def package_docs_download(name, version) do
    {:ok, %HTTPoison.Response{headers: headers, status_code: status_code}} = package_docs_path(name, version) |> get
    case status_code do
      302 ->
        %{"Location"=> url} = headers
        url
      _ -> nil
    end
  end

  # TODO: Implement calls using authentication.

  # Get a given page of packags
  defp packages_page(page, sort) do
    packages_path(page, sort) |> get_body
  end

  # Fetch the Response body for given path or return nil
  defp get_body(path) do
    case get(path) do
      {:ok, %HTTPoison.Response{body: body, status_code: 200}} -> body |> Poison.decode!
      _ -> nil
    end
  end

  defp packages_path(page, sort), do: "packages?page=#{page}&sort=#{sort}"
  defp package_path(name), do: "packages/#{name}"
  defp package_path(name, version), do: "packages/#{name}/releases/#{version}"
  defp package_docs_path(name, version), do: "packages/#{name}/releases/#{version}/docs"
  defp process_url(url), do: @base_url <> url
end
