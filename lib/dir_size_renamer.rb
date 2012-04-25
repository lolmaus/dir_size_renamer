require_relative 'subfolder'
require 'chronic_duration'

class DirSizeRenamer

  def initialize(directory, options = { verbose: false, rerename: false })
    # An existing directory should be provided
    raise "Invalid path given: #{directory}" if not Dir.exists?(directory)
    @directory = directory
    @verbose   = options[:verbose]
    @rerename  = options[:rerename]
  end

  def rename!

    start_time = Time.now

    report "Starting to rename directories within #{@directory}"

    Dir["#{@directory}/*/"].each do |dir|
      subfolder = Subfolder.new(dir.chomp("/"))

      report("Processing #{File.basename(subfolder.directory)}... ", inline: true)

      # Derenaming during renaming is necessary only in rerename mode
      # and only if actual size does not match size in the name
      subfolder.remove_size_from_name! if @rerename == true and not subfolder.name_matches_size?

      subfolder.add_path_to_name! if not subfolder.name_contains_size?
      report(subfolder.size_human_readable,skip_time: true)

    end

    report "Finished! Elapsed time: #{ChronicDuration.output(Time.now - start_time)}"
  end

  def rename_undo!
    report "Starting to derename directories within #{@directory}"

    Dir["#{@directory}/*/"].each do |dir|
      subfolder = Subfolder.new(dir.chomp("/"))

      report("Processing #{File.basename(subfolder.directory)}... ")
      subfolder.remove_size_from_name! if subfolder.name_contains_size?
      #report(subfolder.size_human_readable,skip_time: true) if @verbose

    end

    report "Finished derenaming!"
  end

  private
    def report(text, options = {inline: false, skip_time: false})

      return unless @verbose

      print "[#{Time.new.strftime("%H:%M:%S")}] " unless options[:skip_time]

      if options[:inline]
        print text
      else
        puts text
      end

    end
end