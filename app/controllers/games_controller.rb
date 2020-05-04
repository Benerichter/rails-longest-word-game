require 'open-uri'
require 'json'
class GamesController < ApplicationController
  def new
    @letters = generate_grid(10)
  end

  def score
    @grid_letters = params[:letters]
    @user_letters = params[:user_letters]
    @score = run_game(@user_letters, @grid_letters)
  end

  def generate_grid(grid_size)
    Array.new(grid_size) { ('A'..'Z').to_a.sample }
  end

  def included?(guess, grid)
    guess.chars.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def run_game(attempt, grid)
    result = {}
    score_and_message = score_and_message(attempt, grid)
    result[:score] = score_and_message.first
    result[:message] = score_and_message.last
    result
  end

  def score_and_message(attempt, grid)
    if included?(attempt.upcase, grid)
      if english_word?(attempt)
        [@user_letters.length.to_i ** 2, "well done"]
      else
        [0, "not an english word"]
      end
    else
      [0, "not in the grid"]
    end
  end

  def english_word?(word)
    response = open("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(response.read)
    json['found']
  end
end
