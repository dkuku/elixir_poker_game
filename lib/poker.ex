defmodule Poker do
  @moduledoc """
  Implements high level logic
  """
  use GenStateMachine
  Poker.Game

  # Callbacks

  def start_link(users) do
    GenStateMachine.start_link(__MODULE__, {:end, users})
  end

  def deal(pid) do
    GenStateMachine.cast(pid, :deal)
  end

  def get_hand(pid, player) do
    GenStateMachine.call(pid, {:get_hand, player})
  end

  def drop_cards(pid, player, cards_list) do
    GenStateMachine.call(pid, {:drop_cards, player, cards_list})
  end

  def score(pid) do
    GenStateMachine.call(pid, :score)
  end

  # Server (callbacks)
  def handle_event(:cast, :deal, :end, users) do
    {:next_state, :game, Poker.Game.start(users)}
  end

  def handle_event({:call, from}, {:get_hand, player}, state, game) do
    {:next_state, state, game, {:reply, from, game.players[player]}}
  end

  def handle_event({:call, from}, {:drop_cards, player, cards_list}, state, game) do
    game = Poker.Game.new_card(game, player, cards_list)

    {:next_state, state, game, {:reply, from, game.players[player]}}
  end

  def handle_event({:call, from}, :score, _state, game) do
    {winners, _} = Poker.Game.score_game(game)

    {:next_state, :end, game, {:reply, from, winners}}
  end

  def handle_event(event_type, event_content, state, data) do
    # Call the default implementation from GenStateMachine
    super(event_type, event_content, state, data)
  end
end
