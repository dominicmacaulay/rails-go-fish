# frozen_string_literal: true

# go fish player class
class Player
  attr_reader :id, :name

  def initialize(id, name)
    @id = id
    @name = name
  end
end
