defmodule IslandsEngine.Game do
	alias IslandsEngine.{Board, Coordinate, Guesses, Island, Rules}

	# GenServer Pattern (3 parts) - a client functions wraps a GenServer module function, which triggers a callback:
		# 1) Client function - serves as the public interface where other processes will call
		# 2) A function from the GenServer module
			# Direct mapping between GenServer module functions and callbacks (examples below)
				# calling GenServer.start_link/3 will always trigger GenServer.init/1
				# GenServer.call/3 calls GenServer.handle_call/3
				# GenServer.cast/2 maps to GenServer.handle_cast/2
		# 3) A callback - where the real work happens and returns a response
	
	# Triggers macro that compiles default implementations for all the GenServer callbacks into our Game module
	# adds start_link/3 and start/3 functions
	use GenServer

	# def demo_call(game), do:
 #    GenServer.call(game, :demo_call)

	# def demo_cast(game, test_value), do:
	# 	GenServer.cast(game, {:demo_cast, test_value})

	# GenServer module itself provides the second argument, state
	# state represents the data structure held by the individual GenServer process (here just an empty map)
	# def handle_info(:first, state) do
 #    IO.puts "This message has been handled by handle_info/2, matching on :first."
 #    {:noreply, state}
 #  end

  # Casts are asynchronous, whereas Calls are synchronous; casts do not return specific reply,
  	# so the caller won't wait for one
  # Casts can increase throughput if synchronous processing becomes a bottleneck
  	# However, still prefer calls over casts because calls limit amount of work a process will accept
  	# and prevent it from getting overloaded
  # def handle_cast({:demo_cast, new_value}, state), do:
  #   {:noreply, Map.put(state, :test, new_value)}


  # GenServer calls are synchronous; returns arbitrary value to the caller and if
  	# caller is waiting for a return, it will block until it receives one
	# handle_call/3 does not accept messages sent directly from other processes
		# Instead, triggered whenever we call GenServer.call/2
		# _from is a tuple that contains the PID of the calling process, here being the IEx session
			# not necessary so prefixed with _
	# def handle_call(:demo_call, _from, state), do:
  #   {:reply, state, state}

  # Enables us to write: Game.start_link(<initial state>) instead of prefixing with GenServer
  	# GenServer Pattern: define a public function that wraps a GenServer module function that triggers a callback
  # Note: GenServer uses only the middle argument, name, to the start_link/3 callback
  def start_link(name) when is_binary(name), do:
  	GenServer.start_link(__MODULE__, name, []) # __MODULE__ is a macro that returns current module

  # Added Guard clause to make sure name is a string
  def add_player(game, name) when is_binary(name), do:
    GenServer.call(game, {:add_player, name})

  # Pattern match on an argument, perform necessary initializations, and return tagged tuple {:ok, initial_state}
  def init(name) do
    player1 = %{name: name, board: Board.new(), guesses: Guesses.new()}
    player2 = %{name: nil,  board: Board.new(), guesses: Guesses.new()}
    {:ok, %{player1: player1, player2: player2, rules: %Rules{}}}
  end

  # handle_call/3 that pattern matches for the {:add_player, name} tuple from GenServer.call/3
  def handle_call({:add_player, name}, _from, state_data) do
    with {:ok, rules} <- Rules.check(state_data.rules, :add_player)
    do
      state_data
      |> update_player2_name(name)
      |> update_rules(rules)
      |> reply_success(:ok)
    else
      :error -> {:reply, :error, state_data}
    end
  end

  defp update_player2_name(state_data, name), do:
  	# Kernel.put_in/2 transforms values nested in a map and returns the whole transformed map
  	put_in(state_data.player2.name, name)

  defp update_rules(state_data, rules), do: %{state_data | rules: rules}

  defp reply_success(state_data, reply), do: {:reply, reply, state_data}

end