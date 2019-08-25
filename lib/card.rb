# -*- coding: utf-8 -*-

# Represents a playing card.
class Card
  SUIT_STRINGS = {
    :clubs    => "♣",
    :diamonds => "♦",
    :hearts   => "♥",
    :spades   => "♠"
  }

  VALUE_STRINGS = {
    :deuce => "2",
    :three => "3",
    :four  => "4",
    :five  => "5",
    :six   => "6",
    :seven => "7",
    :eight => "8",
    :nine  => "9",
    :ten   => "10",
    :jack  => "J",
    :queen => "Q",
    :king  => "K",
    :ace   => "A"
  }

  CARD_VALUE = {
    :ace => 1,
    :deuce => 2,
    :three => 3,
    :four  => 4,
    :five  => 5,
    :six   => 6,
    :seven => 7,
    :eight => 8,
    :nine  => 9,
    :ten   => 10,
    :jack  => 11,
    :queen => 12,
    :king  => 13,
  }

  # Returns an array of all suits.
  def self.suits
    SUIT_STRINGS.keys
  end

  # Returns an array of all values.
  def self.values
    VALUE_STRINGS.keys
  end

  attr_reader :suit, :value

  def initialize(suit, value)
    unless Card.suits.include?(suit) and Card.values.include?(value)
      raise "illegal suit (#{suit}) or value (#{value})"
    end

    @suit, @value = suit, value
  end

  def color
    return :red if self.suit == :spades || self.suit == :clubs
    return :black if self.suit == :diamonds || self.suit == :hearts
  end

  def card_value
    CARD_VALUE[self.value]
  end

  # Compares two cards to see if they're equal in suit & value.
  def ==(other_card)
    return false if other_card.nil?

    [:suit, :value].all? do |attr|
      self.send(attr) == other_card.send(attr)
    end
  end

  def tableau_stackable?(table_card)
    return true if table_card.nil?
    self.color != table_card.color && self.card_value == table_card.card_value - 1
  end

  def foundation_stackable?(foundation_card)
    if !foundation_card.is_a?(Card)
      if foundation_card == self.suit && self.value == :ace
        return true
      else  
        return false 
      end
    end
      
    self.suit == foundation_card.suit && self.card_value == foundation_card.card_value + 1
    
  end

  def to_s
    VALUE_STRINGS[value] + SUIT_STRINGS[suit]
  end
end

p card1 = Card.new(:hearts, :ten)
p card2 = Card.new(:spades, :jack)
p card3 = Card.new(:hearts, :jack)
p card4 = Card.new(:clubs, :ace)
p card1.foundation_stackable?(card2)
p card2.foundation_stackable?(card3)
p card3.foundation_stackable?(card1)
p card4.foundation_stackable?(:clubs)
p card4.tableau_stackable?(nil)

