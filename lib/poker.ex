defmodule Poker do
  @moduledoc """
  Documentation for `Poker`.
  """
  alias CardDeck, as: Deck

  @typedoc "Defines poker game"

  @enforce_keys [:players, :pile, :deck]
  defstruct players: %{},
            pile: [],
            deck: []

  @type t() :: %__MODULE__{
          players: %{String.t() => Deck.deck()},
          pile: Deck.deck(),
          deck: Deck.deck()
        }

  # typedstruct enforce: true do
  #  field :players, map, default: %{}
  #  field :pile, list, default: []
  #  field :deck, list, default: []
  # end

  @doc """
  Starts the game

  ## Examples

  """
  @spec start(list(String.t())) :: Poker.t()
  def start(num_players) do
    deal(Deck.shuffled(), num_players)
  end

  @spec deal(Deck.t(), list) :: Poker.t()
  def deal(deck, players) do
    game = %Poker{deck: deck, players: %{}, pile: []}

    players
    |> Enum.reduce(game, fn player, game ->
      {hand, deck} = Deck.deal(game.deck, 5)
      game = %{game | deck: deck}
      %{game | players: Map.put(game.players, player, Deck.sort(hand))}
    end)
  end

  @spec new_card(Poker.t(), integer, integer | list(integer)) :: Poker.t()
  def new_card(game, player, card) when is_integer(card) do
    new_card(game, player, [card])
  end

  def new_card(%Poker{players: players, deck: deck, pile: old_pile} = game, player, cards) do
    case players[player] do
      nil ->
        game

      hand ->
        {new_cards, new_deck} = Deck.deal(deck, length(cards))
        # player = Deck.drop(player, cards)
        {pile, hand_without_cards} = Deck.drop_to_pile(hand, cards)
        new_hand = Deck.sort(hand_without_cards ++ new_cards)

        %{
          game
          | deck: new_deck,
            players: Map.put(players, player, new_hand),
            pile: pile ++ old_pile
        }
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
  @result %{
    0 => "high card",
    1 => "pair",
    2 => "two pairs",
    3 => "three of a kind",
    4 => "straight",
    5 => "flush",
    6 => "full house",
    7 => "four of a kind",
    8 => "straight flush"
  }

  def hand_type([{2, z}, {3, z}, {4, z}, {5, z}, {14, z}]) do
    {@straight_flush, {5}}
  end

  def hand_type([{a, z}, {b, z}, {c, z}, {d, z}, {e, z}]) do
    cond do
      int(a) + 1 == int(b) && int(b) + 1 == int(c) && int(c) + 1 == int(d) && int(d) + 1 == int(e) ->
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
      int(a) + 1 == int(b) && int(b) + 1 == int(c) && int(c) + 1 == int(d) && int(d) + 1 == int(e) ->
        {@straight, {e}}

      true ->
        {@high_card, {e, d, c, b, a}}
    end
  end

  def print_player(game, player) do
    current_player = game.players[player]
    hand = current_player |> Enum.map(fn {r, s} -> [r, s, " "] end)
    {result, _} = hand_type(current_player)

    IO.iodata_to_binary([
      "Player: ",
      player,
      " Has: ",
      @result[result],
      " Cards: ",
      hand,
      "\n"
    ])
  end

  def score_game(game) do
  players_sorted_by_score =
    game.players
    |> Enum.map(fn {player, hand} -> {player, hand_type(hand)} end)
    |> Enum.sort_by(&elem(&1, 1), &>=/2)

    winning_hand = players_sorted_by_score |> hd |> elem(1)

    %{true: winners, false: losers} =
      players_sorted_by_score
    |> Enum.group_by(fn {_player, hand} -> hand == winning_hand end)

    {extract_players(winners), extract_players(losers)}
  end

  def extract_players(players) do
    Enum.map(players, fn {player, _hand} -> player end)
  end

  def pretty_score_game(game) do
    {winners, losers} = score_game(game)

    IO.puts([
      "Winner: \n",
      Enum.map(winners, fn p -> print_player(game, p) end),
      "Other: \n",
      Enum.map(losers, fn p -> print_player(game, p) end)
    ])
  end

  def score_hand(hand) do
    hand
    |> Enum.map(fn card -> Deck.to_value(card) end)
    |> CardDeck.sort()
    |> Poker.hand_type()
  end

  defp int(string) when is_bitstring(string), do: Deck.rank_value(string)
  defp int(integer), do: integer
end
