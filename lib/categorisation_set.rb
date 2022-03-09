# frozen_string_literal: true

require_relative 'categorisation'
require_relative 'path_traversal'

class CategorisationSet
  include PathTraversal

  def initialize(path:, categories: [])
    @pathname = convert_to_relative_pathname(Pathname.new(path))

    ensure_real_path!

    @store = categories.each_with_object({}) do |category, categorisation_store|
      categorisation_store[category] = Categorisation.new(category: category, score: 0)
    end
  end

  def <<(categorisation)
    if store[categorisation.category]
      store[categorisation.category] += categorisation
    else
      store[categorisation.category] = categorisation
    end
  end

  def +(other)
    new_categorisation_set = self.class.new(path: path_shared_with(other))
    new_categorisation_set.store = store.merge(other.store) { |_key, v1, v2| v1 + v2 }
    new_categorisation_set
  end

  def categorisations
    store.values_at(*categories)
  end

  def categories
    store.keys.sort
  end

  def highest_scoring_categorisation
    categorisations.max
  end

  def primary_category
    highest_scoring_categorisation.category
  end

  def primary_category_score
    highest_scoring_categorisation.score
  end

  def sum_of_scores
    categorisations.sum(&:score)
  end

  def as_json
    {
      path: path,
      categorisations: store.transform_values(&:score),
      sum_of_scores: sum_of_scores,
      primary_category: primary_category,
      primary_category_score: primary_category_score
    }
  end

  def csv_headers
    ['path', 'sum_of_scores', 'primary_category_score', 'primary_category', *categories]
  end

  def as_csv_row
    [path, sum_of_scores, primary_category_score, primary_category, *scores]
  end

  attr_reader :store

  protected

  attr_writer :store

  def scores
    store.values_at(*categories).map(&:score)
  end
end
