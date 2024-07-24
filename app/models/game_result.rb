class GameResult
  attr_reader :winners

  def initialize(winners)
    @winners = winners
  end

  def display_for(player)
    winner = winners.detect { |w| w.id == player.id }
    if winner.nil?
      third_person_message
    else
      first_person_message(winner)
    end
  end

  def ==(other)
    return false unless winners.count == other.winners.count
    return false unless winners.all? { |winner| other.winners.include?(winner) }

    true
  end

  private

  def first_person_message(player)
    if winners.count == 1
      one_winner = winners.first
      return "You won the game with #{one_winner.book_count} books totalling in #{one_winner.total_book_value}"
    end

    winners_duplicate = winners.dup
    winners_duplicate.delete(player)
    message = 'You '
    message.concat(create_multiple_winners_string(winners_duplicate))
  end

  def third_person_message
    if winners.count == 1
      one_winner = winners.first
      return "#{one_winner.name} won the game with #{one_winner.book_count} books totalling in #{one_winner.total_book_value}"
    end

    create_multiple_winners_string
  end

  def create_multiple_winners_string(winners = self.winners)
    message = ''
    winners.each do |winner|
      message.concat('and ') if winner == winners.last
      message.concat("#{winner.name} ")
      message.concat(', ') if winner != winners.last && winner != winners[-2]
    end
    message.concat("tied with #{winners.first.book_count} books totalling in #{winners.first.total_book_value}")
  end
end
