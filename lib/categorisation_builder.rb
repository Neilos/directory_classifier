# frozen_string_literal: true

require_relative 'categorisation'

class CategorisationBuilder
  class << self
    def categorisation_from(file_content:, category:, keyword_regexp:)
      Categorisation.new(
        category: category,
        score: file_content.scan(keyword_regexp).join('-').length
      )
    end
  end
end
