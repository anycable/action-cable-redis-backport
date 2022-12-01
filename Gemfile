# frozen_string_literal: true

source "https://rubygems.org"

gem "debug", platform: :mri

gemspec

local_gemfile = "#{File.dirname(__FILE__)}/Gemfile.local"

if File.exist?(local_gemfile)
  eval(File.read(local_gemfile)) # rubocop:disable Security/Eval
else
  gem "redis", "< 5"
  gem "rails", "~> 6.0"
end
