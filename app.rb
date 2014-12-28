require 'rubygems'
require 'sinatra'
require 'pry'

set :sessions, true

BLACKJACK_AMOUNT = 21
DEALER_HIT_MAX = 17

helpers do
  def calculate_total_value(cards)
    total_value = 0
    cards.each do |suit, value|
      if value === "A"
        total_value += (total_value + 11) <= BLACKJACK_AMOUNT ? 11 : 1
      else
        total_value += value.to_i === 0 ? 10 : value.to_i
      end
    end
    total_value
  end

  def winner!(msg)
    session[:player_money] += session[:bet_amount]
    @winner = "#{msg}, now you have #{session[:player_money]}"
    @game_over = true
  end

  def losser!(msg)
    session[:player_money] -= session[:bet_amount]
    @losser = "#{msg}, now you have #{session[:player_money]}"
    @game_over = true
  end

  def tier!(msg)
    @tier = "#{msg}, now you have #{session[:player_money]}"
    @game_over = true
  end

  def card_image(card)
    suit, value = card
    suit = case suit
      when "C" then "clubs"
      when "D" then "diamonds"
      when "S" then "spades"
      when "H" then "hearts"
    end

    value = case value
      when "J" then "jack"
      when "Q" then "queen"
      when "K" then "king"
      when "A" then "Ace"
      else value
    end

    "<img src='/images/cards/#{suit}_#{value}.jpg' height='190' width='140'>"
  end
end

get "/" do
  if session[:player_name]
    redirect "/game"
  else
    redirect "/new_player"
  end
end

get "/new_player" do
  session[:player_money] = 500.0
  erb :new_player
end

post "/new_player" do
  session[:player_name] = params[:player_name]
  redirect "/set_bet"
end

get "/set_bet" do
  erb :set_bet
end

post "/set_bet" do
  bet_amount = params[:bet_amount].to_f
  if bet_amount <= 0.0
    @error = "Your bet amount must greater than 0.0 & less or equal than player money & must numeric"
    erb :set_bet
  else
    session[:bet_amount] = bet_amount
    redirect "/game"
  end
end

get "/game_over" do
  erb :game_over
end

# player's actions
post "/game/player/hit" do
  session[:player_cards] << session[:deck].pop
  player_amount = calculate_total_value(session[:player_cards])

  if player_amount === BLACKJACK_AMOUNT
    winner!("#{session[:player_name]} hit blackjack.")
  elsif player_amount > BLACKJACK_AMOUNT
    losser!("it look like #{session[:player_name]} are busted")
  end
  erb :game
end

post "/game/player/stay" do
  session[:player_stay] = true
  dealer_amount = calculate_total_value(session[:dealer_cards])
  player_amount = calculate_total_value(session[:player_cards])
  if dealer_amount > player_amount && dealer_amount < BLACKJACK_AMOUNT
    losser!("The dealer hit blackjack.")
  end
  erb :game
end

# dealer's actions
post "/game/dealer/hit" do
  # if calculate_total_value(session[:dealer_cards]) < DEALER_HIT_MAX
  session[:dealer_cards] << session[:deck].pop

  dealer_amount = calculate_total_value(session[:dealer_cards])
  player_amount = calculate_total_value(session[:player_cards])
  if dealer_amount === BLACKJACK_AMOUNT
    losser!("The dealer hit blackjack.")
  elsif dealer_amount === player_amount
    tier!("It is a tie." )
  elsif dealer_amount > BLACKJACK_AMOUNT
    winner!("#{session[:player_name]} hit blackjack.")
  elsif dealer_amount > player_amount && dealer_amount < BLACKJACK_AMOUNT
    losser!("The dealer hit blackjack.")
  end
  erb :game
end

# game
get "/game" do
  redirect "/set_bet" if !session[:bet_amount]
  redirect "/new_player" if !session[:player_name] || !session[:player_money]
  redirect "/game_over" if session[:player_money] <= 0.0

  session[:player_stay] = false

  suits = ["H", "D", "C", "S"]
  cards = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]
  session[:deck] = suits.product(cards).shuffle!

  session[:dealer_cards] = Array.new
  session[:player_cards] = Array.new

  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop

  erb :game
end
