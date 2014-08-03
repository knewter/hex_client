defmodule HexClient do
  use HTTPoison.Base

  @base_url "https://hex.pm/api/"

  # Get all packages, iterating over each page
  def packages do
    do_packages(1, packages(1), [])
  end

  # Iterate over each page of packages, stopping when the result are empty for a given page
  defp do_packages(page, [], acc), do: acc
  defp do_packages(page, results, acc) do
    do_packages(page+1, packages(page+1), acc ++ results)
  end

  # Get a given page of packags
  defp packages(page), do: packages_path(page) |> get_body

  defp get_body(path), do: get(path).body
  defp packages_path(page), do: "packages?page=#{page}"
  def process_url(url), do: @base_url <> url
  def process_response_body(body), do: JSEX.decode!(body)
end
