require "gist"
require "git"

class GistDirectory
  MAJOR    = 0
  MINOR    = 0
  REVISION = 3
  VERSION  = [MAJOR, MINOR, REVISION].map(&:to_s).join('.')

  attr_reader :path
  attr_reader :git

  def initialize(path: nil)
    @path = File.expand_path(path)
  end

  def create(filename: nil)
    raise "No filename supplied" if filename.nil?

    if path_exists?
      fail_unless_gist_directory
      fail_if_filename_exists filename
      add_file_to_directory filename: filename
    else
      do_gist_create filename: filename
    end
  end

  private

  def add_file_to_directory(filename: nil)
    do_file_add filename: filename
  end

  def do_gist_create(filename: nil)
    result = Gist.gist(content_for_empty_file, filename: filename, public: true)
    gist_hash = result["id"]

    Git.clone("git@gist.github.com:#{gist_hash}", path)
  end

  def do_file_add(filename: nil)
    absolute = filepath(filename: filename)
    File.open(absolute, "w") { |f| f.puts content_for_empty_file }
    git.add(absolute)
    git.commit("Added '#{filename}'")
    git.push
  end

  def fail_unless_gist_directory
    if ! is_gist_directory?
      raise "#{path} exists and does not contain a Gist repository"
    end
  end
  
  def fail_if_filename_exists(filename)
    absolute = filepath(filename: filename)
    if File.exist?(absolute)
      raise "A file called #{filename} already exists in #{path}"
    end
  end

  def git
    @git ||= Git.open(path)
  end

  def filepath(filename: nil)
    File.join(path, filename)
  end

  def path_exists?
    File.directory?(path)
  end

  def is_gist_directory?
    return false unless File.directory?(File.join(path, ".git"))
    origin = git.remotes.select { |r| r.name == "origin" }[0]
    return false if origin.nil?
    m = %r(^git@gist\.github\.com:\w+$).match(origin.url)
    ! m.nil?
  end

  def content_for_empty_file
    "Empty Gist"
  end
end
