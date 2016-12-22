# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'omniauth-mapsme/version'

Gem::Specification.new do |spec|
  spec.name          = "omniauth-mapsme"
  spec.version       = OmniAuth::MapsMe::VERSION
  spec.authors       = ["Ilya Zverev"]
  spec.email         = ["ilya@zverev.info"]

  spec.summary       = %q{MAPS.ME passport strategy for OmniAuth}
  spec.description   = %q{MAPS.ME passport strategy for OmniAuth, complete with regual and access token strategies}
  spec.homepage      = "http://maps.me/"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_dependency "omniauth", "~> 1.2"
  spec.add_dependency "oauth2", "~> 1.0"
  spec.add_dependency "omniauth-oauth2", "~> 1.4"
end
