# frozen_string_literal: true

require 'spec_helper'
require 'categories_file_parser'

RSpec.describe CategoriesFileParser do
  let(:parser) { described_class.new(filepath_to_categories_yaml_file) }
  let(:filepath_to_categories_yaml_file) { 'spec/test_categories.yml' }

  describe '#parse' do
    subject(:parsed_yaml) { parser.parse }

    it 'returns categories lookup hash' do
      expect(parsed_yaml).to eq(
        {
          'active_admin_comments' => [
            'active admin comments',
            'active_admin_comments',
            'ACTIVE_ADMIN_COMMENTS',
            'ActiveAdminComments',
            'admin comments',
            'ADMIN_COMMENTS',
            'admin_comments',
            'AdminComments',
            'active_admin',
            'active admin',
            'ACTIVE_ADMIN',
            'ActiveAdmin',
            'comments',
            'Comments',
            'COMMENTS',
            'active',
            'Active',
            'ACTIVE',
            'admin',
            'Admin',
            'ADMIN'
          ],
          'bounced_emails' => [
            'bounced emails',
            'bounced_emails',
            'BOUNCED_EMAILS',
            'BouncedEmails',
            'bounced',
            'Bounced',
            'BOUNCED',
            'emails',
            'Emails',
            'EMAILS'
          ],
          'charges' => %w[
            charges
            Charges
            CHARGES
          ]
        }
      )
    end
  end
end
