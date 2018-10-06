
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
    'README.{md,txt}',
    'CHANGELOG.{md,txt}', 'CREDITS.{md,txt}', 'LICENSE.{md,txt}',
    'Makefile',
    'lib/**/*.rb', #'spec/**/*.rb', 'test/**/*.rb',
    "#{s.name}.gemspec",
  ]

  #flor_version = s.version.to_s.split('.').take(2).join('.')
  #s.add_runtime_dependency 'flor', "~> #{flor_version}"
  s.add_runtime_dependency 'flor'

  s.add_runtime_dependency 'rack', '~> 1.6'
  s.add_runtime_dependency 'sequel', '~> 4'
  s.add_runtime_dependency 'httpclient', '~> 2.8'

  s.add_development_dependency 'rspec', '~> 3'

  s.require_path = 'lib'
end

