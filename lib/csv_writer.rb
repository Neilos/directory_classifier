require 'csv'

class CsvWriter

  def initialize(output_path)
    @output_path = output_path
    FileUtils.touch(output_path)
    @headers = []

    yield self
  end

  attr_reader :output_path, :headers

  def add_headers(headers)
    self.headers = headers

    CSV.open(output_path, 'wb') do |csv|
      csv << headers
    end
  end

  def add_row(row_content)
    CSV.open(output_path, 'ab') do |csv|
      csv << row_content
    end
  end

  private

  attr_writer :headers

end
