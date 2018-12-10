defmodule TheSumOfItsParts do

  @n_workers 5
  @base_time 60
  @build_cost ?A..?Z
    |> Enum.with_index(1)
    |> Enum.map(fn {v, idx} -> {to_string([v]), @base_time + idx} end)
    |> Enum.into(%{})

  def time_to_complete(path) when is_binary(path) do
    path
    |> read_input()
    |> create_graph()
    |> time_to_complete()
  end

  def time_to_complete(g) do
    curr = roots(g) |> Enum.take(@n_workers)
    pending = plan(g) -- curr
    curr_w_ts = curr |> Enum.map(&{&1, 0})
    time_to_complete(g, 1, pending, curr_w_ts)
  end

  defp time_to_complete(_g, sec, [], []), do: sec
  defp time_to_complete(g, sec, [], curr) do
    finished = finished_jobs(sec, curr)
    case finished do
      [] -> time_to_complete(g, sec + 1, [], curr)
      _ -> time_to_complete(g, sec + 1, [], curr -- finished)
    end
  end
  defp time_to_complete(g, sec, pending, curr) do
    finished = finished_jobs(sec, curr)
    case finished do
      [] -> time_to_complete(g, sec + 1, pending, curr)
      _ ->
        next = take_next(g, pending, curr, finished)
        new_pending = (pending -- vertices(finished)) -- next
        new_curr = (curr -- finished) ++ Enum.map(next, &{&1, sec})
        time_to_complete(g, sec + 1, new_pending, new_curr)
    end
  end

  defp vertices(vs_ts) do
    Enum.map(vs_ts, fn {v, _} -> v end)
  end

  defp take_next(g, pending, curr, finished) do
    new_pending = pending -- vertices(finished)
    new_curr = vertices(curr -- finished)
    all_finished = Graph.vertices(g) -- new_pending
    viable =
      (new_pending -- new_curr)
      |> Enum.map(&{&1, Graph.in_neighbors(g, &1)})
      |> Enum.filter(fn {_v, in_n} -> (in_n -- all_finished) == [] end)
      |> Enum.take(@n_workers - length(new_curr))
      |> Enum.map(fn {v, _in_n} -> v end)
      |> Enum.filter(fn v -> Enum.all?(new_curr, &(&1 not in Graph.in_neighbors(g, v))) end)
  end

  defp finished_jobs(sec, curr) do
    curr
    |> Enum.map(fn {v, ts} -> {v, ts, Map.get(@build_cost, v)} end)
    |> Enum.filter(fn {_job, ts, time} -> (sec - ts) == time end)
    |> Enum.map(fn {job, ts, _} -> {job, ts} end)
  end

  def find_plan(path) when is_binary(path) do
    path
    |> read_input()
    |> create_graph()
    |> find_plan()
  end

  def find_plan(g) do
    g |> plan() |> Enum.join()
  end

  defp roots(g) do
    g |> Graph.vertices() |> Enum.filter(&Graph.in_neighbors(g, &1) == [])
  end

  defp plan(g) do
    roots = roots(g)
    plan(g, [], roots) |> Enum.reverse
  end

  defp plan(_g, sol, []), do: sol
  defp plan(g, sol, candidates) do
    next_v = next_v(g, candidates)
    new_sol = [next_v | sol]
    new_candidates =
      ((candidates ++ Graph.out_neighbors(g, next_v)) -- new_sol)
      |> Enum.uniq()
      |> Enum.filter(&preconditions_met?(g, &1, new_sol))
    plan(g, new_sol, new_candidates)
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
