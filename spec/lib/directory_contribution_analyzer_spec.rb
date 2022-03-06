# frozen_string_literal: true

require 'spec_helper'
require 'directory_contribution_analyzer'

RSpec.describe DirectoryContributionAnalyzer do
  let(:directory_contribution_analyzer) do
    described_class.new(contributors_lookup: contributors_lookup, path: path)
  end

  let(:contributors_lookup) do
    {
      'Dennis' => 'Tribe',
      'Neilos' => 'Pooh Bear',
      'Tom' => 'Wawel dragons',
      'Hilda' => 'Pooh Bear'
    }
  end

  describe '#directory_contribution_set' do
    subject(:directory_contribution_set) { directory_contribution_analyzer.directory_contribution_set }

    context 'when path is a directory' do
      context 'when directory is empty' do
        let(:path) { 'spec/test_directory/empty_directory/' }

        it 'returns contributor contributions for the directory' do
          expect(directory_contribution_set).to have_attributes(
            contributions: contain_exactly(
              an_object_having_attributes(contributor: 'Tribe', line_count: 0),
              an_object_having_attributes(contributor: 'Pooh Bear', line_count: 0),
              an_object_having_attributes(contributor: 'Wawel dragons', line_count: 0),
              an_object_having_attributes(contributor: 'UNKNOWN', line_count: 0)
            )
          )
        end
      end

      context 'when directory is NOT empty' do
        let(:path) { 'spec/test_directory/' }

        it 'returns contributor contributions for the directory' do
          expect(directory_contribution_set).to have_attributes(
            contributions: contain_exactly(
              an_object_having_attributes(contributor: 'Tribe', line_count: 0),
              an_object_having_attributes(contributor: 'Pooh Bear', line_count: 7),
              an_object_having_attributes(contributor: 'Wawel dragons', line_count: 0),
              an_object_having_attributes(contributor: 'UNKNOWN', line_count: 0)
            )
          )
        end
      end
    end

    context 'when when is a file' do
      context 'when file is empty' do
        let(:path) { 'spec/test_directory/empty_file.txt' }

        it 'returns contributor contributions for the file itself' do
          expect(directory_contribution_set).to have_attributes(
            contributions: contain_exactly(
              an_object_having_attributes(contributor: 'Tribe', line_count: 0),
              an_object_having_attributes(contributor: 'Pooh Bear', line_count: 0),
              an_object_having_attributes(contributor: 'Wawel dragons', line_count: 0),
              an_object_having_attributes(contributor: 'UNKNOWN', line_count: 0)
            )
          )
        end
      end

      context 'when file is NOT empty' do
        let(:path) { 'spec/test_directory/test_file_2.txt' }

        it 'returns contributor contributions for the file itself' do
          expect(directory_contribution_set).to have_attributes(
            contributions: contain_exactly(
              an_object_having_attributes(contributor: 'Tribe', line_count: 0),
              an_object_having_attributes(contributor: 'Pooh Bear', line_count: 4),
              an_object_having_attributes(contributor: 'Wawel dragons', line_count: 0),
              an_object_having_attributes(contributor: 'UNKNOWN', line_count: 0)
            )
          )
        end
      end
    end
  end
end
