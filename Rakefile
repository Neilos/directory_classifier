# frozen_string_literal: true

require 'rspec/core/rake_task'
require 'pry'
require_relative 'lib/contributors_file_parser'
require_relative 'lib/directory_contribution_analyzer'
require_relative 'lib/csv_writer'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

namespace :directory_classifier do
  desc 'Outputs directory classifications by contributors'
  task :contributors, [
    :project_directory,
    :directories_to_classify,
    :path_to_contributors_yaml_file,
    :output_filepath
  ] do |_task, args|
    contributors_lookup = ContributorsFileParser.new(args.fetch(:path_to_contributors_yaml_file)).parse

    CsvWriter.new(args.fetch(:output_filepath)) do |csv_writer|
      FileUtils.cd(args.fetch(:project_directory), verbose: true) do
        args.fetch(:directories_to_classify).split(';').each do |directory_to_classify|
          DirectoryContributionAnalyzer.new(
            contributors_lookup: contributors_lookup,
            path: directory_to_classify
          ).directory_contribution_set do |contribution_set|
            print '.'
            csv_writer.add_headers(contribution_set.csv_headers)
            csv_writer.add_row(contribution_set.as_csv_row)
          end
        end
      end
    end
  end
end
