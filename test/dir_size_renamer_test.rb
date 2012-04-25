require "test/unit"
require "fileutils"
require_relative "../lib/dir_size_renamer"

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

class DirSizeRenamerTest < Test::Unit::TestCase

  @@temp_dir               = File.expand_path(File.dirname(__FILE__)) + '/lab3'
  @@theregex               = /^.+ \[\d+(\.\d{1,3})?[KMGT]?B\]$/

  @@dir_prerenamed1        = @@temp_dir + "/prerenamed1 [0B]"
  @@dir_prerenamed2        = @@temp_dir + "/prerenamed2 [134.897KB]"
  @@dir_prerenamed1_actual = @@temp_dir + "/prerenamed1 [1B]"
  @@dir_prerenamed2_actual = @@temp_dir + "/prerenamed2 [0B]"

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

  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.
  def teardown
    FileUtils.rm_rf(@@temp_dir) if Dir.exists?(@@temp_dir)
  end

  def test_rename
    DirSizeRenamer.new(@@temp_dir, verbose: false).rename!

    #Dir.chdir(@@temp_dir)
    Dir[@@temp_dir + "/*"].each do |f|
      assert(f =~ @@theregex)
    end
  end

  def test_rename_undo
    vasya = DirSizeRenamer.new(@@temp_dir, verbose: false)
    vasya.rename!
    vasya.rename_undo!

    #Dir.chdir(@@temp_dir)
    Dir[@@temp_dir + "/*"].each do |f|
      assert_no_match(@@theregex, f)
    end
  end

  def test_dont_rename_prerenamed
    DirSizeRenamer.new(@@temp_dir, verbose: false).rename!

    assert_equal(true,Dir.exists?(@@dir_prerenamed1))
    assert_equal(true,Dir.exists?(@@dir_prerenamed2))
  end

  def test_rerename
    DirSizeRenamer.new(@@temp_dir,rerename: true, verbose: false).rename!

    assert_equal(true,Dir.exists?(@@dir_prerenamed1_actual))
    assert_equal(true,Dir.exists?(@@dir_prerenamed2_actual))
  end
end