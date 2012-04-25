require 'find'

class Subfolder

  attr_reader :directory

  def self.renamed_eof_regex
    / \[\d+(\.\d{1,3})?[KMGT]?B\]$/
  end

  def initialize(directory)
    # An existing directory should be provided
    raise "Invalid path given: #{directory}" if not Dir.exists?(directory)
    @directory = directory
  end

  def calc_size!
    dirsize = 0
    Find.find(@directory) do |f|
      dirsize += File.stat(f).size if File.exists?(f) and not File.symlink?(f)
    end

    @size = dirsize

  end

  def size
    @size or calc_size!
  end

  def name_contains_size?
    @directory =~ Subfolder.renamed_eof_regex
  end

  def name_matches_size?
    name_contains_size? and (@directory =~ / \[#{size_human_readable}\]/)
  end

  def add_path_to_name!
    new_name = name_with_size
    File.rename(@directory, new_name)
    @directory = new_name
  end

  def remove_size_from_name!
    return if not name_contains_size?
    new_name = name_without_size
    File.rename(@directory, new_name)
    @directory = new_name
  end

  def size_human_readable
    Subfolder.size_human_readable(size)
  end

  def self.size_human_readable(number_of_bytes)
    raise "Tried to convert invalid value to human-readable file size: #{number_of_bytes}, #{number_of_bytes.class}" if (number_of_bytes.class != Fixnum \
                                                                                                                         and number_of_bytes.class != Bignum) \
                                                                                                                     or number_of_bytes < 0
    return "0B" if number_of_bytes == 0
    units = %w{B KB MB GB TB}
    e = (Math.log(number_of_bytes)/Math.log(1024)).floor
    s = "%.3f" % (number_of_bytes.to_f / 1024**e)
    s.sub(/\.?0*$/, units[e])
  end

  def self.remove_size_from_string(name)
    name.gsub(Subfolder.renamed_eof_regex,"")
  end

  private
    def name_with_size
      "#{@directory} [#{Subfolder.size_human_readable(size)}]"
    end

    def name_without_size
      Subfolder.remove_size_from_string(@directory)
    end



end


