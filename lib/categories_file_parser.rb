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
      raw_keywords = category.downcase.split(WORD_SEPARATOR)
      raw_keyword_count = raw_keywords.count

      keywords = (1..raw_keyword_count).flat_map do |keyword_word_count|
        raw_keywords.each_cons(keyword_word_count).flat_map do |separated_keyword_part|
          keyword_part = separated_keyword_part.join('_')
          spaced_keyword_part = separated_keyword_part.join(' ')

          [
            camelize(keyword_part),
            classify(keyword_part),
            deconstantize(keyword_part),
            demodulize(keyword_part),
            humanize(keyword_part),
            pluralize(keyword_part),
            singularize(keyword_part),
            tableize(keyword_part),
            titleize(keyword_part),
            underscore(keyword_part),
            upcase_first(keyword_part),
            keyword_part.upcase,

            camelize(spaced_keyword_part),
            classify(spaced_keyword_part),
            deconstantize(spaced_keyword_part),
            demodulize(spaced_keyword_part),
            humanize(spaced_keyword_part),
            pluralize(spaced_keyword_part),
            singularize(spaced_keyword_part),
            tableize(spaced_keyword_part),
            titleize(spaced_keyword_part),
            underscore(spaced_keyword_part),
            upcase_first(spaced_keyword_part),
            spaced_keyword_part.upcase
          ].uniq
        end
      end

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
