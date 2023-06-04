defmodule Geniex do
  use Bitwise

  # https://tuxnes.sourceforge.net/gamegenie.html

  def decode("" <> code) do
    code
    |> genie2hex()
    |> then(fn
      h when length(h) == 6 -> decode_hex6(h)
      h when length(h) == 8 -> decode_hex8(h)
    end)
  end

  def encode(code = {_address, _data}), do: encode_hex6(code)
  def encode(code = {_address, _data, _compare}), do: encode_hex8(code)

  def flip8(code, n) do
    code
    |> to_charlist()
    |> List.update_at(n, fn c ->
      c
      |> code2hex()
      |> bxor(1 <<< 3)
      |> hex2code()
    end)
    |> to_string()
  end

  defp genie2hex(code) do
    code
    |> to_charlist()
    |> Enum.map(&code2hex/1)
  end

  defp decode_hex6([n0, n1, n2, n3, n4, n5]) do
    # information loss?!
    address =
      (n3 &&& 7) <<< 12 |||
        (n5 &&& 7) <<< 8 |||
        (n4 &&& 8) <<< 8 |||
        (n2 &&& 7) <<< 4 |||
        (n1 &&& 8) <<< 4 |||
        (n4 &&& 7) |||
        (n3 &&& 8)

    data =
      (n1 &&& 7) <<< 4 |||
        (n0 &&& 8) <<< 4 |||
        (n0 &&& 7) |||
        (n5 &&& 8)

    {0x8000 + address, data}
  end

  defp encode_hex6({address, data}) do
    address = address - 0x8000
    n0 = (0xF &&& data &&& 7) ||| (data >>> 4 &&& 0xF &&& 8)
    n1 = (data >>> 4 &&& 0xF &&& 7) ||| (address >>> 4 &&& 0xF &&& 8)
    # information loss?!
    n2 = address >>> 4 &&& 0xF &&& 7
    n3 = (address >>> 12 &&& 0xF &&& 7) ||| (address &&& 0xF &&& 8)
    n4 = (address >>> 8 &&& 0xF &&& 8) ||| (address &&& 0xF &&& 7)
    n5 = (address >>> 8 &&& 0xF &&& 7) ||| (data &&& 0xF &&& 8)

    [n0, n1, n2, n3, n4, n5]
    |> Enum.map(&hex2code/1)
    |> to_string()
  end

  defp decode_hex8([n0, n1, n2, n3, n4, n5, n6, n7]) do
    # information loss?!
    address =
      (n3 &&& 7) <<< 12 |||
        (n5 &&& 7) <<< 8 |||
        (n4 &&& 8) <<< 8 |||
        (n2 &&& 7) <<< 4 |||
        (n1 &&& 8) <<< 4 |||
        (n4 &&& 7) |||
        (n3 &&& 8)

    data =
      (n1 &&& 7) <<< 4 |||
        (n0 &&& 8) <<< 4 |||
        (n0 &&& 7) |||
        (n7 &&& 8)

    compare =
      (n7 &&& 7) <<< 4 |||
        (n6 &&& 8) <<< 4 |||
        (n6 &&& 7) |||
        (n5 &&& 8)

    {0x8000 + address, data, compare}
  end

  defp encode_hex8({address, data, compare}) do
    address = address - 0x8000
    n0 = (0xF &&& data &&& 7) ||| (data >>> 4 &&& 0xF &&& 8)
    n1 = (data >>> 4 &&& 0xF &&& 7) ||| (address >>> 4 &&& 0xF &&& 8)
    # information loss?!
    n2 = address >>> 4 &&& 0xF &&& 7
    n3 = (address >>> 12 &&& 0xF &&& 7) ||| (address &&& 0xF &&& 8)
    n4 = (address >>> 8 &&& 0xF &&& 8) ||| (address &&& 0xF &&& 7)
    n5 = (address >>> 8 &&& 0xF &&& 7) ||| (compare &&& 0xF &&& 8)
    n6 = (compare >>> 4 &&& 0xF &&& 8) ||| (compare &&& 0xF &&& 7)
    n7 = (compare >>> 4 &&& 0xF &&& 7) ||| (data &&& 0xF &&& 8)

    [n0, n1, n2, n3, n4, n5, n6, n7]
    |> Enum.map(&hex2code/1)
    |> to_string()
  end

  defp code2hex(?A), do: 0x0
  defp code2hex(?P), do: 0x1
  defp code2hex(?Z), do: 0x2
  defp code2hex(?L), do: 0x3
  defp code2hex(?G), do: 0x4
  defp code2hex(?I), do: 0x5
  defp code2hex(?T), do: 0x6
  defp code2hex(?Y), do: 0x7
  defp code2hex(?E), do: 0x8
  defp code2hex(?O), do: 0x9
  defp code2hex(?X), do: 0xA
  defp code2hex(?U), do: 0xB
  defp code2hex(?K), do: 0xC
  defp code2hex(?S), do: 0xD
  defp code2hex(?V), do: 0xE
  defp code2hex(?N), do: 0xF

  defp hex2code(0x0), do: ?A
  defp hex2code(0x1), do: ?P
  defp hex2code(0x2), do: ?Z
  defp hex2code(0x3), do: ?L
  defp hex2code(0x4), do: ?G
  defp hex2code(0x5), do: ?I
  defp hex2code(0x6), do: ?T
  defp hex2code(0x7), do: ?Y
  defp hex2code(0x8), do: ?E
  defp hex2code(0x9), do: ?O
  defp hex2code(0xA), do: ?X
  defp hex2code(0xB), do: ?U
  defp hex2code(0xC), do: ?K
  defp hex2code(0xD), do: ?S
  defp hex2code(0xE), do: ?V
  defp hex2code(0xF), do: ?N
end

"GOSSIP" |> Geniex.decode()
"ZEXPYGLA" |> Geniex.decode()
