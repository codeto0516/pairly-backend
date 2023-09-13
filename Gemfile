source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.4"
gem "rails", "~> 7.0.7"

gem "puma", "~> 5.0"

gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

gem "rack-cors"
gem 'jwt'
gem 'will_paginate'
gem 'json'
gem 'google-apis-identitytoolkit_v3'
gem 'google-cloud-storage'

group :development, :test do
  gem "sqlite3", "~> 1.4"
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem 'rspec-rails'
end

group :development do
  gem 'dotenv-rails' 
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
end

group :production do
  gem 'mysql2'
end
