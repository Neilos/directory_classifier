# frozen_string_literal: true

require_relative 'contribution'
require_relative 'path_traversal'

class ContributionSet
  include PathTraversal

  def initialize(path:, contributors: [])
    @pathname = convert_to_relative_pathname(Pathname.new(path))

    ensure_real_path!

    @store = contributors.each_with_object({}) do |contributor, contribution_store|
      contribution_store[contributor] = Contribution.new(contributor: contributor, line_count: 0)
    end
  end

  def <<(contribution)
    if store[contribution.contributor]
      store[contribution.contributor] += contribution
    else
      store[contribution.contributor] = contribution
    end
  end

  def +(other)
    new_contribution_set = self.class.new(path: path_shared_with(other))
    new_contribution_set.store = store.merge(other.store) { |_key, v1, v2| v1 + v2 }
    new_contribution_set
  end

  def contributions
    store.values_at(*contributors)
  end

  def contributors
    store.keys.sort
  end

  def largest_contribution
    contributions.reject { |contribution| contribution.contributor == Contribution::UNKNOWN_CONTRIBUTOR }.max
  end

  def primary_contributor
    largest_contribution.contributor
  end

  def total_number_of_lines
    contributions.sum(&:line_count)
  end

  def as_json
    {
      path: path,
      contributions: store.transform_values(&:line_count),
      primary_contributor: primary_contributor,
      total_number_of_lines: total_number_of_lines
    }
  end

  def csv_headers
    ['path', 'total_number_of_lines', 'primary_contributor', *contributors]
  end

  def as_csv_row
    [path, total_number_of_lines, primary_contributor, *line_counts]
  end

  attr_reader :store

  protected

  attr_writer :store

  def line_counts
    store.values_at(*contributors).map(&:line_count)
  end
end
