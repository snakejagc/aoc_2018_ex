defmodule D01ChronalCalibrationTest do
  use ExUnit.Case

  @base_path "test/resources/01"

  test "find frequency, small input" do
    assert D01ChronalCalibration.frequency("#{@base_path}/small_input.txt") == 0
  end

  test "find frequency, real input" do
    assert D01ChronalCalibration.frequency("#{@base_path}/real_input.txt") == 508
  end
end
