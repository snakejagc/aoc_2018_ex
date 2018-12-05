defmodule NoMatterHowYouSliceIt do

  @empty 0
  @matrix_size 1_500

  def count_superpositions(path) do
    path
    |> read_input()
    |> gen_matrix()
    |> count_overlaps()
  end

  def gen_matrix(claims) do
    Enum.reduce(claims, empty_matrix(), &add_to_matrix(&1, &2))
  end

  def add_to_matrix({id, left_m, top_m, width, height}, mtx) do
    coords =
      for x <- (left_m + 1)..(left_m + width),
          y <- (top_m + 1)..(top_m + height), do: {x, y}
    Enum.reduce(coords, mtx, fn {x, y}, acc ->
      update_in(acc[x][y], &(&1 + 1))
    end)
  end

  def count_overlaps(mtx) do
    mtx
    |> Map.values()
    |> Enum.flat_map(&Map.values(&1))
    |> Enum.count(&(&1 > 1))
  end

  def empty_matrix() do
    for _ <- 1..@matrix_size do
      for _ <- 1..@matrix_size do
        @empty
      end
    end |> Matrix.from_list()
  end

  def read_input(path) do
    path
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse_line/1)
  end

  defp parse_line(line) do
    import String
    ["#" <> claim, _, margins, size] = split(line)
    [left_m, top_m, _] = split(margins, [",", ":"])
    [width, height] = split(size, "x")
    {
      to_integer(claim),
      to_integer(left_m),
      to_integer(top_m),
      to_integer(width),
      to_integer(height)
    }
  end
end
