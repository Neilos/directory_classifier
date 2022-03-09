# frozen_string_literal: true

require 'spec_helper'
require 'categorisation'
require 'categorisation_set'

RSpec.describe CategorisationSet do
  let(:categorisation_set) { described_class.new(path: path, categories: categories_of_interest) }
  let(:path) { 'spec/test_directory' }
  let(:categories_of_interest) do
    [
      'glidepaths',
      'portfolios',
      'investments',
      'funds',
      Categorisation::UNKNOWN_CATEGORY
    ]
  end

  describe 'instantiation' do
    subject(:new_categorisation_set) { categorisation_set }

    context 'with a real relative path' do
      let(:path) { 'spec/test_directory' }

      it 'does not raise an error' do
        expect { new_categorisation_set }.not_to raise_error
      end
    end

    context 'with a real absolute path' do
      let(:path) { Pathname.new('spec/test_directory').realdirpath.to_path }

      it 'does not raise an error' do
        expect { new_categorisation_set }.not_to raise_error
      end
    end

    context 'with a fake path' do
      let(:path) { 'some/fake/path' }

      it 'raises a InvalidPathError' do
        expect { new_categorisation_set }.to raise_error(described_class::InvalidPathError)
      end
    end

    context 'with categories'
  end

  describe '#path' do
    it 'is same path regardless of whether set was instantiated with or without a "/" suffix' do
      expect(described_class.new(path: 'spec/test_directory').path).to eq(
        described_class.new(path: 'spec/test_directory/').path
      )
    end
  end

  describe '#categorisations' do
    subject(:categorisations) { categorisation_set.categorisations }

    it 'returns categorisations for each of the categories' do
      expect(categorisations).to contain_exactly(
        an_object_having_attributes(category: 'glidepaths', score: 0),
        an_object_having_attributes(category: 'funds', score: 0),
        an_object_having_attributes(category: 'portfolios', score: 0),
        an_object_having_attributes(category: 'investments', score: 0),
        an_object_having_attributes(category: Categorisation::UNKNOWN_CATEGORY, score: 0)
      )
    end
  end

  describe '#categories' do
    subject(:categories) { categorisation_set.categories }

    it 'returns categories' do
      expect(categories).to match_array(categories_of_interest)
    end
  end

  describe 'primary_category' do
    subject(:primary_category) { categorisation_set.primary_category }

    let(:categorisation_1) { Categorisation.new(category: 'glidepaths', score: 5) }
    let(:categorisation_2) { Categorisation.new(category: 'glidepaths', score: 7) }
    let(:categorisation_3) { Categorisation.new(category: 'portfolios', score: 6) }
    let(:categorisation_4) { Categorisation.new(category: 'investments', score: 11) }
    let(:categorisation_5) { Categorisation.new(category: Categorisation::UNKNOWN_CATEGORY, score: 8) }

    before do
      categorisation_set << categorisation_1
      categorisation_set << categorisation_2
      categorisation_set << categorisation_3
      categorisation_set << categorisation_4
      categorisation_set << categorisation_5
    end

    it 'is the category of the largest_categorisation' do
      expect(primary_category).to eq('glidepaths')
    end
  end

  describe '#<< (and #categorisations)' do
    let(:categorisation_1) { Categorisation.new(category: 'glidepaths', score: 5) }
    let(:categorisation_2) { Categorisation.new(category: 'portfolios', score: 7) }
    let(:categorisation_3) { Categorisation.new(category: categorisation_4.category, score: 8) }
    let(:categorisation_4) { Categorisation.new(category: 'investments', score: 3) }

    context 'when the categorisation_set has no existing categorisations' do
      it 'stores the given categorisation' do
        categorisation_set << categorisation_4

        expect(categorisation_set.categorisations).to contain_exactly(
          an_object_having_attributes(category: 'glidepaths', score: 0),
          an_object_having_attributes(category: 'funds', score: 0),
          an_object_having_attributes(category: 'portfolios', score: 0),
          an_object_having_attributes(category: 'investments', score: categorisation_4.score),
          an_object_having_attributes(category: Categorisation::UNKNOWN_CATEGORY, score: 0)
        )
      end
    end

    context 'when the categorisation_set already has a categorisation for other categories' do
      it 'stores the given categorisation' do
        categorisation_set << categorisation_1
        categorisation_set << categorisation_2
        categorisation_set << categorisation_4

        expect(categorisation_set.categorisations).to contain_exactly(
          an_object_having_attributes(category: 'glidepaths', score: categorisation_1.score),
          an_object_having_attributes(category: 'funds', score: 0),
          an_object_having_attributes(category: 'portfolios', score: categorisation_2.score),
          an_object_having_attributes(category: 'investments', score: categorisation_4.score),
          an_object_having_attributes(category: Categorisation::UNKNOWN_CATEGORY, score: 0)
        )
      end
    end

    context 'when the categorisation_set already has a categorisation for the same category' do
      it 'stores the given categorisation combining it with other categorisations for the same category' do
        categorisation_set << categorisation_1
        categorisation_set << categorisation_2
        categorisation_set << categorisation_3
        categorisation_set << categorisation_4

        expect(categorisation_set.categorisations).to contain_exactly(
          an_object_having_attributes(category: 'glidepaths', score: categorisation_1.score),
          an_object_having_attributes(category: 'funds', score: 0),
          an_object_having_attributes(category: 'portfolios', score: categorisation_2.score),
          an_object_having_attributes(
            category: 'investments', score: categorisation_3.score + categorisation_4.score
          ),
          an_object_having_attributes(category: Categorisation::UNKNOWN_CATEGORY, score: 0)
        )
      end
    end
  end

  describe '#+' do
    subject(:combined_sets) { categorisation_set + other_categorisation_set }

    let(:other_categorisation_set) { described_class.new(path: other_set_path, categories: categories_of_interest) }

    let(:categorisation_set_categorisation_1) { Categorisation.new(category: 'glidepaths', score: 5) }
    let(:categorisation_set_categorisation_2) { Categorisation.new(category: 'portfolios', score: 7) }
    let(:other_categorisation_set_categorisation_1) { Categorisation.new(category: 'investments', score: 4) }
    let(:other_categorisation_set_categorisation_2) { Categorisation.new(category: 'portfolios', score: 2) }

    let(:expected_summed_categorisations) do
      a_collection_containing_exactly(
        an_object_having_attributes(
          category: 'glidepaths',
          score: categorisation_set_categorisation_1.score
        ),
        an_object_having_attributes(
          category: 'investments',
          score: other_categorisation_set_categorisation_1.score
        ),
        an_object_having_attributes(
          category: 'portfolios',
          score: categorisation_set_categorisation_2.score +
                      other_categorisation_set_categorisation_2.score
        ),
        an_object_having_attributes(
          category: 'funds',
          score: 0
        ),
        an_object_having_attributes(
          category: Categorisation::UNKNOWN_CATEGORY,
          score: 0
        )
      )
    end

    before do
      categorisation_set << categorisation_set_categorisation_1
      categorisation_set << categorisation_set_categorisation_2

      other_categorisation_set << other_categorisation_set_categorisation_1
      other_categorisation_set << other_categorisation_set_categorisation_2
    end

    context 'when given set has identical path' do
      let(:other_set_path) { categorisation_set.path }

      it 'adds the set to the given set returning a new set' do
        expect(combined_sets).to have_attributes(
          path: categorisation_set.path,
          categorisations: expected_summed_categorisations
        )
      end
    end

    context 'when given set has identical path but also a trailing "/"' do
      let(:other_set_path) { "#{categorisation_set.path}/" }

      it 'adds the set to the given set returning a new set' do
        expect(combined_sets).to have_attributes(
          path: categorisation_set.path,
          categorisations: expected_summed_categorisations
        )
      end
    end

    context 'when given set has path that is parent of path' do
      let(:other_set_path) { categorisation_set.pathname.parent.to_s }

      it 'adds the set to the given set returning a new set ' \
         'with path matching the given set' do
        expect(combined_sets).to have_attributes(
          path: other_categorisation_set.path,
          categorisations: expected_summed_categorisations
        )
      end
    end

    context 'when given set has path that is subdirectory of path' do
      let(:other_set_path) { File.join(categorisation_set.pathname, 'test_file_1.txt') }

      it 'adds the set to the given set returning a new set with the same path' do
        expect(combined_sets).to have_attributes(
          path: categorisation_set.path,
          categorisations: expected_summed_categorisations
        )
      end
    end

    context 'when given set is for a different path' do
      let(:other_set_path) { 'lib' }

      it 'adds the set to the given set returning a new set ' \
         'with path that is the longest path that is a parent of the paths of both sets' do
        expect(combined_sets).to have_attributes(
          path: '.',
          categorisations: expected_summed_categorisations
        )
      end
    end
  end

  describe '#as_json' do
    subject(:jsonable_hash) { categorisation_set.as_json }

    let(:categorisation_1) { Categorisation.new(category: 'glidepaths', score: 5) }
    let(:categorisation_2) { Categorisation.new(category: 'glidepaths', score: 7) }
    let(:categorisation_3) { Categorisation.new(category: 'portfolios', score: 6) }
    let(:categorisation_4) { Categorisation.new(category: 'investments', score: 11) }

    before do
      categorisation_set << categorisation_1
      categorisation_set << categorisation_2
      categorisation_set << categorisation_3
      categorisation_set << categorisation_4
    end

    it 'returns a jsonable representation of the set' do
      expect(jsonable_hash).to eq(
        {
          path: path,
          categorisations: {
            'glidepaths' => 12,
            'portfolios' => 6,
            'investments' => 11,
            'funds' => 0,
            'UNKNOWN' => 0
          },
          sum_of_scores: 29,
          primary_category: 'glidepaths',
          primary_category_score: 12
        }
      )
    end
  end

  describe 'csv_headers' do
    subject(:csv_headers) { categorisation_set.csv_headers }

    specify do
      expect(csv_headers).to eq(
        [
          'path',
          'sum_of_scores',
          'primary_category_score',
          'primary_category',
          *categories_of_interest.sort
        ]
      )
    end
  end

  describe 'as_csv_row' do
    subject(:csv_row) { categorisation_set.as_csv_row }

    let(:categorisation_1) { Categorisation.new(category: 'glidepaths', score: 5) }
    let(:categorisation_2) { Categorisation.new(category: 'glidepaths', score: 7) }
    let(:categorisation_3) { Categorisation.new(category: 'portfolios', score: 6) }
    let(:categorisation_4) { Categorisation.new(category: 'investments', score: 11) }

    before do
      categorisation_set << categorisation_1
      categorisation_set << categorisation_2
      categorisation_set << categorisation_3
      categorisation_set << categorisation_4
    end

    specify do
      expect(csv_row).to eq(
        [path, 29, 12,'glidepaths', 0, 0, 12, 11, 6]
      )
    end
  end
end
