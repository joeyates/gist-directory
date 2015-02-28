require "gist"
require "git"

class GistFile
  attr_reader :pathname

  def initialize(pathname)
    @pathname = File.expand_path(pathname)
  end

  def create
    if ! File.directory?(path)
      create_gist
    else
      if exists?
        add_if_not_in_repo
      else
        create_empty_file pathname
        add
      end
    end
  end

  def edit
    create
    raise "Please set the EDITOR environment variable" if ! ENV.include?("EDITOR")

    exec "$SHELL $EDITOR '#{pathname}'"
  end

  def view
    exec "$SHELL gulp-octodown-livereload '#{pathname}'"
  end

  private

  def create_gist
    result = Gist.gist(content_for_empty_file, filename: basename, public: true)
    gist_hash = result["id"]

    Git.clone("git@gist.github.com:#{gist_hash}", path)
  end

  def create_empty_file(pathname)
    File.open(pathname, "w") { |f| f.puts content_for_empty_file }
  end

  def add_if_not_in_repo
    files = git.ls_files.keys
    add if ! files.include?(basename)
  end

  def add
    git.add(pathname)
    git.commit("Added '#{basename}'")
    git.push
  end

  def exists?
    File.exist?(pathname)
  end

  def path
    File.dirname(pathname)
  end

  def basename
    File.basename(pathname)
  end

  def content_for_empty_file
    "Empty Gist"
  end

  def git
    @git ||= Git.open(path)
  end
end

class GistDirectory
  MAJOR    = 0
  MINOR    = 1
  REVISION = 2
  VERSION  = [MAJOR, MINOR, REVISION].map(&:to_s).join('.')

  attr_reader :filename

  def initialize(filename: nil)
    @filename = File.expand_path(filename)
  end

  def path
    @path = File.dirname(filename)
  end

  def create
    if path_exists?
      fail_unless_gist_directory
    end

    file.create
  end

  def edit
    file.edit
  end

  def view
    file.view
  end

  private

  def file
    @file ||= GistFile.new(filename)
  end

  def fail_unless_gist_directory
    if ! is_gist_directory?
      raise "#{path} exists and does not contain a Gist repository"
    end
  end

  def is_gist_directory?
    return false if ! is_git_directory?
    origin = origin_remote
    return false if origin.nil?
    is_gist_url? origin.url
  end

  def is_git_directory?
    git_path = File.join(path, ".git")
    File.directory?(git_path)
  end

  def origin_remote
    git = Git.open(path)
    git.remotes.select { |r| r.name == "origin" }[0]
  end

  def is_gist_url?(url)
    m = %r(^git@gist\.github\.com:\w+$).match(url)
    ! m.nil?
  end

  def path_exists?
    File.directory?(path)
  end
end
