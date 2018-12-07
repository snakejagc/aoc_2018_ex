defmodule ChronalCoordinates do
  @no_area "_"
  @mult_areas "."

  def safe_region(path, dist_lim) when is_binary(path) do
    path
    |> read_input()
    |> safe_region(dist_lim)
  end

  def safe_region(coords, dist_lim) do
    dims = matrix_dims(coords)

    empty_matrix(dims)
    |> calc_total_dists(coords)
    |> count_in_range(dims, dist_lim)
  end

  defp count_in_range(mtx, {min_x, max_x, min_y, max_y}, dist_lim) do
    Enum.map(min_x..max_x, fn x ->
      Enum.count(min_y..max_y, fn y ->
        get_in(mtx, [x, y]) < dist_lim
      end)
    end)
    |> Enum.sum()
  end

  defp calc_total_dists(mtx, coords) do
    {min_x, max_x, min_y, max_y} = matrix_dims(coords)

    Enum.reduce(min_x..max_x, mtx, fn x, mtx2 ->
      Enum.reduce(min_y..max_y, mtx2, fn y, mtx3 ->
        put_in(mtx3[x][y], total_distance({x, y}, coords))
      end)
    end)
  end

  defp total_distance(orig, coords) do
    coords
    |> Enum.map(&distance(orig, &1))
    |> Enum.sum()
  end

  def largest_area(path) when is_binary(path) do
    path
    |> read_input()
    |> largest_area()
  end

  def largest_area(coords) do
    coords
    |> matrix_dims()
    |> empty_matrix()
    |> place_coords(coords)
    |> assign_areas(coords)
    |> pick_largest_area(coords)
  end

  defp matrix_dims(coords) do
    min_x = coords |> Enum.map(fn {x, _} -> x end) |> Enum.min
    max_x = coords |> Enum.map(fn {x, _} -> x end) |> Enum.max
    min_y = coords |> Enum.map(fn {_, y} -> y end) |> Enum.min
    max_y = coords |> Enum.map(fn {_, y} -> y end) |> Enum.max
    {min_x - 1, max_x + 1, min_y - 1, max_y + 1}
  end

  defp empty_matrix({_min_x, max_x, _min_y, max_y}) do
    for _ <- 0..max_x do
      for _ <- 0..max_y, do: @no_area
    end
    |> Matrix.from_list()
  end

  defp place_coords(mtx, coords) do
    coords
    |> coords_with_names()
    |> Enum.reduce(mtx, fn {{x, y}, name}, mtx -> put_in(mtx[x][y], name) end)
  end

  defp assign_areas(mtx, coords) do
    coords_names = coords |> coords_with_names()
    {min_x, max_x, min_y, max_y} = matrix_dims(coords)

    Enum.reduce(min_x..max_x, mtx, fn x, mtx2 ->
      Enum.reduce(min_y..max_y, mtx2, fn y, mtx3 ->
        update_in(mtx3[x][y], &set_area(&1, {x, y}, coords_names))
      end)
    end)
  end

  defp pick_largest_area(mtx, coords) do
    dims = matrix_dims(coords)

    edge_areas =
      mtx
      |> edges_values(dims)
      |> to_uniq_area_names()

    area_names(coords) -- edge_areas
    |> Enum.map(fn a -> area_size(a, mtx, dims) end)
    |> Enum.max()
  end

  defp to_uniq_area_names(values) do
    values
    |> Enum.uniq
    |> Enum.filter(&(&1 != @mult_areas))
    |> Enum.map(&String.upcase/1)
  end

  defp area_names(coords) do
    coords
    |> coords_with_names()
    |> Enum.map(fn {_cord, name} -> name end)
  end

  defp edges_values(mtx, {min_x, max_x, min_y, max_y}) do
    edge_1 = Enum.map(min_x..max_x, fn x -> get_in(mtx, [x, min_y]) end)
    edge_2 = Enum.map(min_x..max_x, fn x -> get_in(mtx, [x, max_y]) end)
    edge_3 = Enum.map(min_y..max_y, fn y -> get_in(mtx, [min_x, y]) end)
    edge_4 = Enum.map(min_y..max_y, fn y -> get_in(mtx, [max_x, y]) end)
    (edge_1 ++ edge_2 ++ edge_3 ++ edge_4)
  end

  defp area_size(name, mtx, {min_x, max_x, min_y, max_y}) do
    name_d = String.downcase(name)
    Enum.reduce(min_x..max_x, 0, fn x, count ->
      Enum.reduce(min_y..max_y, count, fn y, count2 ->
        if get_in(mtx, [x, y]) in [name, name_d], do: count2 + 1, else: count2
      end)
    end)
  end

  defp set_area(val = "C" <> _id, _coord, _coords_names), do: val
  defp set_area("_", {x, y}, coords_names) do
    dists = Enum.map(coords_names, fn {c, name} -> {name, distance(c, {x, y})} end)
    {_, min_d} = Enum.min_by(dists, fn {_name, dist} -> dist end)
    case Enum.filter(dists, fn {_name, dist} -> dist == min_d end) do
      [{name, _dist} | []] -> String.downcase(name)
      _ -> @mult_areas
    end
  end

  defp distance({x1, y1}, {x2, y2}) do
    :erlang.abs(x2 - x1) + :erlang.abs(y2 - y1)
  end

  defp coords_with_names(coords) do
    coords
    |> Enum.with_index
    |> Enum.map(fn {coord, idx} -> {coord, "C" <> Integer.to_string(idx)} end)
  end

  defp read_input(path) do
    path
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse_line/1)
  end

  defp parse_line(line) do
    [x, y] = String.split(line, ", ")
    {String.to_integer(x), String.to_integer(y)}
  end
end
