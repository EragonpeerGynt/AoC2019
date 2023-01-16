defmodule VM do
	defstruct [:head, :program, :ram]

 	def create_vm(program) when is_map(program) do
		%VM{head: 0, program: program, ram: []}
  	end

   	def create_vm(program) when is_binary(program) do
		program
  		|> String.split(",")
		|> Enum.map(&String.to_integer/1)
  		|> Enum.with_index(0)
		|> Map.new(fn {op,i} -> {i,op} end)
  		|> VM.create_vm
 	end

   	def find_opcode(vm) do
		vm.program 
  		|> Map.get(vm.head)
		|> then(fn x -> {rem(x, 100), div(x, 100)} end)
		|> execute_opcode(vm)
 	end

	# Add reg1 to reg2 and save result to reg3
  	def execute_opcode({1, mode}, vm) do
   		window = 4
   		gather_window(vm, window)
	 	|> Enum.zip(parse_mode(mode, window))
	 	|> then(fn [i1,i2,i3] -> {get_reg_value(i1,vm), get_reg_value(i2,vm), get_reg_location(i3,vm)} end) 
   		|> then(fn {reg1, reg2, reg3} -> update_reg(vm, reg3, reg1+reg2) end)
	 	|> then(fn tvm -> {:cont, %{tvm | head: vm.head + window}} end)
   	end

 	# Multiply reg1 with reg2 and save result to reg3
	def execute_opcode({2, mode}, vm) do
 		window = 4
 		gather_window(vm, window)
	 	|> Enum.zip(parse_mode(mode, window))
   		|> then(fn [i1,i2,i3] -> {get_reg_value(i1,vm), get_reg_value(i2,vm), get_reg_location(i3,vm)} end) 
	 	|> then(fn {reg1, reg2, reg3} -> update_reg(vm, reg3, reg1*reg2) end)
	 	|> then(fn tvm -> {:cont, %{tvm | head: vm.head + window}} end)
 	end

  	# Input to register
   	def execute_opcode({3, mode}, vm) do
		window = 2
  		gather_window(vm, window)
		|> Enum.zip(parse_mode(mode, window))
  		|> then(fn [i1] -> {get_reg_location(i1,vm)} end)
		|> then(fn {reg1} -> update_reg(vm, reg1, vm.ram |> hd()) end)
  		|> then(fn tvm -> {:cont, %{tvm | head: vm.head + window, ram: vm.ram |> tl()}} end)
 	end

   	# Output from register
	def execute_opcode({4, mode}, vm) do
		window = 2
  		gather_window(vm, window)
		|> Enum.zip(parse_mode(mode, window))
  		|> then(fn [i1] -> {get_reg_value(i1,vm)} end)
		|> then(fn {reg1} -> update_ram(vm, reg1) end)
  		|> then(fn tvm -> {:cont, %{tvm | head: vm.head + window}} end)
 	end

  	# Jump if first parameter not zero
   	def execute_opcode({5, mode}, vm) do
		window = 3
  		gather_window(vm, window)
		|> Enum.zip(parse_mode(mode, window))
  		|> then(fn [i1, i2] -> {get_reg_value(i1,vm), get_reg_value(i2,vm)} end)
		|> then(fn {reg1, reg2} -> jump_head(vm, {reg2, vm.head + window}, reg1 != 0) end)
  		|> then(fn tvm -> {:cont, tvm} end)
 	end

   	# Jump if first parameter is zero
	def execute_opcode({6, mode}, vm) do
		window = 3
  		gather_window(vm, window)
		|> Enum.zip(parse_mode(mode, window))
  		|> then(fn [i1, i2] -> {get_reg_value(i1,vm), get_reg_value(i2,vm)} end)
		|> then(fn {reg1, reg2} -> jump_head(vm, {reg2, vm.head + window}, reg1 == 0) end)
  		|> then(fn tvm -> {:cont, tvm} end)
 	end

 	# Is less then
  	def execute_opcode({7, mode}, vm) do
		window = 4
  		gather_window(vm, window)
	 	|> Enum.zip(parse_mode(mode, window))
	 	|> then(fn [i1,i2,i3] -> {get_reg_value(i1,vm), get_reg_value(i2,vm), get_reg_location(i3,vm)} end) 
   		|> then(fn {reg1, reg2, reg3} -> update_reg(vm, reg3, (if reg1 < reg2, do: 1, else: 0)) end)
	 	|> then(fn tvm -> {:cont, %{tvm | head: vm.head + window}} end)
 	end

  	# Is equal to
   	def execute_opcode({8, mode}, vm) do
		window = 4
  		gather_window(vm, window)
	 	|> Enum.zip(parse_mode(mode, window))
	 	|> then(fn [i1,i2,i3] -> {get_reg_value(i1,vm), get_reg_value(i2,vm), get_reg_location(i3,vm)} end) 
   		|> then(fn {reg1, reg2, reg3} -> update_reg(vm, reg3, (if reg1 == reg2, do: 1, else: 0)) end)
	 	|> then(fn tvm -> {:cont, %{tvm | head: vm.head + window}} end)
 	end

  	# End program
  	def execute_opcode({99, _mode}, vm) do
   		{:halt, vm}
   	end

 	def update_reg(vm, reg, value) do
  		put_in(vm.program[reg], value)
  	end

   	def update_ram(vm, add) do
		vm.ram
  		|> Enum.reverse()
		|> then(&([add|&1]))
  		|> Enum.reverse
		|> then(fn x -> %{vm | ram: x} end)
 	end

   	def get_reg_value({reg, mode}, vm) do
		case mode do
			0 -> Map.get(vm.program, reg)
   			1 -> reg
  		end
		|> then(&(Map.get(vm.program, &1)))
 	end

  	def get_reg_location({reg, mode}, vm) do
		case mode do
			0 -> Map.get(vm.program, reg)
   			1 -> reg
  		end
 	end

  	def jump_head(vm, {position_true, position_false}, should_jump) do
   		case should_jump do
			true -> %{vm | head: position_true}
   			false -> %{vm | head: position_false}
  		end
	end
   
 	def gather_window(vm, window_size) do
		1..(window_size-1)
  		|> Enum.map(fn x -> vm.head + x end)
  	end

   	def parse_mode(modes, window_size) do
		1..(window_size-1)
  		|> Enum.reduce({[], modes}, fn _,{parsed,remaining} -> {[rem(remaining, 10) | parsed], div(remaining, 10)} end)
		|> then(fn {x,_} -> x |> Enum.reverse end)
 	end
end

defmodule Solution do
	def part1(input) do
  		0
  		|> Stream.iterate(&(&1+1))
		|> Enum.reduce_while(input |> VM.update_ram(1), fn _,acc -> VM.find_opcode(acc) end)
  		|> then(&(&1.ram |> Enum.reverse() |> hd()))
	end

	def part2(input) do
		0
  		|> Stream.iterate(&(&1+1))
		|> Enum.reduce_while(input |> VM.update_ram(5), fn _,acc -> VM.find_opcode(acc) end)
  		|> then(&(&1.ram |> Enum.reverse() |> hd()))
	end
end

defmodule Main do
	def execute(day) do
		input = Input.file(day)
  		|> VM.create_vm()

		Solution.part1(input) 
  		|> IO.puts
		Solution.part2(input) 
  		|> IO.puts
	end
end
