$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ninja_access/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "ninja_access"
  s.version     = NinjaAccess::VERSION
  s.authors     = ["Domhnall Murphy"]
  s.email       = ["domhnall.murphy@examtime.com"]
  s.homepage    = ""
  s.summary     = "Apply granular group permissions to existing models"
  s.description = "NinjaAccess allows you to create groups that share the same access permissions to existing models in your application."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 3.2.8"
  s.add_dependency "foreigner"

  s.add_development_dependency "mysql2"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "capybara"
  s.add_development_dependency "guard-rspec"
  s.add_development_dependency "guard-spork"
  s.add_development_dependency "factory_girl_rails"
end
