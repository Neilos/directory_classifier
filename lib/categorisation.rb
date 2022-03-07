# frozen_string_literal: true

class Categorisation
  include Comparable

  UNKNOWN_CATEGORY = 'UNKNOWN'

  CategoryMismatchError = Class.new(StandardError)

  def initialize(score:, category: UNKNOWN_CATEGORY)
    @category = category
    @score = score
  end

  attr_reader :category, :score

  def +(other)
    raise CategoryMismatchError unless other.category == category

    new_categorisation = dup
    new_categorisation.score += other.score
    new_categorisation
  end

  def <=>(other)
    score <=> other.score
  end

  protected

  attr_writer :category, :score
end
