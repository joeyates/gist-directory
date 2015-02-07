# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift(File.expand_path("lib", __dir__))
require "gist_directory"

Gem::Specification.new do |gem|
  gem.name          = "gist_directory"
  gem.summary       =
  gem.description   = "Create collections of Gists"
  gem.authors       = ["Joe Yates"]
  gem.email         = ["joe.g.yates@gmail.com"]
  gem.homepage      = "https://github.com/joeyates/gist_directory"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^spec/})
  gem.require_paths = ["lib"]
  gem.version       = GistDirectory::VERSION

  gem.required_ruby_version = ">= 2.0.0"

  gem.add_runtime_dependency "git"
  gem.add_runtime_dependency "gist"

  gem.add_development_dependency "rspec",  ">= 3.0.0"
  gem.add_development_dependency "pry-byebug"
end
