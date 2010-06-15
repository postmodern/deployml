require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:development, :doc)
rescue Bundler::BundlerError => e
  STDERR.puts e.message
  STDERR.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rake'
require 'jeweler'
require './lib/deployml/version.rb'

Jeweler::Tasks.new do |gem|
  gem.name = 'deployml'
  gem.version = DeploYML::VERSION
  gem.license = 'MIT'
  gem.summary = %Q{A deployment solution that works.}
  gem.description = %Q{DeploYML is a simple deployment solution that uses a single YAML file and does not require Ruby to be installed on the server.}
  gem.email = 'postmodern.mod3@gmail.com'
  gem.homepage = 'http://github.com/postmodern/deployr'
  gem.authors = ['Postmodern']
  gem.has_rdoc = 'yard'
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs += ['lib', 'spec']
  spec.spec_files = FileList['spec/**/*_spec.rb']
  spec.spec_opts = ['--options', '.specopts']
end

task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new
