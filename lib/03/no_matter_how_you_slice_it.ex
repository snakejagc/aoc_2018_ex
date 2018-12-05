defmodule NoMatterHowYouSliceIt do

  @no_claims "."
  @mult_claims "X"
  @matrix_size 1_500

  def legitimate_claim(path) do
    claims = path |> read_input()
    mtx = claims |> gen_matrix()
    claims_coords = claims |> all_claims_coords()
    find_legit_claim(mtx, claims_coords)
  end

  defp all_claims_coords(claims) do
    Enum.reduce(claims, %{},
      fn c = {id, _, _, _, _}, acc -> Map.put(acc, id, claim_coords(c)) end)
  end

  defp find_legit_claim(mtx, claim_coords) do
    Enum.find(claim_coords, &is_legit(&1, mtx)) |> elem(0)
  end

  defp is_legit({id, coords}, mtx) do
    Enum.all?(coords, fn {x, y} -> get_in(mtx, [x, y]) == id end)
  end

  def count_superpositions(path) do
    path
    |> read_input()
    |> gen_matrix()
    |> count_overlaps()
  end

  defp gen_matrix(claims) do
    Enum.reduce(claims, empty_matrix(), &add_claim_to_matrix(&1, &2))
  end

  defp add_claim_to_matrix(claim = {id, _left_m, _top_m, _width, _height}, mtx) do
    Enum.reduce(claim_coords(claim), mtx, fn {x, y}, acc ->
      update_in(acc[x][y], &new_value(id, &1))
    end)
  end

  defp claim_coords({_, left_m, top_m, width, height}) do
    for x <- (left_m + 1)..(left_m + width),
        y <- (top_m + 1)..(top_m + height), do: {x, y}
  end

  defp new_value(id, "."), do: id
  defp new_value(_, _), do: @mult_claims

  defp count_overlaps(mtx) do
    mtx
    |> Map.values()
    |> Enum.flat_map(&Map.values(&1))
    |> Enum.count(&(&1 == @mult_claims))
  end

  defp empty_matrix() do
    for _ <- 1..@matrix_size do
      for _ <- 1..@matrix_size do
        @no_claims
      end
    end |> Matrix.from_list()
  end

  defp read_input(path) do
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
