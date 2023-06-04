defmodule GeniexTest do
  use PropCheck
  use ExUnit.Case
  use Bitwise
  import PropCheck.BasicTypes

  test "code6" do
    assert {0xD1DD, 0x14} == Geniex.decode("GOSSIP")
  end

  test "code8" do
    assert {0x94A7, 0x2, 0x3} == Geniex.decode("ZEXPYGLA")
  end

  property "roundtrip6" do
    forall code <- code6() do
      back = code |> Geniex.decode() |> Geniex.encode()
      assert code == back or code == Geniex.flip8(back, 2)
    end
  end

  property "roundtrip8" do
    forall code <- code8() do
      back = code |> Geniex.decode() |> Geniex.encode()
      assert code == back or code == Geniex.flip8(back, 2)
    end
  end

  def code6() do
    code_letter()
    |> List.duplicate(6)
    |> fixed_list()
    |> and_then(&to_string/1)
  end

  def code8() do
    code_letter()
    |> List.duplicate(8)
    |> fixed_list()
    |> and_then(&to_string/1)
  end

  def code_letter() do
    [?A, ?P, ?Z, ?L, ?G, ?I, ?T, ?Y, ?E, ?O, ?X, ?U, ?K, ?S, ?V, ?N]
    |> elements()
  end

  def and_then(g, f) do
    let x <- g do
      f.(x)
    end
  end
end
