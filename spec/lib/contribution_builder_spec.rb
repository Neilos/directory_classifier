# frozen_string_literal: true

require 'spec_helper'
require 'contribution'
require 'contribution_builder'

RSpec.describe ContributionBuilder do
  let(:contribution_builder) { described_class }

  describe '.from_git_blame_line' do
    subject(:new_contribution) do
      contribution_builder.from_git_blame_line(
        blame_line: blame_line,
        contributors_lookup: contributors_lookup
      )
    end

    let(:contributors_lookup) do
      {
        'Hugo Humpeter' => 'Tribe',
        'Jimbo Weasle' => 'Pooh Bear',
        'Tombo Bombo' => 'Wawel dragons'
      }
    end

    context 'when contributor is recognised in the contributors_lookup' do
      let(:blame_line) { '308f0de6 (Jimbo Weasle 2022-02-27 17:31:33 +0000 1) some file content' }

      it 'returns a new contribution with the correct contributor' do
        expect(new_contribution).to have_attributes(
          contributor: 'Pooh Bear',
          line_count: 1
        )
      end
    end

    context 'when contributor is NOT recognised in the contributors_lookup' do
      let(:blame_line) { '308f0de6 (Mikelos Munter 2022-02-27 17:31:33 +0000 1) some file content' }

      it 'returns a new contribution with an UNKNOWN contributor' do
        expect(new_contribution).to have_attributes(
          contributor: Contribution::UNKNOWN_CONTRIBUTOR,
          line_count: 1
        )
      end
    end
  end
end
