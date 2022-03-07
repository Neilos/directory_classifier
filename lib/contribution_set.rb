# frozen_string_literal: true

require_relative 'contribution'

class ContributionSet
  PathMismatchError = Class.new(StandardError)
  InvalidPathError = Class.new(StandardError)

  RELATIVE_BASE_PATH = Pathname.new('.').cleanpath
  ABSOLUTE_BASE_PATH = RELATIVE_BASE_PATH.realdirpath

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

  def path
    pathname.to_path
  end

  def +(other)
    new_contribution_set = self.class.new(path: path_shared_with(other))
    new_contribution_set.store = store.merge(other.store) { |_key, v1, v2| v1 + v2 }
    new_contribution_set
  end

  def contributions
    store.values
  end

  def contributors
    store.keys
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
      contributions: store.transform_values(&:line_count),
      primary_contributor: primary_contributor,
      total_number_of_lines: total_number_of_lines
    }
  end

  attr_reader :store, :pathname

  protected

  attr_writer :store, :pathname

  def path_segments
    path.split('/')
  end

  def path_length
    path_segments.count
  end

  private

  def path_shared_with(other_set)
    return path if pathname == other_set.pathname

    common_base_path(other_set)
  end

  def common_base_path(other_set)
    max_path_length = [path_length, other_set.path_length].max

    max_path_length.times.reverse_each do |index|
      partial_path_segments = path_segments.slice(0, index + 1)
      other_set_partial_path_segments = other_set.path_segments.slice(0, index + 1)
      return File.join(partial_path_segments) if partial_path_segments == other_set_partial_path_segments
    end

    RELATIVE_BASE_PATH.to_path
  end

  def for_parent_directory?(other_contribution)
    path.start_with?(other_contribution.path)
  end

  def for_subdirectory?(other_contribution)
    other_contribution.path.start_with?(path)
  end

  def ensure_real_path!
    pathname.realdirpath
  rescue Errno::ENOENT
    raise InvalidPathError
  end

  def convert_to_relative_pathname(some_pathname)
    some_pathname.cleanpath.relative_path_from(some_pathname.relative? ? RELATIVE_BASE_PATH : ABSOLUTE_BASE_PATH)
  end
end
