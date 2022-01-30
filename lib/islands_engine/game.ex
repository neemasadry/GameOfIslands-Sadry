defmodule IslandsEngine.Game do
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

end