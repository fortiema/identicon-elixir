defmodule Identicon do

  @doc """
  """
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  @doc """
    Takes an input string and returns an `Identicon.Image` with its `hex` value set.

  ## Examples

      iex> Identicon.hash_input("banana")
      %Identicon.Image{
        color: nil,
        grid: nil,
        hex: [114, 179, 2, 191, 41, 122, 34, 138, 117, 115, 1, 35, 239, 239, 124, 65],
        pixel_map: nil
      }
  """
  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end

  @doc """
    Updates an `Identicon.Image` with RGB values picked from its `hex` property.

  ## Examples

      iex> image = Identicon.hash_input("banana")
      iex> Identicon.pick_color(image)
      %Identicon.Image{
          color: {114, 179, 2},
          grid: nil,
          hex: [114, 179, 2, 191, 41, 122, 34, 138, 117, 115, 1, 35, 239, 239, 124, 65],
          pixel_map: nil
        }
  """
  def pick_color(image) do
    %Identicon.Image{hex: [r, g, b | _]} = image
    %Identicon.Image{image | color: {r, g, b}}
  end

  @doc """
    Updates an `Identicon.Image` to construct its `grid` property based on its `hex` property.

  ## Examples

      iex> image = Identicon.hash_input("banana")
      iex> Identicon.build_grid(image)
      %Identicon.Image{
          color: nil,
          grid: [
            {114, 0},
            {179, 1},
            {2, 2},
            {179, 3},
            {114, 4},
            {191, 5},
            {41, 6},
            {122, 7},
            {41, 8},
            {191, 9},
            {34, 10},
            {138, 11},
            {117, 12},
            {138, 13},
            {34, 14},
            {115, 15},
            {1, 16},
            {35, 17},
            {1, 18},
            {115, 19},
            {239, 20},
            {239, 21},
            {124, 22},
            {239, 23},
            {239, 24}
          ],
          hex: [114, 179, 2, 191, 41, 122, 34, 138, 117, 115, 1, 35, 239, 239, 124, 65],
          pixel_map: nil
        }
  """
  def build_grid(image) do
    %Identicon.Image{hex: hex} = image
    grid =
      hex
      |> Enum.chunk(3)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index

    %Identicon.Image{image | grid: grid}
  end

  @doc """
    Returns a mirrored version of a 3-elements list.

  ## Examples

      iex> Identicon.mirror_row([1, 2, 3])
      [1, 2, 3, 2, 1]
  """
  def mirror_row(row) do
    [first, second | _] = row
    row ++ [second, first]
  end

  def filter_squares(image) do
    %Identicon.Image{grid: grid} = image
    grid = Enum.filter grid, fn({val, _}) ->
      rem(val, 2) == 0
    end

    %Identicon.Image{image | grid: grid}
  end

  def build_pixel_map(image) do
    %Identicon.Image{grid: grid} = image
    pixel_map = Enum.map grid, fn({_, index}) ->
      hor = rem(index, 5) * 50
      ver = div(index, 5) * 50
      top_left = {hor, ver}
      bot_right = {hor+50, ver+50}
      {top_left, bot_right}
    end

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  def draw_image(image) do
    %Identicon.Image{color: color, pixel_map: pixel_map} = image
    canvas = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(canvas, start, stop, fill)
    end

    :egd.render(canvas)
  end

  def save_image(image, filename) do
    File.write("#{filename}.png", image)
  end

end
