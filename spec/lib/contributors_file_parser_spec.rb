# frozen_string_literal: true

require 'spec_helper'
require 'contributors_file_parser'

RSpec.describe ContributorsFileParser do
  let(:parser) { described_class.new(filepath_to_contributors_yaml_file) }
  let(:filepath_to_contributors_yaml_file) { './example_contributors.yml' }

  describe '#parse' do
    subject(:parsed_yaml) { parser.parse }

    it 'returns contributors lookup hash' do
      expect(parsed_yaml).to eq(
        {
          'Dennis' => 'Tribe',
          'Neilos' => 'Pooh Bear',
          'Tom Bombadil' => 'Wawel dragons',
          'Monkey Man' => 'Pooh Bear',
          'Hilda' => 'Pooh Bear'
        }
      )
    end
  end
end
