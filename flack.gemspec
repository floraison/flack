
Gem::Specification.new do |s|

  s.name = 'flack'

  s.version = File.read(
    File.expand_path('../lib/flack.rb', __FILE__)
  ).match(/ VERSION *= *['"]([^'"]+)/)[1]

  s.platform = Gem::Platform::RUBY
  s.authors = [ 'John Mettraux' ]
  s.email = [ 'jmettraux@gmail.com' ]
  s.homepage = 'http://github.com/floraison'
  #s.rubyforge_project = 'flor'
  s.license = 'MIT'
  s.summary = 'a web front-end to the flor workflow engine'

  s.description = %{
A web front-end to the flor workflow engine
  }.strip

  #s.files = `git ls-files`.split("\n")
  s.files = Dir[
    'Makefile',
    'lib/**/*.rb', #'spec/**/*.rb', 'test/**/*.rb',
    '*.gemspec', '*.txt', '*.rdoc', '*.md'
  ]

  s.add_runtime_dependency 'flor', s.version

  s.add_development_dependency 'rspec', '3.4.0'

  s.require_path = 'lib'
end

