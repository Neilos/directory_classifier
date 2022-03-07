# frozen_string_literal: true

require_relative 'categorisation'

class CategorisationBuilder
  class << self
    def categorisation_from(file_content:, category:, keywords:)
      Categorisation.new(
        category: category,
        score: file_content.scan(Regexp.union(keywords)).join.length / category.length.to_f
      )
    end
  end
end
