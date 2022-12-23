defmodule Solution do
	def part1(input) do
		input
  		|> Enum.reduce(0, fn x,acc -> (div(x, 3) - 2) + acc end)
	end

	def part2(input) do
		input
  		|> Enum.reduce(0, fn x,acc -> fuel_self_weight(x) + acc end)
	end

 	def fuel_self_weight(weight) do
		case (div(weight, 3) - 2) do
			x when x < 0 -> 0
   			x -> x + fuel_self_weight(x)
  		end
  	end
end

defmodule Main do
	def execute(day) do
		input = Input.file(day)
  		|> String.split("\n")
		|> Enum.map(&String.to_integer/1)
  
		Solution.part1(input) |> IO.puts
		Solution.part2(input) |> IO.puts
	end
end
