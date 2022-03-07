# frozen_string_literal: true

module PathTraversal
  PathMismatchError = Class.new(StandardError)
  InvalidPathError = Class.new(StandardError)

  def path
    pathname.to_path
  end

  def path_segments
    path.split('/')
  end

  def path_length
    path_segments.count
  end

  attr_reader :pathname

  protected

  attr_writer :pathname

  private

  def path_shared_with(other_set)
    return path if pathname == other_set.pathname

    common_base_path(other_set)
  end

  def common_base_path(other_set)
    max_path_length = [path_length, other_set.path_length].max

    max_path_length.times.reverse_each do |index|
      partial_path_segments = path_segments.slice(0, index + 1)
      other_set_partial_path_segments = other_set.path_segments.slice(0, index + 1)
      return File.join(partial_path_segments) if partial_path_segments == other_set_partial_path_segments
    end

    relative_base_pathname.to_path
  end

  def ensure_real_path!
    pathname.realpath
  rescue Errno::ENOENT
    raise InvalidPathError
  end

  def convert_to_relative_pathname(some_pathname)
    some_pathname.cleanpath.relative_path_from(
      some_pathname.relative? ? relative_base_pathname : absolute_base_pathname
    )
  end

  def relative_base_pathname
    @relative_base_pathname ||= Pathname.new(absolute_base_pathname.to_path).relative_path_from(absolute_base_pathname)
  end

  def absolute_base_pathname
    @absolute_base_pathname ||= Pathname.new(FileUtils.pwd)
  end
end
