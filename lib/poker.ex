defmodule Poker do
  @moduledoc """
  Documentation for `Poker`.
  """
  use TypedStruct
  alias CardDeck, as: Deck

  @typedoc "Defines poker game"
  typedstruct do
    field(:players, map(), default: %{})
    field(:pile, list(), default: [])
    field(:deck, list(), default: [])
  end

  @doc """
  Starts the game

  ## Examples

  """
  def start(num_players) do
    deal(num_players)
  end

  @spec deal(integer()) :: Poker
  def deal(num_players) do
    game = %Poker{deck: Deck.shuffled(), players: %{}, pile: []}

    0..num_players
    |> Enum.reduce(game, fn player, game ->
      {hand, deck} = Deck.deal(game.deck, 5)
      game = %{game | deck: deck}
      %{game | players: Map.put(game.players, player, Deck.sort(hand))}
    end)
  end

  @spec new_card(Poker, integer(), integer() | list(integer())) :: Poker
  def new_card(game, num_player, card) when is_integer(card) do
    new_card(game, num_player, [card])
  end

  def new_card(%{players: players, deck: deck} = game, num_player, cards) do
    case players[num_player] do
      nil ->
        game

      player ->
        {new_cards, new_deck} = Deck.deal(deck, length(cards))
        player = Deck.drop(player, cards)
        player = Deck.sort(player ++ new_cards)
        %{game | deck: new_deck, players: Map.put(players, num_player, player)}
    end
  end

  @doc """
  Scores poker hand
  We convert our hand to a tuple with 2 elements:
  {ranking , {tuple with card rankings}}
  this can be easily compared
  as the rank is on the most sighificant place it gets compared first
  if we have identical ranks then we compare cards from the most sighificant
  # Examples
  iex> {1, {5, 4, 3, 2, 1}} > {3, {3, 2, 1}}
  false
  iex> {4, {5, 4, 3}} > {3, {3, 2, 1}}
  true

  """
  @high_card 0
  @pair 1
  @two_pairs 2
  @three_of_a_kind 3
  @straight 4
  @flush 5
  @full_house 6
  @four_of_a_kind 7
  @straight_flush 8

  def hand_type([{2, z}, {3, z}, {4, z}, {5, z}, {14, z}]) do
    {@straight_flush, {5}}
  end

  def hand_type([{a, z}, {b, z}, {c, z}, {d, z}, {e, z}]) do
    cond do
      a + 1 == b && b + 1 == c && c + 1 == d && d + 1 == e ->
        {@straight_flush, {e}}

      true ->
        {@flush, {e, d, c, b, a}}
    end
  end

  def hand_type([{2, _}, {3, _}, {4, _}, {5, _}, {14, _}]) do
    {@straight, {5}}
  end

  def hand_type([{a, z}, {b, z}, {c, z}, {d, z}, {e, z}]) do
    {@flush, {e, d, b, c, a}}
  end

  def hand_type([{a, _}, {b, _}, {c, _}, {d, _}, {e, _}]) do
    hand_type(a, b, c, d, e)
  end

  def hand_type(a, a, a, a, b), do: {@four_of_a_kind, {a, b}}
  def hand_type(b, a, a, a, a), do: {@four_of_a_kind, {a, b}}

  def hand_type(a, a, a, b, b), do: {@full_house, {a, b}}
  def hand_type(b, b, a, a, a), do: {@full_house, {a, b}}

  def hand_type(a, a, a, b, c), do: {@three_of_a_kind, {a, c, b}}
  def hand_type(b, a, a, a, c), do: {@three_of_a_kind, {a, c, b}}
  def hand_type(b, c, a, a, a), do: {@three_of_a_kind, {a, c, b}}

  def hand_type(a, a, b, b, c), do: {@two_pairs, {b, a, c}}
  def hand_type(c, a, a, b, b), do: {@two_pairs, {b, a, c}}
  def hand_type(a, a, c, b, b), do: {@two_pairs, {b, a, c}}

  def hand_type(a, a, b, c, d), do: {@pair, {a, d, c, b}}
  def hand_type(b, a, a, c, d), do: {@pair, {a, d, c, b}}
  def hand_type(b, c, a, a, d), do: {@pair, {a, d, c, b}}
  def hand_type(b, c, d, a, a), do: {@pair, {a, d, c, b}}

  def hand_type(a, b, c, d, e) do
    cond do
      a + 1 == b && b + 1 == c && c + 1 == d && d + 1 == e ->
        {@straight, {e}}

      true ->
        {@high_card, {e, d, c, b, a}}
    end
  end

  def score_hand(hand) do
    hand
    |> Enum.map(fn card -> CardDeck.to_value(card) end)
    |> CardDeck.sort()
    |> IO.inspect()
    |> Poker.hand_type()
  end
end