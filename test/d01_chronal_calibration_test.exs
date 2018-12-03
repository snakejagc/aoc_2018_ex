defmodule D01ChronalCalibrationTest do
  use ExSpec, async: true

  @base_path "test/resources/01"

  describe "find frequency" do
    context "with small input" do
      it "finds correct answer" do
        assert D01ChronalCalibration.frequency("#{@base_path}/small_input.txt") == 0
      end
    end

    context "with real input" do
      it "finds correct answer" do
        assert D01ChronalCalibration.frequency("#{@base_path}/real_input.txt") == 508
      end
    end
  end
end
