source 'https://rubygems.org'
gemspec
gem 'sbsm', :path => '../sbsm'
gem 'ydim', :path => '../ydim'

group :debugger do
	if RUBY_VERSION.match(/^1/)
		gem 'pry-debugger'
	else
		gem 'pry-byebug'
    gem 'pry-doc'
	end
end
