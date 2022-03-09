# frozen_string_literal: true

require_relative 'categorisation'

class CategorisationBuilder
  class << self
    def categorisation_from(path:, file_content:, category:, keyword_regexp:)
      Categorisation.new(
        category: category,
        score: score(path, file_content, category, keyword_regexp)
      )
    end

    def score(path, file_content, category, keyword_regexp)
      score_for(relative(path), keyword_regexp) + score_for(file_content, keyword_regexp)
    end

    def relative(path)
      return path if Pathname.new(path).relative?

      Pathname.new(path).relative_path_from(current_directory).to_path
    end

    def current_directory
      Dir.pwd
    end

    def score_for(text, keyword_regexp)
      text.scan(keyword_regexp).join('-').length
    end
  end
end
