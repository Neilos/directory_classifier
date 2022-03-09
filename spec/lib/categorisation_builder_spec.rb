# frozen_string_literal: true

require 'spec_helper'
require 'categorisation'
require 'categorisation_builder'

RSpec.describe CategorisationBuilder do
  let(:categorisation_builder) { described_class }

  describe '.categorisation_from' do
    subject(:new_categorisation) do
      categorisation_builder.categorisation_from(
        path: path,
        file_content: file_content,
        category: category,
        keyword_regexp: keyword_regexp
      )
    end

    let(:category) { 'a_category' }
    let(:keyword_regexp) { Regexp.union(%w[some_category SomeCategory some category]) }

    context 'when path does not contain match' do
      let(:path) { 'a/path/that/does_not_match' }

      context 'when text contains no match' do
        let(:file_content) do
          <<~TEXT
            This text is irrelevant.
          TEXT
        end

        it 'returns a categorisation with a score matching the keyword count' do
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

        it 'returns a categorisation with a score matching the keyword count' do
          expect(new_categorisation).to have_attributes(
            category: category,
            score: 54
          )
        end
      end

      context 'when path contains a match' do
        let(:path) { 'a/path/that/some_category/matches' }

        context 'when text contains no match' do
          let(:file_content) do
            <<~TEXT
              This text is irrelevant.
            TEXT
          end

          it 'returns a categorisation with a score matching the keyword count' do
            expect(new_categorisation).to have_attributes(
              category: category,
              score: 13
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

          it 'returns a categorisation with a score matching the keyword count' do
            expect(new_categorisation).to have_attributes(
              category: category,
              score: 67
            )
          end
        end

        context 'when path is absolute and absolute part contains a match' do
          let(:keyword_regexp) { Regexp.union(%w[directory|classifier]) }
          let(:path) { Dir.pwd }
          let(:file_content) do
            <<~TEXT
              This text is irrelevant.
            TEXT
          end

          it 'does not score the absolute part' do
            expect(new_categorisation).to have_attributes(
              category: category,
              score: 0
            )
          end
        end
      end
    end
  end
end
