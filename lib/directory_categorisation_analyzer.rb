# frozen_string_literal: true

require_relative 'categorisation'
require_relative 'categorisation_builder'
require_relative 'categorisation_set'

class DirectoryCategorisationAnalyzer
  def initialize(category_keywords:, path:)
    @category_keywords = category_keywords
    @path = path
  end

  def directory_categorisation_set(&block)
    categorisation_set_for_this_directory = block ? categorisation_set(&block) : categorisation_set

    block.call(categorisation_set_for_this_directory) if path_is_directory? && block

    categorisation_set_for_this_directory
  end

  private

  attr_reader :category_keywords, :path

  def categorisation_set(&block)
    return file_categorisation_set unless path_is_directory?
    return empty_categorisation_set if directory_is_empty?

    empty_categorisation_set + subdirectory_categorisation_sets(&block).reduce(&:+)
  end

  def subdirectory_categorisation_sets(&block)
    Dir.each_child(path).map do |child_path|
      self.class.new(
        category_keywords: category_keywords,
        path: File.join(path, child_path)
      ).directory_categorisation_set(&block)
    end
  end

  def file_categorisation_set
    category_keywords.each_with_object(empty_categorisation_set) do |(category, keywords), file_categorisations|
      file_categorisations << CategorisationBuilder.categorisation_from(
        file_content: file_content,
        category: category,
        keywords: keywords
      )
    end
  end

  def file_content
    @file_content ||= File.read(path)
  end

  def path_is_directory?
    Dir.exist?(path)
  end

  def directory_is_empty?
    Dir.empty?(path)
  end

  def empty_categorisation_set
    CategorisationSet.new(path: path, categories: categories)
  end

  def categories
    category_keywords.keys.uniq.push(Categorisation::UNKNOWN_CATEGORY)
  end
end