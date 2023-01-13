defmodule VM do
	defstruct [:head, :program]

 	def create_vm(program) do
		%VM{head: 0, program: program}
  	end

   	def find_opcode(vm) do
		vm.program 
  		|> Map.get(vm.head)
		|> execute_opcode(vm)
 	end

	# Add reg1 to reg2 and save result to reg3
  	def execute_opcode(1, vm) do
   		gather_window(vm, 4) 
	 	|> then(fn [i1,i2,i3] -> get_reg_value([i1,i2], vm) ++ [i3] end) 
   		|> then(fn [reg1, reg2, reg3] -> update_reg(vm, reg3, reg1+reg2) end)
	 	|> then(fn tvm -> {:cont, %{tvm | head: vm.head + 4}} end)
   	end

 	# Multiply reg1 with reg2 and save result to reg3
	def execute_opcode(2, vm) do
 		gather_window(vm, 4) 
   		|> then(fn [i1,i2,i3] -> get_reg_value([i1,i2], vm) ++ [i3] end) 
	 	|> then(fn [reg1, reg2, reg3] -> update_reg(vm, reg3, reg1*reg2) end)
	 	|> then(fn tvm -> {:cont, %{tvm | head: vm.head + 4}} end)
 	end

  	# End program
  	def execute_opcode(99, vm) do
   		{:halt, vm}
   	end

 	def update_reg(vm, reg, value) do
  		put_in(vm.program[reg], value)
  	end

 	def get_reg_value(regs, vm) do
		regs
  		|> Enum.map(&(Map.get(vm.program, &1)))
  	end

 	def gather_window(vm, window_size) do
		1..(window_size-1)
  		|> Enum.map(fn x -> vm.program |> Map.get(vm.head + x) end)
  	end
end

defmodule Solution do
	def part1(input) do
		part0(input, {12, 2})
	end

 	def part0(input,{noun, verb}) do
		0
  		|> Stream.iterate(&(&1+1))
		|> Enum.reduce_while(input |> VM.update_reg(1,noun) |> VM.update_reg(2,verb), fn _,acc -> VM.find_opcode(acc) end)
  		|> then(fn x -> x.program end)
		|> Map.get(0)
  	end

	def part2(input) do
 		0..99
   		|> Enum.map(fn x -> 0..99 |> Enum.map(fn y -> {x,y} end) end)
	 	|> Enum.flat_map(&(&1))
	 	|> Enum.reduce_while({0,0}, fn x, acc -> if (part0(input, x) == 19690720), do: {:halt, x}, else: {:cont, acc} end)
   		|> then(fn {x,y} -> 100 * x + y end)
	end
end

defmodule Main do
	def execute(day) do
		input = Input.file(day)
  		|> String.split(",")
		|> Enum.map(&String.to_integer/1)
  		|> Enum.with_index(0)
		|> Map.new(fn {op,i} -> {i,op} end)
  		|> VM.create_vm

		Solution.part1(input)
  		|> IO.puts
		Solution.part2(input) 
  		|> IO.puts
	end
end
