
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "fields/serializer/version"

Gem::Specification.new do |spec|
  spec.name          = "fields-serializer"
  spec.version       = Fields::Serializer::VERSION
  spec.authors       = ["Stuart Chinery", "Miguel Montalbo", "Lorenzo Tello"]
  spec.email         = ["stuart.chinery@gmail.com, mmontalbo@zonedigital.com, ltello8a@gmail.com"]

  spec.summary       = "Extensions to ActiveRecord and ActionController to serialize a subset of model fields"
  spec.description   = "Extensions to ActiveRecord and ActionController to serialize a subset of model fields"
  spec.homepage      = "https://github.com/ltello/fields-serializer"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler",      "~> 1.16"
  spec.add_development_dependency "rake",         "~> 10.0"
  spec.add_development_dependency "rspec",        "~> 3.6"
  spec.add_development_dependency "factory_girl", "~> 4.8"
  spec.add_development_dependency "byebug",       "~> 5.0"
  spec.add_development_dependency "simplecov"

  spec.add_runtime_dependency     "rails",        "~> 5.0"
  spec.add_runtime_dependency     "active_model_serializers", "~> 0.10"
end
