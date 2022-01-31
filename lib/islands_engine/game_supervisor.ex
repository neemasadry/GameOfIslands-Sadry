defmodule IslandsEngine.GameSupervisor do
	use DynamicSupervisor

	alias IslandsEngine.Game

	# 3 categories of reasons for a process to terminate:
		# 1) :normal - won't send an exit signal and terminate other linked processes
		# 2) :kill - will send an exit signal and terminate linked processes
		# 3) Any other reason - same as :kill (2) above

	# When defining a new Supervisor module, we describe:
		# 1) how we want it to supervise its children
		# 2) what restart strategy to use
		# 3) determine under which circumstances the Supervisor should restart the process
		# 4) also define scenarios where the Supervisor itself should terminate and restart
			# Configuring maximum allowable number of restarts over a given period of time:
				# :max_restarts (default 3) and :max_seconds (default 5)

	def start_link(_options), do:
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)

  def start_game(name) do
    spec = %{id: Game, start: {Game, :start_link, [name]}}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def stop_game(name) do
    :ets.delete(:game_state, name)
    DynamicSupervisor.terminate_child(__MODULE__, pid_from_name(name))
  end

  def init(:ok), do:
    DynamicSupervisor.init(strategy: :one_for_one)

  defp pid_from_name(name) do
    name
    |> Game.via_tuple()
    |> GenServer.whereis()
  end
  
end