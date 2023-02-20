require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = generate_letters(10).join
    @start_time = Time.now
    session[:letters] = @letters
    session[:start_time] = @start_time
  end

  def score
    letters = params[:letters]
    start_time = Time.parse(session[:start_time])
    end_time = Time.now
    @result = run_game(@attempt, letters, start_time, end_time)
  end

  private

  def generate_letters(count)
    letters_array = Array.new(count) { ('A'..'Z').to_a[rand(26)] }
  end

  def included?(guess, letters)
    guess.split("").all? { |letter| letters.include? letter }
  end

  def compute_score(attempt, time_taken)
    (time_taken > 60.0) ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def run_game(attempt, letters, start_time, end_time)
    result = { time: end_time - start_time }

    # result[:translation] = get_translation(attempt)
    result[:score], result[:message] = score_and_message(
      attempt, result[:translation], letters, result[:time])

    result
  end

  def score_and_message(attempt, translation, letters, time)
    if translation
      if included?(attempt.upcase, letters)
        score = compute_score(attempt, time)
        [score, "well done"]
      else
        [0, "not in the grid"]
      end
    else
      [0, "not an english word"]
    end
  end

  # def get_translation(word)
  #   JSON.parse("https://www.dictionary.com/browse/#{word}").read.to_s
  # end
end
