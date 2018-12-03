defmodule Dfalse1ChronalCalibrationTest do
  use ExSpec, async: true

  @base_path "test/resources/02"

  describe "id checksum" do
    @id_samples [
      {"abcdef", false, false},
      {"bababc", true, true},
      {"abbcde", true, false},
      {"abcccd", false, true},
      {"aabcdd", true, false},
      {"abcdee", true, false},
      {"ababab", false, true}
    ]

    Enum.each(@id_samples, fn {id, dup, trip} ->
      @id id
      @dup dup
      @trip trip
      context "with example: #{@id}" do
        it "gets correct id checksum" do
          assert InventoryManagementSystem.id_checksum(@id) == {@dup, @trip}
        end
      end
    end)
  end

  describe "whole checksum" do
    context "with example input" do
      it "gets correct checksum" do
        assert InventoryManagementSystem.checksum("#{@base_path}/sample_input.txt") == 12
      end
    end

    context "with real input" do
      it "finds correct answer" do
        assert InventoryManagementSystem.checksum("#{@base_path}/input.txt") == 6200
      end
    end
  end
end
