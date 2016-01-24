class Card
  attr_accessor :rank, :suit

  def initialize(rank, suit)
    @rank = rank
    @suit = suit
  end

  def to_s
    "#{@rank.to_s.capitalize} of #{@suit.to_s.capitalize}"
  end

  def inspect
    "#{@rank.to_s.capitalize} of #{@suit.to_s.capitalize}"
  end

  def ==(other)
    @rank == other.rank and @suit == other.suit
  end
end

module Sizer
  def size
    @cards.size
  end
end

class Deck
  include Sizer
  include Enumerable

  class Hand
    include Sizer
    def initialize(cards)
      @cards = cards
    end

    def king_and_queen?(cards)
      kings_queens = cards.select do |card|
        card.rank == :queen or card.rank == :king
      end
      kings_queens.permutation(2).any? do | (card_first, card_second) |
        equal_suits = card_first.suit == card_second.suit
        different_ranks = card_first.rank != card_second.rank
        equal_suits and different_ranks
      end
    end
  end

  attr_accessor :cards
  HAND_SIZE = 52
  RANKS = [2, 3, 4, 5, 6, 7, 8, 9, 10, :jack, :queen, :king, :ace]
  SUITS = [:spades, :hearts, :diamonds, :clubs]

  class << self
    def generate_full_deck
      self::RANKS.product(self::SUITS).map { |x| Card.new(x.first, x.last) }
    end

    def sorting_ranks_suit(ranks, suits, card_first, card_second)
      comp_suit = suits.index(card_first.suit) <=> suits.index(card_second.suit)
      comp_rank = ranks.index(card_second.rank) <=> ranks.index(card_first.rank)
      return comp_suit unless comp_suit == 0
      return comp_rank
    end

    def sorting(card_first, card_second)
      sorting_ranks_suit(self::RANKS, self::SUITS, card_first, card_second)
    end
  end

  def initialize(cards = nil)
    if cards.nil?
      @cards = self::class::generate_full_deck
      sort
    else
      @cards = cards.clone
    end
  end

  def draw_top_card
    @cards.shift
  end

  def draw_bottom_card
    @cards.pop
  end

  def top_card
    @cards.first
  end

  def bottom_card
    @cards.last
  end

  def shuffle
    @cards.shuffle!
  end

  def sort
    @cards.sort!(&self::class.method(:sorting))
  end

  def each
    @cards.each { |card| yield(card) }
  end

  def to_s
    @cards.join("\n").strip
  end

  def deal_elements
    deal_elements = []
    smaller = [self::class::HAND_SIZE,  @cards.size].min
    1.upto(smaller) { deal_elements << draw_top_card }
    deal_elements
  end
end


class WarDeck < Deck
  RANKS = [2, 3, 4, 5, 6, 7, 8, 9, 10, :jack, :queen, :king, :ace]
  HAND_SIZE = 26

  class HandWarDeck < Hand

    def play_card
      @cards.pop
    end

    def allow_face_up?
      @cards.size <= 3
    end
  end

  def deal
    HandWarDeck.new(deal_elements)
  end
end


class BeloteDeck < Deck
  RANKS = [7, 8, 9, :jack, :queen, :king, 10, :ace]

  HAND_SIZE = 8

  def deal
    HandBeloteDeck.new(deal_elements)
  end

  class HandBeloteDeck < Hand

    def highest_of_suit(suit)
      @cards.sort(&BeloteDeck.method(:sorting)).find do |card|
        card.suit == suit
      end
    end

    def belote?
      king_and_queen?(@cards)
    end

    def tierce?
      sequence(3, @cards)
    end

    def quarte?
      sequence(4, @cards)
    end

    def quint?
      sequence(5, @cards)
    end

    def carre(suit)
      grouped_cards = @cards.group_by { |card| card.rank }
      grouped_cards[suit].nil? ? false : grouped_cards[suit].size == 4
    end

    def carre_of_jacks?
      carre(:jack)
    end

    def carre_of_nines?
      carre(9)
    end

    def carre_of_aces?
      carre(:ace)
    end

    def consecutive?(cards)
      all_consecutive = true
      cards.each_cons(2) do | (card_first, card_second) |
        if RANKS.index(card_first.rank) - 1 != RANKS.index(card_second.rank)
          all_consecutive = false
        end
      end
      all_consecutive
    end

    def sequence(number, cards)
      cards.sort(&BeloteDeck.method(:sorting))
                    .group_by { |card| card.suit }.map do |cards|
        groups = cards.last.each_cons(number).to_a
        groups.map! { |cards| consecutive? cards }
        groups.any?
      end .any?
    end
  end
end

class SixtySixDeck < Deck
  RANKS = [9, :jack, :queen, :king, 10, :ace]
  HAND_SIZE = 6

  def deal
    HandSixtySixDeck.new(deal_elements)
  end

  class HandSixtySixDeck < Hand

    def twenty?(trump_suit)
      cards_no_trump_suit = @cards.reject { |card| card.suit == trump_suit }
      king_and_queen?(cards_no_trump_suit)
    end

    def forty?(trump_suit)
      cards_trump_suit = @cards.select { |card| card.suit == trump_suit }
      king_and_queen?(cards_trump_suit)
    end
  end
end
