# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "jekyll-ditaa"
  spec.version       = "1.0.1"
  spec.authors       = ["Matthias Vogelgesang"]
  spec.homepage      = "https://github.com/matze/jekyll-ditaa"

  spec.summary       = "Ditaa plugin for Jekyll"
  spec.license       = "MIT"

  spec.files         = ["jekyll-ditaa.rb"]
  spec.require_paths = ["."]

  spec.add_dependency "jekyll", ">= 3.7", "< 5.0"
end
