defmodule InventoryManagementSystem do
  def checksum(path) when is_binary(path) do
    path
    |> read_input()
    |> checksum()
  end

  def checksum(input) do
    checksums = Enum.map(input, &id_checksum(&1))
    dups = Enum.count(checksums, fn {dup, _} -> dup end)
    trips = Enum.count(checksums, fn {_, trip} -> trip end)
    dups * trips
  end

  def id_checksum(id) do
    freqs = char_freqs(id)
    {n_reps?(freqs, 2), n_reps?(freqs, 3)}
  end

  defp n_reps?(freqs, n) do
    Enum.find(freqs, fn {_, freq} -> freq == n end) != nil
  end

  defp char_freqs(id) do
    id
    |> String.to_charlist()
    |> Enum.reduce(%{}, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)
  end

  defp read_input(path) do
    path
    |> File.stream!()
    |> Stream.map(&String.trim/1)
  end
end
