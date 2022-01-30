defmodule IslandsEngine.Guesses do
	alias __MODULE__

	@enforce_keys [:hits, :misses]
	defstruct [:hits, :misses]

	# Use MapSet to ensure each guess will be unique
	def new(), do:
		%Guesses{hits: MapSet.new(), misses: MapSet.new()}
		
end