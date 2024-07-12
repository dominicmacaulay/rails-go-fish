require 'rails_helper'

RSpec.describe RoundResultMessage do
  it 'returns messages that it was created with' do
    message = RoundResultMessage.new(action: 'action', opponent_response: 'opponent response', result: 'result')
    expect(message.action).to eq 'action'
    expect(message.opponent_response).to eq 'opponent response'
    expect(message.result).to eq 'result'
  end
end
