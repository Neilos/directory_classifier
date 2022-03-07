# frozen_string_literal: true

require 'spec_helper'
require 'contribution'
require 'contribution_set'

RSpec.describe ContributionSet do
  let(:contribution_set) { described_class.new(path: path, contributors: contributors_of_interest) }
  let(:path) { 'spec/test_directory' }
  let(:contributors_of_interest) do
    [
      'Wawel Dragons',
      'Tribe',
      'Pooh Bear',
      'Aliens',
      Contribution::UNKNOWN_CONTRIBUTOR
    ]
  end

  describe 'instantiation' do
    subject(:new_contribution_set) { contribution_set }

    context 'with a real relative path' do
      let(:path) { 'spec/test_directory' }

      it 'does not raise an error' do
        expect { new_contribution_set }.not_to raise_error
      end
    end

    context 'with a real absolute path' do
      let(:path) { Pathname.new('spec/test_directory').realdirpath.to_path }

      it 'does not raise an error' do
        expect { new_contribution_set }.not_to raise_error
      end
    end

    context 'with a fake path' do
      let(:path) { 'some/fake/path' }

      it 'raises a InvalidPathError' do
        expect { new_contribution_set }.to raise_error(described_class::InvalidPathError)
      end
    end

    context 'with contributors'
  end

  describe '#path' do
    it 'is same path regardless of whether set was instantiated with or without a "/" suffix' do
      expect(described_class.new(path: 'spec/test_directory').path).to eq(
        described_class.new(path: 'spec/test_directory/').path
      )
    end
  end

  describe '#contributions' do
    subject(:contributions) { contribution_set.contributions }

    it 'returns contributions for each of the contributors' do
      expect(contributions).to contain_exactly(
        an_object_having_attributes(contributor: 'Wawel Dragons', line_count: 0),
        an_object_having_attributes(contributor: 'Aliens', line_count: 0),
        an_object_having_attributes(contributor: 'Tribe', line_count: 0),
        an_object_having_attributes(contributor: 'Pooh Bear', line_count: 0),
        an_object_having_attributes(contributor: Contribution::UNKNOWN_CONTRIBUTOR, line_count: 0)
      )
    end
  end

  describe '#contributors' do
    subject(:contributors) { contribution_set.contributors }

    it 'returns contributors' do
      expect(contributors).to match_array(contributors_of_interest)
    end
  end

  describe 'largest_contribution' do
    subject(:largest_contribution) { contribution_set.largest_contribution }

    let(:contribution_1) { Contribution.new(contributor: 'Wawel Dragons', line_count: 5) }
    let(:contribution_2) { Contribution.new(contributor: 'Wawel Dragons', line_count: 7) }
    let(:contribution_3) { Contribution.new(contributor: 'Tribe', line_count: 6) }
    let(:contribution_4) { Contribution.new(contributor: 'Pooh Bear', line_count: 11) }

    before do
      contribution_set << contribution_1
      contribution_set << contribution_2
      contribution_set << contribution_3
      contribution_set << contribution_4
    end

    it 'is the contribution with the largest line_count' do
      expect(largest_contribution).to have_attributes(
        contributor: 'Wawel Dragons', line_count: 12
      )
    end
  end

  describe 'primary_contributor' do
    subject(:primary_contributor) { contribution_set.primary_contributor }

    let(:contribution_1) { Contribution.new(contributor: 'Wawel Dragons', line_count: 5) }
    let(:contribution_2) { Contribution.new(contributor: 'Wawel Dragons', line_count: 7) }
    let(:contribution_3) { Contribution.new(contributor: 'Tribe', line_count: 6) }
    let(:contribution_4) { Contribution.new(contributor: 'Pooh Bear', line_count: 11) }

    before do
      contribution_set << contribution_1
      contribution_set << contribution_2
      contribution_set << contribution_3
      contribution_set << contribution_4
    end

    it 'is the contributor of the largest_contribution' do
      expect(primary_contributor).to eq('Wawel Dragons')
    end
  end

  describe 'total_number_of_lines' do
    subject(:total_number_of_lines) { contribution_set.total_number_of_lines }

    let(:contribution_1) { Contribution.new(contributor: 'Wawel Dragons', line_count: 5) }
    let(:contribution_2) { Contribution.new(contributor: 'Wawel Dragons', line_count: 7) }
    let(:contribution_3) { Contribution.new(contributor: 'Tribe', line_count: 6) }
    let(:contribution_4) { Contribution.new(contributor: 'Pooh Bear', line_count: 11) }

    before do
      contribution_set << contribution_1
      contribution_set << contribution_2
      contribution_set << contribution_3
      contribution_set << contribution_4
    end

    it 'is the sum of the contribution line_counts' do
      expect(total_number_of_lines).to eq(
        contribution_1.line_count +
        contribution_2.line_count +
        contribution_3.line_count +
        contribution_4.line_count
      )
    end
  end

  describe '#<< (and #contributions)' do
    let(:contribution_1) { Contribution.new(contributor: 'Wawel Dragons', line_count: 5) }
    let(:contribution_2) { Contribution.new(contributor: 'Tribe', line_count: 7) }
    let(:contribution_3) { Contribution.new(contributor: contribution_4.contributor, line_count: 8) }
    let(:contribution_4) { Contribution.new(contributor: 'Pooh Bear', line_count: 3) }

    context 'when the contribution_set has no existing contributions' do
      it 'stores the given contribution' do
        contribution_set << contribution_4

        expect(contribution_set.contributions).to contain_exactly(
          an_object_having_attributes(contributor: 'Wawel Dragons', line_count: 0),
          an_object_having_attributes(contributor: 'Aliens', line_count: 0),
          an_object_having_attributes(contributor: 'Tribe', line_count: 0),
          an_object_having_attributes(contributor: 'Pooh Bear', line_count: contribution_4.line_count),
          an_object_having_attributes(contributor: Contribution::UNKNOWN_CONTRIBUTOR, line_count: 0)
        )
      end
    end

    context 'when the contribution_set already has a contribution for other contributors' do
      it 'stores the given contribution' do
        contribution_set << contribution_1
        contribution_set << contribution_2
        contribution_set << contribution_4

        expect(contribution_set.contributions).to contain_exactly(
          an_object_having_attributes(contributor: 'Wawel Dragons', line_count: contribution_1.line_count),
          an_object_having_attributes(contributor: 'Aliens', line_count: 0),
          an_object_having_attributes(contributor: 'Tribe', line_count: contribution_2.line_count),
          an_object_having_attributes(contributor: 'Pooh Bear', line_count: contribution_4.line_count),
          an_object_having_attributes(contributor: Contribution::UNKNOWN_CONTRIBUTOR, line_count: 0)
        )
      end
    end

    context 'when the contribution_set already has a contribution for the same contributor' do
      it 'stores the given contribution combining it with other contributions for the same contributor' do
        contribution_set << contribution_1
        contribution_set << contribution_2
        contribution_set << contribution_3
        contribution_set << contribution_4

        expect(contribution_set.contributions).to contain_exactly(
          an_object_having_attributes(contributor: 'Wawel Dragons', line_count: contribution_1.line_count),
          an_object_having_attributes(contributor: 'Aliens', line_count: 0),
          an_object_having_attributes(contributor: 'Tribe', line_count: contribution_2.line_count),
          an_object_having_attributes(
            contributor: 'Pooh Bear', line_count: contribution_3.line_count + contribution_4.line_count
          ),
          an_object_having_attributes(contributor: Contribution::UNKNOWN_CONTRIBUTOR, line_count: 0)
        )
      end
    end
  end

  describe '#+' do
    subject(:sum_of_sets) { contribution_set + other_contribution_set }

    let(:other_contribution_set) { described_class.new(path: other_set_path, contributors: contributors_of_interest) }

    let(:contribution_set_contribution_1) { Contribution.new(contributor: 'Wawel Dragons', line_count: 5) }
    let(:contribution_set_contribution_2) { Contribution.new(contributor: 'Tribe', line_count: 7) }
    let(:other_contribution_set_contribution_1) { Contribution.new(contributor: 'Pooh Bear', line_count: 4) }
    let(:other_contribution_set_contribution_2) { Contribution.new(contributor: 'Tribe', line_count: 2) }

    let(:expected_summed_contributions) do
      a_collection_containing_exactly(
        an_object_having_attributes(
          contributor: 'Wawel Dragons',
          line_count: contribution_set_contribution_1.line_count
        ),
        an_object_having_attributes(
          contributor: 'Pooh Bear',
          line_count: other_contribution_set_contribution_1.line_count
        ),
        an_object_having_attributes(
          contributor: 'Tribe',
          line_count: contribution_set_contribution_2.line_count +
                      other_contribution_set_contribution_2.line_count
        ),
        an_object_having_attributes(
          contributor: 'Aliens',
          line_count: 0
        ),
        an_object_having_attributes(
          contributor: Contribution::UNKNOWN_CONTRIBUTOR,
          line_count: 0
        )
      )
    end

    before do
      contribution_set << contribution_set_contribution_1
      contribution_set << contribution_set_contribution_2

      other_contribution_set << other_contribution_set_contribution_1
      other_contribution_set << other_contribution_set_contribution_2
    end

    context 'when given set has identical path' do
      let(:other_set_path) { contribution_set.path }

      it 'adds the set to the given set returning a new set' do
        expect(sum_of_sets).to have_attributes(
          path: contribution_set.path,
          contributions: expected_summed_contributions
        )
      end
    end

    context 'when given set has identical path but also a trailing "/"' do
      let(:other_set_path) { "#{contribution_set.path}/" }

      it 'adds the set to the given set returning a new set' do
        expect(sum_of_sets).to have_attributes(
          path: contribution_set.path,
          contributions: expected_summed_contributions
        )
      end
    end

    context 'when given set has path that is parent of path' do
      let(:other_set_path) { contribution_set.pathname.parent.to_s }

      it 'adds the set to the given set returning a new set ' \
         'with path matching the given set' do
        expect(sum_of_sets).to have_attributes(
          path: other_contribution_set.path,
          contributions: expected_summed_contributions
        )
      end
    end

    context 'when given set has path that is subdirectory of path' do
      let(:other_set_path) { File.join(contribution_set.pathname, 'test_file_1.txt') }

      it 'adds the set to the given set returning a new set with the same path' do
        expect(sum_of_sets).to have_attributes(
          path: contribution_set.path,
          contributions: expected_summed_contributions
        )
      end
    end

    context 'when given set is for a different path' do
      let(:other_set_path) { 'lib' }

      it 'adds the set to the given set returning a new set ' \
         'with path that is the longest path that is a parent of the paths of both sets' do
        expect(sum_of_sets).to have_attributes(
          path: '.',
          contributions: expected_summed_contributions
        )
      end
    end
  end

  describe '#as_json' do
    subject(:jsonable_hash) { contribution_set.as_json }

    let(:contribution_1) { Contribution.new(contributor: 'Wawel Dragons', line_count: 5) }
    let(:contribution_2) { Contribution.new(contributor: 'Wawel Dragons', line_count: 7) }
    let(:contribution_3) { Contribution.new(contributor: 'Tribe', line_count: 6) }
    let(:contribution_4) { Contribution.new(contributor: 'Pooh Bear', line_count: 11) }

    before do
      contribution_set << contribution_1
      contribution_set << contribution_2
      contribution_set << contribution_3
      contribution_set << contribution_4
    end

    it 'returns a jsonable representation of the set' do
      expect(jsonable_hash).to eq(
        {
          contributions: {
            'Wawel Dragons' => 12,
            'Tribe' => 6,
            'Pooh Bear' => 11,
            'Aliens' => 0,
            'UNKNOWN' => 0
          },
          primary_contributor: 'Wawel Dragons',
          total_number_of_lines: 29
        }
      )
    end
  end
end
