class RoundResultMessage
  attr_accessor :action, :opponent_response, :result

  def initialize(action:, opponent_response:, result:)
    @action = action
    @opponent_response = opponent_response
    @result = result
  end
end
