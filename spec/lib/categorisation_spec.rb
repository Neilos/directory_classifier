# frozen_string_literal: true

require 'spec_helper'
require 'categorisation'

RSpec.describe Categorisation do
  let(:categorisation) { described_class.new(category: category, score: score) }

  let(:category) { 'holdings' }
  let(:score) { 2 }

  describe 'instantiation' do
    subject(:new_object) { categorisation }

    context 'with a category' do
      it 'has the correct category' do
        expect(new_object.category).to eq(category)
      end
    end

    context 'without a category' do
      let(:categorisation) { described_class.new(score: score) }

      it 'has an UNKNOWN category' do
        expect(new_object.category).to eq(described_class::UNKNOWN_CATEGORY)
      end
    end
  end

  describe '<=>' do
    subject(:comparison) { categorisation <=> other_categorisation }

    context 'when other_categorisation has lower score' do
      let(:other_categorisation) do
        described_class.new(category: category, score: categorisation.score - 1)
      end

      it { is_expected.to eq(1) }
    end

    context 'when other_categorisation has higher score' do
      let(:other_categorisation) do
        described_class.new(category: category, score: categorisation.score + 1)
      end

      it { is_expected.to eq(-1) }
    end

    context 'when other_categorisation has the same score' do
      let(:other_categorisation) do
        described_class.new(category: category, score: categorisation.score)
      end

      it { is_expected.to eq(0) }
    end
  end

  describe '#+' do
    subject(:combined_categorisations) { categorisation + other_categorisation }

    let(:other_categorisation) do
      described_class.new(category: other_category, score: other_score)
    end

    let(:other_score) { 3 }
    let(:other_category) { categorisation.category }

    context 'when categories match' do
      it 'returns a categorisation with the score equal to the sum of the scores' do
        expect(combined_categorisations).to have_attributes(
          class: described_class,
          category: categorisation.category,
          score: categorisation.score + other_categorisation.score
        )
      end
    end

    context 'when categories do not match' do
      let(:other_category) { 'portfolios' }

      it 'raises a CategoryMismatchError' do
        expect { combined_categorisations }.to raise_error(described_class::CategoryMismatchError)
      end
    end
  end
end
