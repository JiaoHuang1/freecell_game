require_relative 'card'
require_relative 'player'
require 'byebug'

# Represents a deck of playing cards.
class Deck
  attr_reader :tableau
  
  def self.all_cards
    all_cards = []
    count = 0
    Card.suits.each do |suit|
      Card.values.each do |value|
        all_cards << Card.new(suit, value)
      end
    end
    all_cards.shuffle
  end

  def initialize(cards = Deck.all_cards)
    idx = 0
    @tableau = Array.new(8) {Array.new}
    while idx < cards.length
      @tableau[idx % 8] << cards[idx]
      idx += 1
    end
    @freecells = Array.new(4, "___")
    @foundation_pile = Array.new(4) {Array.new}
    Card.suits.each_with_index do |suit, i|
      @foundation_pile[i] << suit
    end
    @player = Player.new
  end

  def render
    self.tableau.each do |row|
      puts row.join("      ")
    end
    puts "---------FreeCell---------       ----------FoundationPile-----------"
    puts "#{@freecells.join("    ")}             #{@foundation_pile.join("    ")}"
    puts "--------------------------Tableau------------------------------------"
    longest_subpile = @tableau.map {|sub_pile| sub_pile.count}.max
    transposed = Array.new(8) {Array.new(longest_subpile, nil)}
    self.tableau.each_with_index do |sub_pile, row_idx|
      sub_pile.each_with_index do |card, col_idx|
        transposed[col_idx][row_idx] = card
      end
    end
    transposed.each do |row|
      puts row.join("      ")
    end
  end

  def max_move_cards
    @freecells.count {|pos| !pos.is_a?(Card)} + 1
  end

  def get_position(card)
    if @freecells.include?(card)
      return [:freecells, @freecells.index(card)]
    end

    @foundation_pile.each_with_index do |sub_pile, idx|
      if sub_pile.include?(card)
        return [:foundation_pile, [idx, sub_pile.index(card)]]
      end
    end

    @tableau.each_with_index do |sub_pile, idx|
      if sub_pile.include?(card)
        return [:tableau, [idx, sub_pile.index(card)]]
      end
    end

    nil
  end

  def moveable?(card)
    pos = get_position(card)
    if pos.nil?
      raise 'card not exist'
    end

    return true if pos[0] == :freecells

    if pos[0] == :foundation_pile
      if pos[1][1] == @foundation_pile[pos[1][0]].length
        return true
      else
        return false 
      end
    end

    if pos[0] == :tableau
      pile_num, pile_idx = pos[1]
      while pile_idx < @tableau[pile_num].length - 1
        return false if !@tableau[pile_num][pile_idx + 1].tableau_stackable?(card)
        pile_idx += 1
      end
      return true
    end
  end


  def move_cards(move_card, designation)
    if !moveable?(move_card)
      return
    end
    pos = get_position(move_card)
    return if pos.nil?
    ### moving card from tableau/freecells to freecells
    if designation[0] == :freecells && @freecells[designation[1]] == "___"
      if pos[0] == :tableau
        pile_num, pile_idx = pos[1]
        if pile_idx == @tableau[pile_num].length - 1
          moving_card = @tableau[pile_num].pop
          @freecells[designation[1]] = moving_card
        end
      elsif pos[0] == :freecells
        moving_card = @freecells[pos[1]]
        @freecells[designation[1]] = moving_card
        @freecells[pos[1]] = "___"
      end
    end

    ### moving card from freecells/tableau to foundation_pile
    if designation[0] == :foundation
      last_card_on_designated_subpile = @foundation_pile[designation[1]][-1]
      if pos[0] == :freecells
        
        if move_card.foundation_stackable?(last_card_on_designated_subpile)
          moving_card = @freecells[pos[1]]
          @foundation_pile[designation[1]] << moving_card
          @freecells[pos[1]] = "___"
        end
      elsif pos[0] = :tableau
        pile_num, pile_idx = pos[1]
        if move_card.foundation_stackable?(last_card_on_designated_subpile) && pile_idx == @tableau[pile_num].length - 1
          moving_card = @tableau[pile_num].pop
          @foundation_pile[designation[1]] << moving_card
        end
      end
    end

    ### moving card from freecell/foundation/tableau to tableau
    if designation[0] = :tableau
      last_card_on_designated_subpile = @tableau[designation[1]][-1]
      if pos[0] == :freecells
        if move_card.tableau_stackable?(last_card_on_designated_subpile)
          @tableau[designation[1]] << moving_card
          @freecells[pos[1]] = "___"
        end
      elsif pos[0] == :foundation
        pile_num, pile_idx = pos[1]
        if move_card.tableau_stackable?(last_card_on_designated_subpile)
          moving_card = @foundation_pile[pile_num].pop
          @tableau[designation[1]] << moving_card
        end
      else pos[0] == :tableau
        pile_num, pile_idx = pos[1]
        if move_card.tableau_stackable?(last_card_on_designated_subpile)
          moved_arr = []
          pop_num = @tableau[pile_num].length - pile_idx
          pop_num.times do
            moved_arr.unshift(@tableau[pile_num].pop)
          end
          @tableau[designation[1]].concat(moved_arr)
        end
      end
    end
  end

  def play_turn
    suit, value = @player.get_move
    designation = @player.get_designation
    card = Card.new(suit, value)
    self.move_cards(card, designation)
  end

  def win?
    @foundation_pile.each do |sub_pile| 
      if !sub_pile[-1].is_a?(Card) || sub_pile[-1].value == :king
        return false
      end
    end
    true
  end

  def run
    self.render
    until win?
      self.play_turn
      self.render
    end
    puts "you win!"
    self.render
  end


end



deck = Deck.new
deck.run



