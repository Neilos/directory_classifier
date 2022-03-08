# frozen_string_literal: true

require 'spec_helper'
require 'directory_categorisation_analyzer'

RSpec.describe DirectoryCategorisationAnalyzer do
  let(:directory_categorisation_analyzer) do
    described_class.new(category_keywords: category_keywords, path: path)
  end

  let(:category_keywords) do
    {
      'file' => Regexp.union(['some file content', 'content', 'Some', 'some', 'file']),
      'line' => Regexp.union(%w[Line line])
    }
  end

  describe '#directory_categorisation_set' do
    subject(:directory_categorisation_set) { directory_categorisation_analyzer.directory_categorisation_set }

    context 'when path is a directory' do
      context 'when directory is empty' do
        let(:path) { 'spec/test_directory/empty_directory/' }

        it 'returns category categorisations for the directory' do
          expect(directory_categorisation_set).to have_attributes(
            path: 'spec/test_directory/empty_directory',
            categorisations: contain_exactly(
              an_object_having_attributes(category: 'file', score: 0),
              an_object_having_attributes(category: 'line', score: 0),
              an_object_having_attributes(category: 'UNKNOWN', score: 0)
            )
          )
        end
      end

      context 'when directory is NOT empty' do
        context 'with only 1 file in the directory' do
          let(:path) { 'spec/test_directory_with_one_file/' }

          it 'returns category categorisations for the directory' do
            expect(directory_categorisation_set).to have_attributes(
              path: 'spec/test_directory_with_one_file',
              categorisations: contain_exactly(
                an_object_having_attributes(category: 'file', score: 35),
                an_object_having_attributes(category: 'line', score: 14),
                an_object_having_attributes(category: 'UNKNOWN', score: 0)
              )
            )
          end

          context 'when a block is given' do
            it 'yields each directory and sub-directory to the block' do
              expect do |blk|
                directory_categorisation_analyzer.directory_categorisation_set(&blk)
              end.to yield_successive_args(
                an_object_having_attributes(
                  path: 'spec/test_directory_with_one_file/test_file_3.txt',
                  categorisations: contain_exactly(
                    an_object_having_attributes(category: 'file', score: 35),
                    an_object_having_attributes(category: 'line', score: 14),
                    an_object_having_attributes(category: 'UNKNOWN', score: 0)
                  )
                ),
                an_object_having_attributes(
                  path: 'spec/test_directory_with_one_file',
                  categorisations: contain_exactly(
                    an_object_having_attributes(category: 'file', score: 35),
                    an_object_having_attributes(category: 'line', score: 14),
                    an_object_having_attributes(category: 'UNKNOWN', score: 0)
                  )
                )
              )
            end
          end
        end

        context 'with multiple files and sub-directories' do
          let(:path) { 'spec/test_directory/' }

          it 'returns category categorisations for the directory' do
            expect(directory_categorisation_set).to have_attributes(
              path: 'spec/test_directory',
              categorisations: contain_exactly(
                an_object_having_attributes(category: 'file', score: 57),
                an_object_having_attributes(category: 'line', score: 23),
                an_object_having_attributes(category: 'UNKNOWN', score: 0)
              )
            )
          end

          context 'when a block is given' do
            it 'yields each file, directory and sub-directory (except hidden ones) to the block' do
              expect do |blk|
                directory_categorisation_analyzer.directory_categorisation_set(&blk)
              end.to yield_successive_args(
                an_object_having_attributes(
                  path: 'spec/test_directory/test_file_1.txt',
                  categorisations: contain_exactly(
                    an_object_having_attributes(category: 'file', score: 22),
                    an_object_having_attributes(category: 'line', score: 9),
                    an_object_having_attributes(category: 'UNKNOWN', score: 0)
                  )
                ),
                an_object_having_attributes(
                  path: 'spec/test_directory/test_file_2.txt',
                  categorisations: contain_exactly(
                    an_object_having_attributes(category: 'file', score: 35),
                    an_object_having_attributes(category: 'line', score: 14),
                    an_object_having_attributes(category: 'UNKNOWN', score: 0)
                  )
                ),
                an_object_having_attributes(
                  path: 'spec/test_directory/empty_file.txt',
                  categorisations: contain_exactly(
                    an_object_having_attributes(category: 'file', score: 0),
                    an_object_having_attributes(category: 'line', score: 0),
                    an_object_having_attributes(category: 'UNKNOWN', score: 0)
                  )
                ),
                an_object_having_attributes(
                  path: 'spec/test_directory/empty_directory',
                  categorisations: contain_exactly(
                    an_object_having_attributes(category: 'file', score: 0),
                    an_object_having_attributes(category: 'line', score: 0),
                    an_object_having_attributes(category: 'UNKNOWN', score: 0)
                  )
                ),
                an_object_having_attributes(
                  path: 'spec/test_directory',
                  categorisations: contain_exactly(
                    an_object_having_attributes(category: 'file', score: 57),
                    an_object_having_attributes(category: 'line', score: 23),
                    an_object_having_attributes(category: 'UNKNOWN', score: 0)
                  )
                )
              )
            end
          end
        end
      end
    end

    context 'when path is a file' do
      context 'when file is empty' do
        let(:path) { 'spec/test_directory/empty_file.txt' }

        it 'returns category categorisations for the file itself' do
          expect(directory_categorisation_set).to have_attributes(
            path: 'spec/test_directory/empty_file.txt',
            categorisations: contain_exactly(
              an_object_having_attributes(category: 'file', score: 0),
              an_object_having_attributes(category: 'line', score: 0),
              an_object_having_attributes(category: 'UNKNOWN', score: 0)
            )
          )
        end
      end

      context 'when file is NOT empty' do
        let(:path) { 'spec/test_directory/test_file_2.txt' }

        it 'returns category categorisations for the file itself' do
          expect(directory_categorisation_set).to have_attributes(
            path: 'spec/test_directory/test_file_2.txt',
            categorisations: contain_exactly(
              an_object_having_attributes(category: 'file', score: 35),
              an_object_having_attributes(category: 'line', score: 14),
              an_object_having_attributes(category: 'UNKNOWN', score: 0)
            )
          )
        end
      end
    end
  end
end
