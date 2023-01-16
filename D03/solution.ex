defmodule Solution do
	def part1(input) do
		input
  		|> Enum.map(&build_wire/1)
		|> intersection()
		|> Enum.map(fn {x,_} -> x end)
  		|> Enum.map(&manhattan/1)
		|> Enum.sort()
  		|> hd()
	end

 	def intersection([{wire1,_},{wire2,_}]) do
  		Map.to_list(wire2)
		|> Enum.reduce([], fn {c,d},acc -> if Map.has_key?(wire1, c) do
  				[{c,{d,Map.get(wire1, c)}}|acc]
	  		else
	  			acc
  			end
  		end)
   	end

 	def manhattan({x,y}) do
		abs(x) + abs(y)
  	end

 	def build_wire(wire) do
		wire
  		|> Enum.reduce({Map.new(),{{0,0}, 0}}, fn x,acc -> reduce_wire(acc,x) end)
  	end

   	def reduce_wire(wire_data, next_point) do
		case next_point do
			<<"U", d::binary>> -> d |> String.to_integer()
   				|> then(fn x -> 1..x |> Enum.map(&({0,&1})) |> generate_wire(wire_data, 1..x) end)
   			<<"R", d::binary>> -> d |> String.to_integer()
	  			|> then(fn x -> 1..x |> Enum.map(&({&1,0})) |> generate_wire(wire_data, 1..x) end)
	  		<<"D", d::binary>> -> d |> String.to_integer()
	 			|> then(fn x -> 1..x |> Enum.map(&({0,-1*&1})) |> generate_wire(wire_data, 1..x) end)
	 		<<"L", d::binary>> -> d |> String.to_integer()
				|> then(fn x -> 1..x |> Enum.map(&({-1*&1,0})) |> generate_wire(wire_data, 1..x) end)
  		end
 	end

  	def generate_wire(wire_indexes, {wire, {{x,y}, i}}, distance) do
		wire_indexes
  		|> Enum.map(fn {x_w, y_w} -> {x_w+x,y_w+y} end)
		|> Enum.zip(distance |> Enum.map(&(&1+i)))
		|> then(
  			fn new_wire -> 
	 			{new_wire |> Enum.reduce(wire, 
	 				fn {n_w,d},acc -> if !Map.has_key?(acc,n_w), do: acc |> Map.put(n_w,d), else: acc
	  			end), new_wire |> Enum.reverse |> hd()}
	 	end)
   	end

	def part2(input) do
		input
  		|> Enum.map(&build_wire/1)
		|> intersection()
		|> Enum.map(fn {_,x} -> x end)
  		|> Enum.map(fn {x,y} -> x + y end)
		|> Enum.sort()
  		|> hd()
	end
end

defmodule Main do
	def execute(day) do
		input = Input.file(day)
  		|> String.split("\n")
		|> Enum.map(&String.split(&1, ","))

		Solution.part1(input) 
  		|> IO.puts
		Solution.part2(input) 
  		|> IO.puts
	end
end
