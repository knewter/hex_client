defmodule HexClientTest do
  use ExUnit.Case

  test "all packages" do
    packages = HexClient.packages
    assert [] != packages
  end

  test "newest packages" do
    packages = HexClient.packages_newest(5)

    assert Enum.count(packages) == 5
  end

  test "most downloaded packages" do
    packages = HexClient.packages_most_downloaded(5)

    assert Enum.count(packages) == 5
  end

  test "all packages streamed" do
    package_names = HexClient.packages_stream |> Stream.map(fn package -> package["name"] end) |> Enum.take(234)
    assert Enum.count(package_names) == 234
  end

  test "package by name" do
    package = HexClient.package "cowboy"

    assert package["name"] == "cowboy"
    assert package["url"] == "https://hex.pm/api/packages/cowboy"
    assert package["meta"]["links"]["GitHub"] == "https://github.com/ninenines/cowboy"

    assert is_integer(package["downloads"]["all"])
    assert is_integer(package["downloads"]["day"])
    assert is_integer(package["downloads"]["week"])

    assert is_bitstring(package["inserted_at"])
    assert is_bitstring(package["updated_at"])

    assert is_list(package["meta"]["contributors"])
    assert is_bitstring(package["meta"]["description"])
    assert is_list(package["meta"]["licenses"])
    assert is_map(package["meta"]["links"])

    assert is_list(package["releases"])
  end

  test "package by name 404" do
    package = HexClient.package "does_not_exist"
    assert package == nil
  end

  test "package by name and version" do
    package_version = HexClient.package "poison", "1.0.1"

    assert is_integer(package_version["downloads"])
    assert is_boolean(package_version["has_docs"])
    assert is_bitstring(package_version["version"])

    assert is_bitstring(package_version["inserted_at"])
    assert is_bitstring(package_version["updated_at"])

    assert is_bitstring(package_version["package_url"])
    assert is_bitstring(package_version["url"])

    assert is_bitstring(package_version["meta"]["app"])
    assert is_list(package_version["meta"]["build_tools"])
    assert is_map(package_version["requirements"])
  end

  test "package by name and version 404" do
    package_version = HexClient.package "poison", "0.0.0"

    assert package_version == nil
  end

  test "package docs by name and version" do
    docs_url = HexClient.package_docs_download "poison", "1.3.1"

    assert docs_url == "https://s3.amazonaws.com/s3.hex.pm/docs/poison-1.3.1.tar.gz"
  end

  test "package docs by name and version 404" do
    docs_url = HexClient.package_docs_download "poison", "0.0.0"

    assert docs_url == nil
  end

end
