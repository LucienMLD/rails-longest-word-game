class GameController < ApplicationController
  def game
    @grid = Array.new(15) { ('A'..'Z').to_a[rand(26)] }
    @start_time = Time.now
  end

  def score
    @grid = params[:grid]
    @attempt = params[:attempt]
    @start_time = params[:start_time]
    t = DateTime.parse(@start_time)
    time = Time.now - t

    @result = { time: time }

    @result[:translation] = get_translation(@attempt)
    # @result[:score]
    @result[:message] = score_and_message(@attempt, @result[:translation], @grid, @result[:time])

     if @attempt.upcase.split.all? { |letter| @attempt.count(letter) <= @grid.count(letter) } && @result[:translation] != @attempt && @result[:translation] != nil
       @result[:message] = "You lose!"
       @score = 1
     else
       @result[:message] = "You win!"
       @score = 0
     end


  end

  def included?(guess, grid)
    guess.upcase.split.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def compute_score(attempt, time_taken)
    (time_taken > 60.0) ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end

  def score_and_message(attempt, translation, grid, time)
    if included?(attempt.upcase, grid)
      if translation
        score = compute_score(attempt, time)
        [score, "well done"]
      else
        @result[:message] = "not an english word"
      end
    else
        @result[:message] = "not in the grid"
    end
  end

  def get_translation(word)
    api_key = "db64232a-4a1f-4d5a-8bc2-0d232e708f91"
    begin
      response = open("https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=#{api_key}&input=#{word}")
      json = JSON.parse(response.read.to_s)
      if json['outputs'] && json['outputs'][0] && json['outputs'][0]['output'] && json['outputs'][0]['output'] != word
        return json['outputs'][0]['output']
      end
    rescue
      if File.read('/usr/share/dict/words').upcase.split("\n").include? word.upcase
        return word
      else
        return nil
      end
    end
  end
end
