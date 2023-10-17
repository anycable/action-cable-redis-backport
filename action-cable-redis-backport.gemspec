# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name = "action-cable-redis-backport"
  s.version = "1.0.3"
  s.authors = ["Vladimir Dementyev"]
  s.email = ["dementiev.vm@gmail.com"]
  s.homepage = "http://github.com/palkan/action-cable-redis-backport"
  s.summary = "Backports Action Cable 7.1 Redis adapter for older versions"
  s.description = "Backports Action Cable 7.1 Redis adapter for older versions"

  s.metadata = {
    "bug_tracker_uri" => "http://github.com/palkan/action-cable-redis-backport/issues",
    "changelog_uri" => "https://github.com/palkan/action-cable-redis-backport/blob/master/CHANGELOG.md",
    "documentation_uri" => "http://github.com/palkan/action-cable-redis-backport",
    "homepage_uri" => "http://github.com/palkan/action-cable-redis-backport",
    "source_code_uri" => "http://github.com/palkan/action-cable-redis-backport"
  }

  s.license = "MIT"

  s.files = Dir.glob("lib/**/*") + %w[README.md LICENSE.txt]
  s.require_paths = ["lib"]
  s.required_ruby_version = ">= 2.6"

  # Allow using with Rails 7.1+ to test backward compatibility
  if ENV["CI"] == "true"
    s.add_dependency "actioncable", ">= 5.0"
  else
    s.add_dependency "actioncable", ">= 5.0"
  end

  s.add_development_dependency "bundler", ">= 1.15"
  s.add_development_dependency "rake", ">= 13.0"
end
