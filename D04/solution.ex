defmodule Solution do
	def part1(input) do
		input
  		|> Enum.filter(&matcher/1)
		|> length()
	end

 	def matcher(password) do
		password
  		|> Enum.dedup()
  		|> then(fn duplicate -> length(duplicate) < length(password) && duplicate == (duplicate |> Enum.sort()) end)
   	end

	def part2(input) do
		input
  		|> Enum.filter(&matcher/1)
  		|> Enum.filter(&advanced_matcher/1)
		|> length()
	end

 	def advanced_matcher(password) do
		1..9
  		|> Enum.map(fn x -> password |> Enum.count(&(&1 == x)) end)
		|> Enum.any?(&(&1 == 2))
  	end
end

defmodule Main do
	def execute(day) do
		input = Input.file(day)
  		|> String.split("-")
		|> Enum.map(&String.to_integer/1)
  		|> then(fn [x,y] -> x..y end)
		|> Enum.map(fn x -> Integer.to_string(x) |> String.graphemes |> Enum.map(&String.to_integer/1) end)

		Solution.part1(input) 
  		|> IO.puts
		Solution.part2(input) 
  		|> IO.puts
	end
end
