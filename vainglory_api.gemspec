Gem::Specification.new do |s|
  s.name        = 'vainglory-api'
  s.version     = '0.0.0'
  s.date        = '2017-03-20'
  s.summary     = "Vainglory API"
  s.description = "A Ruby libary wrapper for the Vainglory API"
  s.authors     = ["Chet Bortz"]
  s.files       = ["lib/vainglory_api.rb"]
  s.license     = 'MIT'

  s.add_development_dependency "webmock"
  s.add_development_dependency "vcr"
  s.add_development_dependency "rspec"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "codeclimate-test-reporter"
end
