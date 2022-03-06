# frozen_string_literal: true

require 'spec_helper'
require 'contribution'

RSpec.describe Contribution do
  let(:contribution) { described_class.new(contributor: contributor, line_count: line_count) }

  let(:contributor) { 'Mr developer' }
  let(:line_count) { 2 }

  describe 'instantiation' do
    subject(:new_object) { contribution }

    context 'with a contributor' do
      it 'has the correct contributor' do
        expect(new_object.contributor).to eq(contributor)
      end
    end

    context 'without a contributor' do
      let(:contribution) { described_class.new(line_count: line_count) }

      it 'has an UNKNOWN contributor' do
        expect(new_object.contributor).to eq(described_class::UNKNOWN_CONTRIBUTOR)
      end
    end
  end

  describe '<=>' do
    subject(:comparison) { contribution <=> other_contribution }

    context 'when other_contribution has lower line count' do
      let(:other_contribution) do
        described_class.new(contributor: contributor, line_count: contribution.line_count - 1)
      end

      it { is_expected.to eq(1) }
    end

    context 'when other_contribution has higher line count' do
      let(:other_contribution) do
        described_class.new(contributor: contributor, line_count: contribution.line_count + 1)
      end

      it { is_expected.to eq(-1) }
    end

    context 'when other_contribution has the same line count' do
      let(:other_contribution) do
        described_class.new(contributor: contributor, line_count: contribution.line_count)
      end

      it { is_expected.to eq(0) }
    end
  end

  describe '#+' do
    subject(:sum_of_contributions) { contribution + other_contribution }

    let(:other_contribution) do
      described_class.new(contributor: other_contributor, line_count: other_line_count)
    end

    let(:other_line_count) { 3 }
    let(:other_contributor) { contribution.contributor }

    context 'when contributors match' do
      it 'returns a contribution with the line_count equal to the sum of the line_counts' do
        expect(sum_of_contributions).to have_attributes(
          class: described_class,
          contributor: contribution.contributor,
          line_count: contribution.line_count + other_contribution.line_count
        )
      end
    end

    context 'when contributors do not match' do
      let(:other_contributor) { 'Mr Stranger' }

      it 'raises a ContributorMismatchError' do
        expect { sum_of_contributions }.to raise_error(described_class::ContributorMismatchError)
      end
    end
  end
end
