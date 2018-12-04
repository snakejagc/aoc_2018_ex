defmodule Util.Hamming do
  def hamming(l1, l2), do: hamming(l1, l2, 0)

  defp hamming([], [], count), do: count
  defp hamming([x | l1], [x | l2], count), do: hamming(l1, l2, count)
  defp hamming([_ | l1], [_ | l2], count), do: hamming(l1, l2, count + 1)
end
