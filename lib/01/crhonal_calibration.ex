defmodule ChronalCalibration do
  def frequency(path) when is_binary(path) do
    path
    |> read_input()
    |> frequency()
  end

  def frequency(input) do
    Enum.reduce(input, 0, &adjust/2)
  end

  defp read_input(path) do
    path
    |> File.stream!()
    |> Stream.map(&String.trim/1)
  end

  defp adjust("+" <> num, old) do
    old + String.to_integer(num)
  end

  defp adjust("-" <> num, old) do
    old - String.to_integer(num)
  end

  def base_frequency(path) when is_binary(path) do
    path
    |> read_input()
    |> base_frequency()
  end

  def base_frequency(input) do
    input
    |> Stream.cycle()
    |> Stream.scan(0, &adjust/2)
    |> Stream.scan([0], &[&1 | &2])
    |> Enum.find(&repeated_freq?/1)
    |> hd
  end

  defp repeated_freq?(freqs) do
    length(freqs) != length(Enum.uniq(freqs))
  end
end
