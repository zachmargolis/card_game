require 'card_game/card'
require 'card_game/ordering'
require 'card_game/trick'

module CardGame
  # Utility methods for modeling five hundred.
  class FiveHundred
    # @private
    OPPOSITES = {
      Suit.hearts   => Suit.diamonds,
      Suit.diamonds => Suit.hearts,
      Suit.clubs    => Suit.spades,
      Suit.spades   => Suit.clubs,
    }

    # Returns the winning card of a given trick, accounting for trumps, bowers,
    # and the Joker.
    #
    # @param trick [Trick]
    # @return [Card]
    def self.winning_card(trick)
      led = trick.cards.first

      raise(ArgumentError, "Trick must contain at least one card") unless led

      opposite = OPPOSITES.fetch(trick.trump) { Suit.none }
      left_bower  = Card.new(rank: Rank.jack, suit: opposite)
      right_bower = Card.new(rank: Rank.jack, suit: trick.trump)
      joker       = Card.new(rank: Rank.joker, suit: Suit.none)

      trick.cards.sort_by(&Ordering.composite(
        Ordering.match(joker),
        Ordering.match(right_bower),
        Ordering.match(left_bower),
        Ordering.suit(trick.trump),
        Ordering.suit(led.suit),
        Ordering.ace_high,
      )).last
    end

    # @private
    LOWEST_RANKS = {
      Color.red   => Card.unsuited(Rank.numbered(4)),
      Color.black => Card.unsuited(Rank.numbered(5)),
    }

    # Creates a deck suitable for Five Hundred with four players.
    #
    # @return [Array<Card>]
    def self.deck
      ordering = Ordering.ace_high

      (Rank.all - [Rank.joker]).product(Suit.all - [Suit.none])
        .map {|rank, suit| Card.new(rank: rank, suit: suit) }
        .select {|card|
          ordering[card] >= ordering[LOWEST_RANKS.fetch(card.suit.color)]
        } + [Card.new(rank: Rank.joker, suit: Suit.none)]
    end
  end
end
