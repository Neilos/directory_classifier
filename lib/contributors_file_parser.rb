# frozen_string_literal: true

require 'yaml'

class ContributorsFileParser
  def initialize(filepath)
    @filepath = Pathname.new(filepath).realpath
  end

  def parse
    YAML.load_file(filepath)
  end

  private

  attr_reader :filepath
end
