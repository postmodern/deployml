source 'https://rubygems.org'

gem 'rprogram',		'~> 0.1.8'
gem 'pullr',		'~> 0.1.1'
gem 'thor',		'~> 0.14.0'

group(:development) do
  gem 'rake',			'~> 0.8.7'
  gem 'jeweler',		'~> 1.5.0.pre'
end

group(:doc) do
  case RUBY_PLATFORM
  when 'java'
    gem 'maruku',	'~> 0.6.0'
  else
    gem 'rdiscount',	'~> 1.6.3'
  end

  gem 'yard',		'~> 0.6.0'
end

gem 'rspec',	'~> 2.0.0', :group => [:development, :test]
