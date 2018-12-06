defmodule ChronalCoordinates do
  @no_area "_"
  @mult_areas "."

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

  def matrix_dims(coords) do
    min_x = coords |> Enum.map(fn {x, _} -> x end) |> Enum.min
    max_x = coords |> Enum.map(fn {x, _} -> x end) |> Enum.max
    min_y = coords |> Enum.map(fn {_, y} -> y end) |> Enum.min
    max_y = coords |> Enum.map(fn {_, y} -> y end) |> Enum.max
    {min_x - 1, max_x + 1, min_y - 1, max_y + 1}
  end

  def empty_matrix({_min_x, max_x, _min_y, max_y}) do
    for _ <- 0..max_x do
      for _ <- 0..max_y, do: @no_area
    end
    |> Matrix.from_list()
  end

  def place_coords(mtx, coords) do
    coords
    |> coords_with_names()
    |> Enum.reduce(mtx, fn {{x, y}, name}, mtx -> put_in(mtx[x][y], name) end)
  end

  def assign_areas(mtx, coords) do
    coords_names = coords |> coords_with_names()
    {min_x, max_x, min_y, max_y} = matrix_dims(coords)

    Enum.reduce(min_x..max_x, mtx, fn x, mtx2 ->
      Enum.reduce(min_y..max_y, mtx2, fn y, mtx3 ->
        update_in(mtx3[x][y], &set_area(&1, {x, y}, coords_names))
      end)
    end)
  end

  def pick_largest_area(mtx, coords) do
    dims = matrix_dims(coords)

    edge_areas =
      mtx
      |> edges_values(dims)
      |> to_uniq_area_names()

    area_names(coords) -- edge_areas
    |> Enum.map(fn a -> area_size(a, mtx, dims) end)
    |> Enum.max()
  end

  def to_uniq_area_names(values) do
    values
    |> Enum.uniq
    |> Enum.filter(&(&1 != @mult_areas))
    |> Enum.map(&String.upcase/1)
  end

  def area_names(coords) do
    coords
    |> coords_with_names()
    |> Enum.map(fn {_cord, name} -> name end)
  end

  def edges_values(mtx, {min_x, max_x, min_y, max_y}) do
    edge_1 = Enum.map(min_x..max_x, fn x -> get_in(mtx, [x, min_y]) end)
    edge_2 = Enum.map(min_x..max_x, fn x -> get_in(mtx, [x, max_y]) end)
    edge_3 = Enum.map(min_y..max_y, fn y -> get_in(mtx, [min_x, y]) end)
    edge_4 = Enum.map(min_y..max_y, fn y -> get_in(mtx, [max_x, y]) end)
    (edge_1 ++ edge_2 ++ edge_3 ++ edge_4)
  end

  def area_size(name, mtx, {min_x, max_x, min_y, max_y}) do
    name_d = String.downcase(name)
    Enum.reduce(min_x..max_x, 0, fn x, count ->
      Enum.reduce(min_y..max_y, count, fn y, count2 ->
        if get_in(mtx, [x, y]) in [name, name_d], do: count2 + 1, else: count2
      end)
    end)
  end

  def set_area(val = "C" <> _id, _coord, _coords_names), do: val
  def set_area("_", {x, y}, coords_names) do
    distances = Enum.map(coords_names, fn {coord, name} -> {name, distance(coord, {x, y})} end)
    {_, min_distance} = Enum.min_by(distances, fn {_name, dist} -> dist end)
    case Enum.filter(distances, fn {_name, dist} -> dist == min_distance end) do
      [{name, _dist} | []] -> String.downcase(name)
      _ -> @mult_areas
    end
  end

  def distance({x1, y1}, {x2, y2}) do
    :erlang.abs(x2 - x1) + :erlang.abs(y2 - y1)
  end

  def coords_with_names(coords) do
    coords
    |> Enum.with_index
    |> Enum.map(fn {{x, y}, idx} -> {{x, y}, "C" <> Integer.to_string(idx)} end)
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
