# frozen_string_literal: true

require 'spec_helper'
require 'categorisation'
require 'categorisation_builder'

RSpec.describe CategorisationBuilder do
  let(:categorisation_builder) { described_class }

  describe '.categorisation_from' do
    subject(:new_categorisation) do
      categorisation_builder.categorisation_from(
        file_content: file_content,
        category: category,
        keywords: keywords
      )
    end

    let(:category) { 'a_category' }
    let(:keywords) { %w[some_category SomeCategory some category] }

    context 'when text contains no match' do
      let(:file_content) do
        <<~TEXT
          This text is irrelevant.
        TEXT
      end

      it 'returns a categorisation with a score matching the keyword count divided by the category character count' do
        expect(new_categorisation).to have_attributes(
          category: category,
          score: 0
        )
      end
    end

    context 'when text contains a match' do
      let(:file_content) do
        <<~TEXT
          SomeCategory is a keyword.
          It is a keyword for the category a_category; otherwise known as some_category.
          some categories are sometime left
        TEXT
      end

      it 'returns a categorisation with a score matching the keyword count divided by the category character count' do
        expect(new_categorisation).to have_attributes(
          category: category,
          score: 4.9
        )
      end
    end
  end
end
