# frozen_string_literal: true

class Contribution
  include Comparable

  UNKNOWN_CONTRIBUTOR = 'UNKNOWN'

  ContributorMismatchError = Class.new(StandardError)

  def initialize(line_count:, contributor: UNKNOWN_CONTRIBUTOR)
    @contributor = contributor
    @line_count = line_count
  end

  attr_reader :contributor, :line_count

  def +(other)
    raise ContributorMismatchError unless other.contributor == contributor

    new_contribution = dup
    new_contribution.line_count += other.line_count
    new_contribution
  end

  def <=>(other)
    line_count <=> other.line_count
  end

  protected

  attr_writer :contributor, :line_count
end
