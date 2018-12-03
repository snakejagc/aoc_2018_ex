defmodule D01ChronalCalibration do

  def frequency(path) do
    File.stream!(path)
    |> Stream.map(&String.trim/1)
    |> Enum.reduce(0, &adjust/2)
  end

  def adjust("+" <> num, old) do
    old + String.to_integer(num)
  end

  def adjust("-" <> num, old) do
    old - String.to_integer(num)
  end
end
