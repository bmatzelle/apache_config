require 'rubygems'
require 'rdoc/rdoc'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/packagetask'
require 'rake/gempackagetask'

desc "Default Task"
task :default => [ :test ]

# Run the unit tests
task :test do
  ruby 'test\test_runner.rb'
end

# Generate the documentation
task :rdoc do
  rdoc = RDoc::RDoc.new
  
  files = ['README.txt', 'lib/apache_config.rb']
  files += Dir.glob('lib/apache_config/*.rb')

  rdoc.document(["--main", "README.txt", "--title",
                 "ApacheConfig -- Apache configuration file library",
                 "--line-numbers"] + files)
end

# Gem specification
spec = Gem::Specification.new do |s|
  s.name     = 'apacheconfig'
  s.version  = '1.0.0'
  s.author   = 'Brent Matzelle'
  s.email    = 'bmatzelle@yahoo.com'
  s.homepage = 'brentsbits.com'
  s.platform = Gem::Platform::RUBY
  s.summary  = 'Apache configuration file library'
  s.files = ["rakefile.rb", "install.rb", "README.txt", "LICENSE.txt"]
  s.files = s.files + FileList["{lib,test}/**/*"].to_a
  s.require_path = 'lib'
  s.autorequire  = 'apacheconfig'
  s.test_file    = 'test/test_runner.rb'
  s.has_rdoc     = true
  s.extra_rdoc_files = ["README.txt"]
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end
