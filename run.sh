DAY="D02"
rm -f *.beam
elixirc Common/FileReader.ex
if [ -f ${DAY}/solution.ex ]; then
	elixirc ${DAY}/solution.ex
fi
elixir solution.exs ${DAY}