defmodule Identicon do

  @doc """
  """
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
  end

  @doc """
    Takes an input string and returns an `Identicon.Image` with its `hex` value set.

  ## Examples

      iex> Identicon.hash_input("banana")
      %Identicon.Image{
        color: nil,
        hex: [114, 179, 2, 191, 41, 122, 34, 138, 117, 115, 1, 35, 239, 239, 124, 65]
      }
  """
  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end

  @doc """
    Updates an `Identicon.Image` with RGB values picked from its `hex` property.
  """
  def pick_color(image) do
    %Identicon.Image{hex: [r, g, b | _tail]} = image
    %Identicon.Image{image | color: {r, g, b}}
  end


  def build_grid(image) do
    %Identicon.Image{hex: hex_list} = image
    hex_list
    |> Enum.chunk(3)
    |> Enum.map(&mirror_row/1)
  end

  @doc """
    Returns a mirrored version of a 3-elements list.

  ## Examples

      iex> Identicon.mirror_row([1, 2, 3])
      [1, 2, 3, 2, 1]
  """
  def mirror_row(row) do
    [first, second | _tail] = row
    row ++ [second, first]
  end

end
