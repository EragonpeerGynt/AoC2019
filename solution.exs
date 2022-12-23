start_time = :os.system_time(:millisecond)
[day|_] = System.argv
Main.execute(day)
:os.system_time(:millisecond) - start_time |> IO.puts