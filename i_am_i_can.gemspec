
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "i_am_i_can/version"

Gem::Specification.new do |spec|
  spec.name          = "i_am_i_can"
  spec.version       = IAmICan::VERSION
  spec.authors       = ["zhandao"]
  spec.email         = ["x@skippingcat.com"]

  spec.summary       = '(RBAC like) Concise and Natural DSL for `Subject - Role(Role Group) - Permission - Resource` Management.'
  spec.description   = '(RBAC like) Concise and Natural DSL for `Subject - Role(Role Group) - Permission - Resource` Management.'
  spec.homepage      = 'https://github.com/zhandao/i_am_i_can'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'database_cleaner'
  spec.add_development_dependency 'pg'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'pry'


  spec.add_dependency 'activerecord'
  spec.add_dependency 'activesupport'
  spec.add_dependency 'railties'
  spec.add_dependency 'colorize'
end
