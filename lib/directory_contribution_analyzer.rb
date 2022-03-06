# frozen_string_literal: true

require_relative 'contribution'
require_relative 'contribution_builder'
require_relative 'contribution_set'

class DirectoryContributionAnalyzer
  def initialize(contributors_lookup:, path:)
    @contributors_lookup = contributors_lookup
    @path = path
  end

  def directory_contribution_set
    return file_contribution_set unless path_is_directory?
    return empty_contribution_set if directory_is_empty?

    subdirectory_contribution_sets.reduce(&:+)
  end

  private

  attr_reader :contributors_lookup, :path

  def subdirectory_contribution_sets
    Dir.each_child(path).map do |child_path|
      self.class.new(
        contributors_lookup: contributors_lookup,
        path: File.join(path, child_path)
      ).directory_contribution_set
    end
  end

  def file_contribution_set
    blame_lines.each_with_object(empty_contribution_set) do |blame_line, file_contributions|
      contribution = ContributionBuilder.from_git_blame_line(
        blame_line: blame_line,
        contributors_lookup: contributors_lookup
      )

      file_contributions << contribution
    end
  end

  def blame_lines
    @blame_lines ||= `git blame #{path}`.to_s.split(/\n/)
  end

  def path_is_directory?
    Dir.exist?(path)
  end

  def directory_is_empty?
    Dir.empty?(path)
  end

  def empty_contribution_set
    ContributionSet.new(path: path, contributors: contributors)
  end

  def contributors
    contributors_lookup.values.uniq.push(Contribution::UNKNOWN_CONTRIBUTOR)
  end

  def empty_unknown_file_contribution
    @empty_unknown_file_contribution ||= Contribution.new(
      path: path,
      contribution_count: 0,
      total_line_count: blame_lines.count
    )
  end
end
