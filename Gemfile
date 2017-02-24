source 'https://rubygems.org'
gemspec
gem 'sbsm', :path => '/home/niklaus/git/sbsm'

group :debugger do
	if RUBY_VERSION.match(/^1/)
		gem 'pry-debugger'
	else
		gem 'pry-byebug'
    gem 'pry-doc'
	end
end
