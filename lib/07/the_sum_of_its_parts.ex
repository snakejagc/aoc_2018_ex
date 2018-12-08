defmodule TheSumOfItsParts do
  def route(path) when is_binary(path) do
    path
    |> read_input()
    |> create_graph()
    |> route()
  end

  def route(g) do
    roots = g |> Graph.vertices() |> Enum.filter(&Graph.in_neighbors(g, &1) == [])
    route(g, [], roots) |> Enum.join() |> String.reverse()
  end

  defp route(_g, sol, []), do: sol
  defp route(g, sol, candidates) do
    next_v = next_v(g, candidates)
    new_sol = [next_v | sol]
    new_candidates =
      ((candidates ++ Graph.out_neighbors(g, next_v)) -- new_sol)
      |> Enum.uniq()
      |> Enum.filter(&preconditions_met?(g, &1, new_sol))
    route(g, new_sol, new_candidates)
  end

  defp next_v(_g, [v]), do: v
  defp next_v(g, candidates) do
    final_v = Enum.find(candidates, &(Graph.out_neighbors(g, &1) == []))
    Enum.min(candidates -- [final_v])
  end

  defp preconditions_met?(g, v, sol) do
    Graph.in_neighbors(g, v) -- sol == []
  end

  defp create_graph(edges) do
    Graph.new |> Graph.add_edges(edges)
  end

  defp read_input(path) do
    path
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&parse_line/1)
  end

  defp parse_line(line) do
    [_, from, to, _] =
      String.split(line, ["Step ", " must be finished before step ", " can begin."])
    {from, to}
  end
end
