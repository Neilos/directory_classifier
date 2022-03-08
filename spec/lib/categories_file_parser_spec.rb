# frozen_string_literal: true

require 'spec_helper'
require 'categories_file_parser'

RSpec.describe CategoriesFileParser do
  let(:parser) { described_class.new(filepath_to_categories_yaml_file) }
  let(:filepath_to_categories_yaml_file) { 'spec/test_categories.yml' }

  describe '#parse' do
    subject(:parsed_yaml) { parser.parse }

    it 'returns categories hash' do
      expect(parsed_yaml).to eq(
        {
          'active_admin_comments' => Regexp.union(
            [
              'active_admin_comments',
              'active admin comments',
              'Active_admin_comments',
              'Active admin comments',
              'Active Admin Comments',
              'ACTIVE_ADMIN_COMMENTS',
              'ACTIVE ADMIN COMMENTS',
              'active_admin_comment',
              'active admin comment',
              'Active admin comment',
              'ActiveAdminComments',
              'ActiveAdminComment',
              'admin_comments',
              'admin comments',
              'Admin_comments',
              'Admin comments',
              'Admin Comments',
              'ADMIN_COMMENTS',
              'ADMIN COMMENTS',
              'admin_comment',
              'admin comment',
              'active_admins',
              'active admins',
              'AdminComments',
              'Admin comment',
              'active_admin',
              'active admin',
              'AdminComment',
              'Active_admin',
              'Active admin',
              'Active Admin',
              'ACTIVE_ADMIN',
              'ACTIVE ADMIN',
              'ActiveAdmin',
              'comments',
              'Comments',
              'COMMENTS',
              'comment',
              'actives',
              'Comment',
              'admins',
              'active',
              'Active',
              'ACTIVE',
              'admin',
              'Admin',
              'ADMIN'
            ]
          ),
          'bounced_emails' => Regexp.union(
            [
              'bounced_emails',
              'bounced emails',
              'Bounced_emails',
              'Bounced emails',
              'Bounced Emails',
              'BOUNCED_EMAILS',
              'BOUNCED EMAILS',
              'bounced_email',
              'bounced email',
              'BouncedEmails',
              'Bounced email',
              'BouncedEmail',
              'bounceds',
              'bounced',
              'Bounced',
              'BOUNCED',
              'emails',
              'Emails',
              'EMAILS',
              'email',
              'Email'
            ]
          ),
          'charges' => Regexp.union(
            %w[
              charges
              Charges
              CHARGES
              charge
              Charge
            ]
          )
        }
      )
    end
  end
end
