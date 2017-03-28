Gem::Specification.new do |s|
  s.name        = 'vainglory-api'
  s.version     = '0.0.3'
  s.date        = '2017-03-28'
  s.summary     = "Vainglory API"
  s.description = "A Ruby libary wrapper for the Vainglory API"
  s.authors     = ["Chet Bortz"]
  s.files       = ["lib/vainglory_api.rb"]
  s.license     = 'MIT'

  s.add_development_dependency "webmock", '~> 2.3'
  s.add_development_dependency "vcr", '~> 3.0'
  s.add_development_dependency "rspec", '~> 3.5'
  s.add_development_dependency "simplecov", '~> 0.14'
  s.add_development_dependency "codeclimate-test-reporter", '~> 1.0'
end
