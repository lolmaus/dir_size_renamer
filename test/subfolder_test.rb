require "test/unit"
require_relative "../lib/subfolder"
require "find"
require "fileutils"

# This stuff is needed for RubyMine to parse test results
require 'minitest/reporters'
MiniTest::Unit.runner = MiniTest::SuiteRunner.new
if ENV["RM_INFO"] || ENV["TEAMCITY_VERSION"]
  MiniTest::Unit.runner.reporters << MiniTest::Reporters::RubyMineReporter.new
elsif ENV['TM_PID']
  MiniTest::Unit.runner.reporters << MiniTest::Reporters::RubyMateReporter.new
else
  MiniTest::Unit.runner.reporters << MiniTest::Reporters::ProgressReporter.new
end
# End of RubyMine minitest stuff


class SubfolderTest < Test::Unit::TestCase

  # Test configuration

  # Provide a valid filesystem path that contains some data, but not too much
  #@@dir_with_data   = 'C:\\OpenSSL-Win32'

  #@@curdir          = File.expand_path(File.dirname(__FILE__))
  #@@dir_with_data   = "#{@@curdir}/lab/full"
  #@@dir_empty       = "#{@@curdir}/lab/empty"
  #@@dir_nonexistent = "#{@@curdir}/lab/blah"
  #@@dir_prerenamed1 = "#{@@curdir}/lab/prerenamed [0B]"
  #@@dir_prerenamed2 = "#{@@curdir}/lab/prerenamed [65.432KB]"
  #@@file            = "#{@@curdir}/lab/full/XnView.lnk"

  @@theregex               = /^.+ \[\d+(\.\d{1,3})?[KMGT]?B\]$/
  @@temp_dir               = File.expand_path(File.dirname(__FILE__)) + '/lab3'
  @@dir_prerenamed1        = @@temp_dir + "/prerenamed1 [0B]"
  @@dir_prerenamed2        = @@temp_dir + "/prerenamed2 [134.897KB]"
  @@dir_name_actual        = @@temp_dir + "/prerenamed3 [0B]"
  @@dir_name_wrong         = @@temp_dir + "/prerenamed4 [10B]"
  @@dir_prerenamed1_actual = @@temp_dir + "/prerenamed1 [1B]"
  @@dir_prerenamed2_actual = @@temp_dir + "/prerenamed2 [0B]"
  @@dir_with_data          = @@temp_dir + "/1"
  @@dir_empty              = @@temp_dir + "/empty"
  @@dir_nonexistent        = @@temp_dir + "/tguiaefagui"
  @@file                   = @@temp_dir + "/1/file"


  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    FileUtils.rm_rf(@@temp_dir) if Dir.exists?(@@temp_dir)
    Dir.mkdir(@@temp_dir) # unless Dir.exists?(@@temp_dir)

    #Creating directory structure for tests
    5.times do |i|
      dir = @@temp_dir + "/#{i}"
      Dir.mkdir(dir)

      size = 2 ** i
      File.open("#{dir}/file", 'w') { |f| f.seek(size-1);f.write("\0")} unless size <= 0
    end

    Dir.mkdir(@@dir_prerenamed1)
    File.open("#{@@dir_prerenamed1}/file", 'w') { |f| f.write("\0")}

    Dir.mkdir(@@dir_prerenamed2)
    Dir.mkdir(@@dir_name_actual)
    Dir.mkdir(@@dir_name_wrong)
    Dir.mkdir(@@dir_empty)

  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.
  def teardown
   FileUtils.rm_rf(@@temp_dir) if Dir.exists?(@@temp_dir)
  end

  def test_variables_are_strings
    # Variables contain strings
    assert_equal(String, @@dir_with_data.class)
    assert_equal(String, @@dir_empty.class)
    assert_equal(String, @@dir_nonexistent.class)
  end

  def test_variables_point_to_existing_paths
    assert(File.exists?(@@dir_with_data))
    assert(File.exists?(@@dir_empty))
    assert(!File.exists?(@@dir_nonexistent))
  end

  def test_variables_point_to_directories
    assert(File.directory?(@@dir_with_data))
    assert(File.directory?(@@dir_empty))
  end

  def test_has_contents
    assert_equal(Array,Dir.entries(@@dir_with_data).class)
    assert(Dir.entries(@@dir_with_data).count >= 1)
    assert_equal(Array,Dir.entries(@@dir_empty).class)

    empty = Dir.entries(@@dir_empty)
    empty.delete(".")
    empty.delete("..")
    assert_equal(0, empty.count)
  end

  def test_has_positive_size
    dirsize = 0
    Find.find(@@dir_with_data) { |f| dirsize += File.stat(f).size }
    assert(dirsize > 0)

    dirsize = 0
    Find.find(@@dir_empty) { |f| dirsize += File.stat(f).size }
    assert_equal(0, dirsize)
  end


  # Test that Subfolder only initializes with valid path
  def test_initialize
    assert_raise(RuntimeError){Subfolder.new(@@dir_nonexistent)}
    assert_raise(RuntimeError){Subfolder.new(@@file)}
  end

  def test_get_size
    barney = Subfolder.new(@@dir_with_data)
    assert_equal(Fixnum,barney.size.class)
    assert_equal(2, barney.size)

    barney = Subfolder.new(@@dir_with_data)
    barney.calc_size!
    assert_equal(2, barney.size)

    barney = Subfolder.new(@@dir_empty)
    assert_equal(Fixnum,barney.size.class)
    assert(barney.size == 0)

    barney = Subfolder.new(@@dir_empty)
    barney.calc_size!
    assert(barney.size == 0)
  end

  def test_size_human_readable
    assert_equal("1B",Subfolder.size_human_readable(1))
    assert_equal("339.596GB",Subfolder.size_human_readable(364638486345))
    assert_equal("1KB",Subfolder.size_human_readable(1024))
    assert_equal("1.001KB",Subfolder.size_human_readable(1025))
  end

  def test_name
    assert_equal(@@dir_with_data + " [2B]",Subfolder.new(@@dir_with_data).send(:name_with_size))
    assert_equal(@@dir_empty + " [0B]",Subfolder.new(@@dir_empty).send(:name_with_size))
  end

  def test_name_without_size
    assert_equal("blah", Subfolder.remove_size_from_string("blah [234.569TB]"))
    assert_equal(" ", Subfolder.remove_size_from_string("  [234.56TB]"))
    assert_equal("blah", Subfolder.remove_size_from_string("blah [0B]"))
    assert_equal("blah", Subfolder.remove_size_from_string("blah [25KB]"))
    assert_equal("[asdfas]asda", Subfolder.remove_size_from_string("[asdfas]asda [12.3MB]"))
  end

  def test_rename
   
    assert("G 2012-04-17 12;40;29 (Full) [466.965GB]" =~ @@theregex)
    assert("vasya [123B]" =~ @@theregex)
    assert("vasya [123.1B]" =~ @@theregex)
    assert("vasya [123.02KB]" =~ @@theregex)
    assert("vasya [123.423MB]" =~ @@theregex)
    assert("vasya [123.1GB]" =~ @@theregex)
    assert("vasya [12TB]" =~ @@theregex)
    assert("  [1B]" =~ @@theregex)

    assert_no_match(@@theregex,"petya [123.TB]")
    assert_no_match(@@theregex," [123TB]")

    bake = Subfolder.new(@@dir_with_data)
    bake.add_path_to_name!

    assert_equal(@@dir_with_data + " [2B]", bake.directory)
    assert_equal(2, bake.size)
    assert(Dir.exists?(bake.directory))

    bake.remove_size_from_name!

    assert_equal(@@dir_with_data, bake.directory)
    assert(Dir.exists?(bake.directory))

    bake = Subfolder.new(@@dir_empty)
    bake.add_path_to_name!

    assert_equal(@@dir_empty + " [0B]", bake.directory)
    assert_equal(0, bake.size)
    assert(Dir.exists?(bake.directory))

    bake.remove_size_from_name!

    assert_equal(@@dir_empty, bake.directory)
    assert(Dir.exists?(bake.directory))


  end


  def test_renamed
    assert(Subfolder.new(@@dir_prerenamed1).name_contains_size?)
    assert(Subfolder.new(@@dir_prerenamed2).name_contains_size?)
    assert_equal(nil,Subfolder.new(@@dir_empty).name_contains_size?)
  end

  def test_name_matches_size
    assert_equal(true, !!Subfolder.new(@@dir_name_actual).name_matches_size?)
    assert_equal(false, !!Subfolder.new(@@dir_with_data).name_matches_size?)
    assert_equal(false, !!Subfolder.new(@@dir_name_wrong).name_matches_size?)
  end

end