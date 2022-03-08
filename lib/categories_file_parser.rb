# frozen_string_literal: true

require 'yaml'
require 'active_support'

class CategoriesFileParser
  include ActiveSupport::Inflector

  WORD_SEPARATOR = / |_/

  def initialize(filepath)
    @filepath = Pathname.new(filepath).realpath
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/BlockLength
  def parse
    categories.each_with_object({}) do |category, category_keywords|
      split_category = category.downcase.split(WORD_SEPARATOR)
      underscore_category = split_category.join('_')
      category_as_words = split_category.join(' ')

      keywords = [
        camelize(underscore_category),
        classify(underscore_category),
        deconstantize(underscore_category),
        demodulize(underscore_category),
        humanize(underscore_category),
        pluralize(underscore_category),
        singularize(underscore_category),
        tableize(underscore_category),
        titleize(underscore_category),
        underscore(underscore_category),
        upcase_first(underscore_category),
        underscore_category.upcase,

        camelize(category_as_words),
        classify(category_as_words),
        deconstantize(category_as_words),
        demodulize(category_as_words),
        humanize(category_as_words),
        pluralize(category_as_words),
        singularize(category_as_words),
        tableize(category_as_words),
        titleize(category_as_words),
        underscore(category_as_words),
        upcase_first(category_as_words),
        category_as_words.upcase
      ].uniq

      category_keywords[category] = Regexp.union(keywords.sort_by { |k| [k.length, k] }.reverse.reject(&:blank?))
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Metrics/BlockLength

  private

  attr_reader :filepath

  def categories
    File.read(filepath).split
  end
end
