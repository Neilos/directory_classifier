# frozen_string_literal: true

require_relative 'categorisation'

class CategorisationBuilder
  class << self
    def categorisation_from(path:, file_content:, category:, keyword_regexp:)
      Categorisation.new(
        category: category,
        score: score_for(path, keyword_regexp) + score_for(file_content, keyword_regexp)
      )
    end

    def score_for(text, keyword_regexp)
      text.scan(keyword_regexp).join('-').length
    end
  end
end
