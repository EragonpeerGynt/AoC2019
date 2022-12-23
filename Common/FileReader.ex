defmodule Input do
	def file(filedir) do
		File.read!(filedir <> "/input.txt")
	end
	def split(text, splitter) do
		text |> String.split(splitter, trim: true)
	end
end

defmodule Matrix do
	def transpose([]), do: []
	def transpose([[]|_]), do: []
	def transpose(a) do
		[Enum.map(a, &hd/1) | transpose(Enum.map(a, &tl/1))]
	end
end

defmodule Maping do
	def create_map(map, [], _, _) do
		map
	end

	def create_map(map, [head|tail], x, y) when is_list(head) do
		create_map(map, head, x, y)
		|> create_map(tail, x, y+1)
	end

	def create_map(map, [head|tail], x, y) do
		Map.put(map, {x,y}, head)
		|> create_map(tail, x+1, y)
	end

	def create_map(input) do
		create_map(%{}, input, 0, 0)
	end
end

defmodule Draw do
	def draw_y_axis(map, x, y, max_x, max_y) do
		if y <= max_y do
			draw_x_axis(map, x, y, max_x, max_y)
			IO.puts ""
			draw_y_axis(map, x, y+1, max_x, max_y)
		end
	end

	def draw_x_axis(map, x, y, max_x, max_y) do
		if x <= max_x do
			case map[{x,y}] do
				x when x != nil -> x
				|> Integer.to_string 
				|> String.pad_leading(2, "0") 
				|> IO.write
				_ -> "xx" |> IO.write
			end

			" " |> IO.write

			draw_x_axis(map, x+1, y, max_x, max_y)
		end
	end
end