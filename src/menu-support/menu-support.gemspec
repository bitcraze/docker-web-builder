# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "menu-support"
  spec.version       = "1.1.0"
  spec.authors       = ["Kristoffer Richardsson"]
  spec.homepage      = "https://github.com/bitcraze/docker-web-builder"

  spec.summary       = "Include plugin for Jekyll"
  spec.license       = "MIT"

  spec.files         = ["menu-support.rb"]
  spec.require_paths = ["."]

  spec.add_dependency "jekyll", ">= 4.0", "< 5.0"
end
