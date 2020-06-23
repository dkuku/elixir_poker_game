defmodule PokerTest do
  use ExUnit.Case
  doctest Poker

  @high_card 0
  @pair 1
  @two_pairs 2
  @three_of_a_kind 3
  @straight 4
  @flush 5
  @full_house 6
  @four_of_a_kind 7
  @straight_flush 8

  test "straight_flush" do
    assert [{2, "D"}, {3, "D"}, {4, "D"}, {5, "D"}, {6, "D"}]
           |> Poker.score_hand() == {@straight_flush, {6}}

    assert [{"A", "D"}, {"Q", "D"}, {"K", "D"}, {"J", "D"}, {"T", "D"}]
           |> Poker.score_hand() == {@straight_flush, {14}}

    assert [{"A", "D"}, {"2", "D"}, {"3", "D"}, {"4", "D"}, {"5", "D"}]
           |> Poker.score_hand() == {@straight_flush, {5}}
  end

  test "four of an kind" do
    assert [{2, "C"}, {2, "D"}, {2, "H"}, {2, "S"}, {6, "D"}]
           |> Poker.score_hand() == {@four_of_a_kind, {2, 6}}

    assert [{"A", "D"}, {"A", "C"}, {"A", "H"}, {"K", "D"}, {"A", "S"}]
           |> Poker.score_hand() == {@four_of_a_kind, {14, 13}}

    assert [{"9", "D"}, {"T", "S"}, {"T", "H"}, {"T", "C"}, {"T", "D"}]
           |> Poker.score_hand() == {@four_of_a_kind, {10, 9}}
  end

  test "full house" do
    assert [{2, "C"}, {2, "D"}, {2, "H"}, {4, "S"}, {4, "D"}]
           |> Poker.score_hand() == {@full_house, {2, 4}}

    assert [{"A", "D"}, {"A", "C"}, {"Q", "H"}, {"Q", "D"}, {"A", "S"}]
           |> Poker.score_hand() == {@full_house, {14, 12}}

    assert [{"9", "D"}, {"9", "S"}, {"T", "H"}, {"T", "C"}, {"T", "D"}]
           |> Poker.score_hand() == {@full_house, {10, 9}}
  end

  test "flush" do
    assert [{2, "D"}, {3, "D"}, {4, "D"}, {5, "D"}, {7, "D"}]
           |> Poker.score_hand() == {@flush, {7, 5, 4, 3, 2}}

    assert [{"A", "D"}, {"Q", "D"}, {"K", "D"}, {"J", "D"}, {"9", "D"}]
           |> Poker.score_hand() == {@flush, {14, 13, 12, 11, 9}}

    assert [{"A", "D"}, {"2", "D"}, {"3", "D"}, {"4", "D"}, {"6", "D"}]
           |> Poker.score_hand() == {@flush, {14, 6, 4, 3, 2}}
  end

  test "straight" do
    assert [{2, "C"}, {3, "D"}, {4, "D"}, {5, "D"}, {6, "D"}]
           |> Poker.score_hand() == {@straight, {6}}

    assert [{"A", "D"}, {"Q", "C"}, {"K", "H"}, {"J", "S"}, {"T", "D"}]
           |> Poker.score_hand() == {@straight, {14}}

    assert [{"A", "D"}, {"2", "D"}, {"3", "H"}, {"4", "H"}, {"5", "D"}]
           |> Poker.score_hand() == {@straight, {5}}
  end

  test "three of an kind" do
    assert [{2, "C"}, {2, "D"}, {2, "H"}, {4, "S"}, {6, "D"}]
           |> Poker.score_hand() == {@three_of_a_kind, {2, 6, 4}}

    assert [{"A", "D"}, {"A", "C"}, {"Q", "H"}, {"K", "D"}, {"A", "S"}]
           |> Poker.score_hand() == {@three_of_a_kind, {14, 13, 12}}

    assert [{"9", "D"}, {"J", "S"}, {"T", "H"}, {"T", "C"}, {"T", "D"}]
           |> Poker.score_hand() == {@three_of_a_kind, {10, 11, 9}}
  end

  test "two pairs" do
    assert [{2, "C"}, {2, "D"}, {6, "H"}, {4, "S"}, {6, "D"}]
           |> Poker.score_hand() == {@two_pairs, {6, 2, 4}}

    assert [{"A", "D"}, {"A", "C"}, {"J", "H"}, {"J", "D"}, {"6", "S"}]
           |> Poker.score_hand() == {@two_pairs, {14, 11, 6}}

    assert [{"8", "D"}, {"8", "S"}, {"5", "H"}, {"5", "C"}, {"4", "D"}]
           |> Poker.score_hand() == {@two_pairs, {8, 5, 4}}
  end

  test "pair" do
    assert [{2, "C"}, {3, "D"}, {4, "H"}, {4, "S"}, {5, "D"}]
           |> Poker.score_hand() == {@pair, {4, 5, 3, 2}}

    assert [{"A", "D"}, {"A", "C"}, {"Q", "H"}, {"K", "D"}, {"3", "S"}]
           |> Poker.score_hand() == {@pair, {14, 13, 12, 3}}

    assert [{"9", "D"}, {"J", "S"}, {"4", "H"}, {"T", "C"}, {"T", "D"}]
           |> Poker.score_hand() == {@pair, {10, 11, 9, 4}}
  end

  test "high card" do
    assert [{2, "C"}, {3, "D"}, {7, "H"}, {4, "S"}, {5, "D"}]
           |> Poker.score_hand() == {@high_card, {7, 5, 4, 3, 2}}

    assert [{"A", "D"}, {"T", "C"}, {"Q", "H"}, {"K", "D"}, {"3", "S"}]
           |> Poker.score_hand() == {@high_card, {14, 13, 12, 10, 3}}

    assert [{"9", "D"}, {"J", "S"}, {"4", "H"}, {"5", "C"}, {"A", "D"}]
           |> Poker.score_hand() == {@high_card, {14, 11, 9, 5, 4}}
  end

  test "straight_flush wins" do
    {@straight_flush, {14}}
    |> ties({@straight_flush, {14}})
    |> wins({@straight_flush, {13}})
    |> wins({@straight_flush, {2}})
    |> wins({@four_of_a_kind, {12, 2}})
    |> wins({@full_house, {2, 4}})
    |> wins({@straight, {9}})
    |> wins({@flush, {9, 6, 4, 3, 2}})
    |> wins({@two_pairs, {2}})
    |> wins({@pair, {12, 4, 3, 2}})
    |> wins({@high_card, {14, 11, 9, 5, 4}})
  end

  test "four_of_a_kind wins" do
    {@four_of_a_kind, {14, 13}}
    |> ties({@four_of_a_kind, {14, 13}})
    |> loses({@straight_flush, {13, 14}})
    |> loses({@straight_flush, {5}})
    |> wins({@four_of_a_kind, {12, 2}})
    |> wins({@straight, {14}})
    |> wins({@full_house, {2, 4}})
    |> wins({@straight, {9}})
    |> wins({@flush, {9, 6, 4, 3, 2}})
    |> wins({@two_pairs, {2}})
    |> wins({@pair, {12, 4, 3, 2}})
    |> wins({@high_card, {14, 11, 9, 5, 4}})
  end

  test "full_house wins" do
    {@full_house, {12, 13}}
    |> ties({@full_house, {12, 13}})
    |> loses({@full_house, {12, 14}})
    |> loses({@straight_flush, {13, 14}})
    |> loses({@straight_flush, {5}})
    |> loses({@four_of_a_kind, {12, 2}})
    |> wins({@full_house, {12, 11}})
    |> wins({@straight, {14}})
    |> wins({@full_house, {2, 4}})
    |> wins({@straight, {9}})
    |> wins({@flush, {9, 6, 4, 3, 2}})
    |> wins({@two_pairs, {2}})
    |> wins({@pair, {12, 4, 3, 2}})
    |> wins({@high_card, {14, 11, 9, 5, 4}})
  end

  def wins(left, right) do
    assert(left > right)
    left
  end
  def loses(left, right) do
    assert(left < right)
    left
  end
  def ties(left, right) do
    assert(left == right)
    left
  end
end
