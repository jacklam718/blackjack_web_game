class Player
  attr_reader :name, :ledger, :cards

  def initialize(name, ledger)
    @name = name
    @ledher = ledger
    @cards = [ ]
  end

  def add_ledger(amount)
    @ledger += amount
  end

  def stract_ledger(amount)
    @ledger -= amount
  end

  def add_card(card)
    @cards << card
  end
end

class Computer < Player
  def initialize(name, ledger=0)
    super(name, ledger)
  end
end

class Human < Player
  def initialize(name, ledger=0)
    super(name, ledger)
  end
end

class Card
  attr_reader :suits, :cards, :face_value

  def initialize
    @suits = ["Spades", "Hearts", "Diamonds", "Clubs"]
    @nums = ["Ace","Two", "Three" , "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten", "Jack", "Queen", "King"]
    @cards = [ ]
    @face_value = { }

    @suits.each do |suit|
      @nums.each_with_index do |num, value|
        @cards << {num => suit}
        if ["Ten", "Jack", "Queen", "King"].include?(num)
          @face_value[num] = 10
          next
        end
        @face_value[num] = value + 1
      end
    end
    puts @face_value
  end
end

class Dealer
  attr_reader :card

  def initialize
    initialize_card
  end

  def initialize_card
    @card = Card.new
  end

  def deal
    @card.cards.pop
  end

  def shuffle
    @card.cards.shuffle!
  end
end

class Blackjack
  attr_reader :computer, :human
  def initialize
    @computer = Computer.new("computer", 500)
    @human = Human.new("user", 500)
  end

  def check_winner
  end

  def check_loser
  end

  def start
  end
end
