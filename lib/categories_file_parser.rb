# frozen_string_literal: true

require 'yaml'

class CategoriesFileParser
  WORD_SEPARATOR = / |_/

  def initialize(filepath)
    @filepath = Pathname.new(filepath).realpath
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def parse
    categories.each_with_object({}) do |category, category_keywords|
      raw_keywords = category.split(WORD_SEPARATOR)
      raw_keyword_count = raw_keywords.count

      keywords = (1..raw_keyword_count).flat_map do |keyword_word_count|
        raw_keywords.each_cons(keyword_word_count).flat_map do |keyword_combination|
          [
            keyword_combination.map(&:upcase).join('_'),
            keyword_combination.map(&:capitalize).join,
            keyword_combination.join('_'),
            keyword_combination.join(' ')
          ].uniq
        end
      end

      category_keywords[category] = [
        *keywords
      ].sort_by(&:length).reverse
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  private

  attr_reader :filepath

  def categories
    File.read(filepath).split
  end
end
