defmodule InventoryManagementSystem do
  import Util.Hamming

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

  defp char_freqs(id) when is_binary(id) do
    id |> String.to_charlist() |> char_freqs()
  end

  defp char_freqs(id) do
    Enum.reduce(id, %{}, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)
  end

  defp read_input(path) do
    path
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_charlist/1)
  end

  def find_boxes(path) do
    pairs = path |> read_input() |> gen_pairs()
    dists = Stream.map(pairs, fn {x, y} -> {x, y, hamming(x, y)} end)
    Enum.find(dists, fn {_, _, dist} -> dist == 1 end)
  end

  defp gen_pairs(input) do
    for x <- input, y <- input, x != y, do: {x, y}
  end
end
