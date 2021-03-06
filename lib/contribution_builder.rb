# frozen_string_literal: true

require_relative 'contribution'

class ContributionBuilder
  GIT_NAME_REGEX = /^\w{8}.*\((?<git_name>[\w\s]+)\s\d{4}-\d{2}-\d{2}/

  class << self
    def from_git_blame_line(blame_line:, contributors_lookup:)
      git_name = blame_line.match(GIT_NAME_REGEX)&.named_captures&.fetch('git_name')&.rstrip

      Contribution.new(
        contributor: contributors_lookup.fetch(git_name, Contribution::UNKNOWN_CONTRIBUTOR),
        line_count: 1
      )
    end
  end
end
