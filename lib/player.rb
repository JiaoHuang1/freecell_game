class Player
    def get_move
        puts "please enter a card's suit you'd like to move, choose from: 'hearts', 'diamonds', 'spades' or 'clubs'"
        suit = gets.chomp.to_sym
        puts "please enter a card's value you'd like to move, choose from: 'ace', 'deuce', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten', 'jack', 'queen' or 'king'"
        value = gets.chomp.to_sym
        
        [suit, value]
    end

    def get_designation
        puts "please enter a designation you want to move the card to, choose from: 'freecells', 'foundation', 'table'"
        designation = gets.chomp.to_sym
        puts "please enter the column of the designation, choose from: for 'freecell' and 'foundation' enter a number between 0 and 3; for 'table' enter a number between 0 and 7"
        column = gets.chomp.to_i

        [designation, column]
    end
end
