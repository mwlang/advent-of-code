data = File.readlines('input.txt', chomp: true)

module AoC
  class File
    attr_reader :name, :parent

    def initialize name, size, parent
      @name = name
      @size = size.to_i
      @parent = parent
    end

    def size
      @size
    end

    def inspect
      "<File name=#{name}, size=#{size} parent=#{parent&.name || '/'}>"
    end

    def directory?
      is_a?(Directory)
    end
  end

  class Directory < File
    attr_reader :files

    def initialize name, parent
      @name = name
      @parent = parent
      @files = []
    end

    def size
      @files.map(&:size).reduce(&:+)
    end

    def directories
      @files.select(&:directory?)
    end

    def directory?
      true
    end

    def add_file name, size
      files << File.new(name, size, self).tap{|f| puts "FILE: #{f.inspect}"}
    end

    def add_directory name
      dir = Directory.new(name, self)
      puts "DIRECTORY: #{dir.inspect}"
      files << dir
    end

    def find(file_name)
      @files.find{ |file| file.name == file_name } or raise "no file named #{file_name} in #{name}"
    end

    def inspect
      "<Directory name=#{name}, size=#{size} files=#{files.count} parent=#{parent&.name || '/'}>"
    end
  end

  class Shell
    attr_reader :current_directory

    def initialize
      @current_directory = root_directory
    end

    def root_directory
      @root_directory ||= Directory.new("/", nil)
    end

    def run stdin
      cmd = stdin.shift or return
      puts "RUN: #{cmd.inspect}"
      if cmd =~ /^\$/
        execute(cmd.split("$ ")[-1], stdin)
      else
        raise "whoopsie! #{cmd.inspect}"
      end
      run stdin
    end

    def execute cmd_and_args, stdin
      cmd, args = cmd_and_args.split(/\s+/)
      case cmd
      when 'cd' then change_directory(args)
      when 'ls' then list_files(stdin)
      else raise "oops! #{cmd_and_args.inspect}"
      end
    end

    def print_directory_files directory
      directory.files.each{ |f| pp f }
      directory.directories.each{ |dir| print_directory_files dir }
    end

    def print_file_tree
      pp root_directory
      print_directory_files root_directory
    end

    def find_directories threshold: 0, dir: root_directory, &block
      yield dir if dir.size <= threshold || threshold.zero?
      dir.directories.each{ |dir| find_directories threshold: threshold, dir: dir, &block }
    end

    private

    DIR_OR_FILE_REGEX = /^dir\s|^\d+\s\w+/
    def list_files(stdin)
      return if stdin.empty? || stdin.first !~ DIR_OR_FILE_REGEX

      add_file_or_dir(stdin.shift)
      list_files(stdin)
    end

    def add_file_or_dir args
      args = args.split(' ')
      args[0] == 'dir' ? add_directory(args[1]) : add_file(args[1], args[0])
    end

    def change_directory directory
      directory == '..'  ? change_to_parent_directory : change_to_subdirectory(directory)
    end

    def add_directory(name)
      current_directory.add_directory name
    end

    def add_file name, size
      current_directory.add_file name, size
    end

    def change_to_parent_directory
      @current_directory = current_directory.parent
    end

    def change_to_subdirectory(directory)
      @current_directory = directory == '/' ? root_directory : current_directory.find(directory)
    end
  end
end

shell = AoC::Shell.new
shell.run data

print "PART 1: "
capped_directories = []
shell.find_directories(threshold: 100_000) { |dir| capped_directories << dir }
puts capped_directories.map(&:size).reduce(&:+)

print "PART 2: "
all_directories = []
shell.find_directories { |dir| all_directories << dir }.sort_by(&:size)

total_space = 70_000_000
free_space_needed = 30_000_000
used_space = shell.root_directory.size
unused_space = total_space - used_space
additional_space = free_space_needed - unused_space

puts all_directories.select{ |dir| dir.size > additional_space }.last.size