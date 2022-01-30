defmodule IslandsEngine.Island do
	alias IslandsEngine.{Coordinate, Island}

	@enforce_keys [:coordinates, :hit_coordinates]
	defstruct [:coordinates, :hit_coordinates]


	# def new(), do:
	# 	%Island{coordinates: MapSet.new(), hit_coordinates: MapSet.new()}

	# Replaced previous new/0 function with new/2 below
	# offsets/1 must return list of offsets instead of an invalid island key error
	# add_coordinates/2 neds to return a MapSet instead of an invalid coordinate error
	def new(type, %Coordinate{} = upper_left) do
		with [_|_] = offsets <- offsets(type),
    	%MapSet{} = coordinates <- add_coordinates(offsets, upper_left)
		do
			{:ok, %Island{coordinates: coordinates, hit_coordinates: MapSet.new()}}
		else
			# Two types of error expected: {:error, :invalid_island_type} or {:error, :invalid_coordinate}
			error -> error
		end
	end

	# Validate coordinate(s)
		# Enum.reduce_while takes the following:
			#	1) Enumerable
			# 2) A starting value for an accumulator
			#	3) A function to apply to each enumerated value
	defp add_coordinates(offsets, upper_left) do
    Enum.reduce_while(offsets, MapSet.new(), fn offset, acc ->
    	add_coordinate(acc, upper_left, offset)
    end)
  end

	defp add_coordinate(coordinates, %Coordinate{row: row, col: col},
		{row_offset, col_offset}) do
			case Coordinate.new(row + row_offset, col + col_offset) do
				{:ok, coordinate}             ->
					{:cont, MapSet.put(coordinates, coordinate)}
				{:error, :invalid_coordinate} ->
					{:halt, {:error, :invalid_coordinate}}
			end
		end

	# All valid island types
	defp offsets(:atoll),   do: [{0, 0}, {0, 1}, {1, 1}, {2, 0}, {2, 1}]
  defp offsets(:dot),     do: [{0, 0}]
  defp offsets(:l_shape), do: [{0, 0}, {1, 0}, {2, 0}, {2, 1}]
  defp offsets(:s_shape), do: [{0, 1}, {0, 2}, {1, 0}, {1, 1}]
  defp offsets(:square),  do: [{0, 0}, {0, 1}, {1, 0}, {1, 1}]
  defp offsets(_),        do: {:error, :invalid_island_type}
end