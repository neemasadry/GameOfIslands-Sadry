defmodule IslandsEngine.Rules do
  alias __MODULE__

  defstruct state: :initialized,
            player1: :islands_not_set,
            player2: :islands_not_set

  def new(), do: %Rules{}

  # Performs runtime check on %Rules{} struct followed by pattern matching on the state
  # Does not actually add another player, rather, decide whether ok to add another player
    # based on current state
  def check(%Rules{state: :initialized} = rules, :add_player), do:
    {:ok, %Rules{rules | state: :players_set}}

  def check(%Rules{state: :players_set} = rules, {:position_islands, player}) do
    case Map.fetch!(rules, player) do
      :islands_set -> :error
      :islands_not_set -> {:ok, rules}
    end
  end

  def check(%Rules{state: :players_set} = rules, {:set_islands, player}) do
    rules = Map.put(rules, player, :islands_set)
    case both_players_islands_set?(rules) do
      true  -> {:ok, %Rules{rules | state: :player1_turn}}
      false -> {:ok, rules}
    end
  end

  # Clause to check player1 can guess coordinate, then transition to player2's turn
  def check(%Rules{state: :player1_turn} = rules, {:guess_coordinate, :player1}), do:
    {:ok, %Rules{rules | state: :player2_turn}}

  # Clause to check if player1 wins the game and, if so, transition to :game_over state
  # Board.guess/2 returns tuple with either :win or :no_win
  def check(%Rules{state: :player1_turn} = rules, {:win_check, win_or_not}) do
    case win_or_not do
      :no_win -> {:ok, rules}
      :win -> {:ok, %Rules{rules | state: :game_over}}
    end
  end

  # Clause to check player2 can guess coordinate, then transition to player1's turn
  def check(%Rules{state: :player2_turn} = rules, {:guess_coordinate, :player2}), do:
    {:ok, %Rules{rules | state: :player1_turn}}

  # Clause to check if player2 wins the game and, if so, transition to :game_over state
  def check(%Rules{state: :player2_turn} = rules, {:win_check, win_or_not}) do
    case win_or_not do
      :no_win -> {:ok, rules}
      :win -> {:ok, %Rules{rules | state: :game_over}}
    end
  end

  # Will always match so define this check/2 catchall clause last; clause order matters
  def check(_state, _action), do: :error

  defp both_players_islands_set?(rules), do:
    rules.player1 == :islands_set && rules.player2 == :islands_set
end
