defmodule AlchemicalReduction do

  def improve(path) when is_binary(path) do
    path |> File.read!() |> String.trim() |> do_improve()
  end

  def do_improve(str) do
    equivs = Enum.zip(?a..?z, ?A..?Z)
    equivs
    |> Enum.map(fn {x, y} -> Regex.compile!("(#{[x]}|#{[y]})") end)
    |> Enum.map(&remove_and_reduce(str, &1))
    |> Enum.map(&String.length/1)
    |> Enum.min()
  end

  defp remove_and_reduce(str, regex) do
    new_str = String.replace(str, regex, "")
    do_reduce(new_str)
  end

  def reduce(path) when is_binary(path) do
    path |> File.read!() |> String.trim() |> do_reduce() |> String.length()
  end

  def do_reduce(str) do
    len = String.length(str)
    do_reduce(str, len + 1, len)
  end

  defp do_reduce(str, old_len, new_len) when old_len == new_len, do: str

  defp do_reduce(str, _, _) do
    new_str = String.replace(str, regex(), "")
    do_reduce(new_str, String.length(str), String.length(new_str))
  end

  defp regex() do
    equivs = Enum.zip(?a..?z, ?A..?Z)
    pattern =
      equivs
      |> Enum.flat_map(fn {x, y} -> [[x, y], [y, x]] end)
      |> Enum.map(&to_string/1)
      |> Enum.join("|")
    Regex.compile!("(" <> pattern <> ")")
  end

end
