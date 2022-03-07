# frozen_string_literal: true

require_relative 'contribution'

class ContributionSet # rubocop:disable Metrics/ClassLength
  PathMismatchError = Class.new(StandardError)
  InvalidPathError = Class.new(StandardError)

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

  attr_reader :store, :pathname

  protected

  attr_writer :store, :pathname

  def line_counts
    store.values_at(*contributors).map(&:line_count)
  end

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

    relative_base_pathname.to_path
  end

  def ensure_real_path!
    pathname.realpath
  rescue Errno::ENOENT
    raise InvalidPathError
  end

  def convert_to_relative_pathname(some_pathname)
    some_pathname.cleanpath.relative_path_from(
      some_pathname.relative? ? relative_base_pathname : absolute_base_pathname
    )
  end

  def relative_base_pathname
    @relative_base_pathname ||= Pathname.new(absolute_base_pathname.to_path).relative_path_from(absolute_base_pathname)
  end

  def absolute_base_pathname
    @absolute_base_pathname ||= Pathname.new(FileUtils.pwd)
  end
end
