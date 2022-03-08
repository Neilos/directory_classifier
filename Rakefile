# frozen_string_literal: true

require 'rspec/core/rake_task'
require 'pry'
require_relative 'lib/contributors_file_parser'
require_relative 'lib/categories_file_parser'
require_relative 'lib/directory_contribution_analyzer'
require_relative 'lib/directory_categorisation_analyzer'
require_relative 'lib/csv_writer'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

SUBDIRECTORY_OF_OR_FILE_IN_UNITS = %r{^.+/units/[\w/]+}

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
            path = category_set.path

            if !path.match?(SUBDIRECTORY_OF_OR_FILE_IN_UNITS) || Dir.exist?(path)
              csv_writer.add_headers(contribution_set.csv_headers)
              csv_writer.add_row(contribution_set.as_csv_row)
            end

            print '.'
          end
        end
      end
    end
  end

  desc 'Outputs directory classifications by categories'
  task :categories, [
    :project_directory,
    :directories_to_classify,
    :path_to_categories_yaml_file,
    :output_filepath
  ] do |_task, args|
    category_keywords = CategoriesFileParser.new(args.fetch(:path_to_categories_yaml_file)).parse

    CsvWriter.new(args.fetch(:output_filepath)) do |csv_writer|
      FileUtils.cd(args.fetch(:project_directory), verbose: true) do
        args.fetch(:directories_to_classify).split(';').each do |directory_to_classify|
          DirectoryCategorisationAnalyzer.new(
            category_keywords: category_keywords,
            path: directory_to_classify
          ).directory_categorisation_set do |category_set|
            path = category_set.path

            if !path.match?(SUBDIRECTORY_OF_OR_FILE_IN_UNITS) || Dir.exist?(path)
              csv_writer.add_headers(category_set.csv_headers)
              csv_writer.add_row(category_set.as_csv_row)
            end

            print '.'
          end
        end
      end
    end
  end
end
