require 'pathname'
require "colored"

temple = Pathname.new(File.expand_path(File.dirname(__FILE__)))

# Require our helpers
require temple.join('helpers/javascripts.rb')

#----------------------------------------------------------------------------
# Remove unnecessary Rails files
#----------------------------------------------------------------------------
run 'rm README'
run 'rm public/index.html'
run 'rm public/favicon.ico'
run 'rm public/images/rails.png'
run 'touch README'

append_file '.gitignore' do
  '.DS_Store'
  '.rvmrc'
  'config/database.yml'
end

puts "Adding jQuery, jQuery UI and Rails js for jQuery.".yellow
javascript_install_file = 'public/javascripts'

Abbey::JavaScript.fetch('jquery', javascript_install_file)
Abbey::JavaScript.fetch('jquery_ui', javascript_install_file)
Abbey::JavaScript.fetch('jquery_rails', javascript_install_file)

run "mv #{javascript_install_file}/jquery_rails.js #{javascript_install_file}/rails.js"


puts "checking everything into git...".yellow
git :init
git :add => '.'
git :commit => "-am 'Initial commit of a clean rails application.'"

run 'rm Gemfile'

if mongoid = yes?('Use mongodb?')
  apply temple.join('gemfiles/mongoid.rb')
elsif mysql = yes?('Use mysql?')
  apply temple.join('gemfiles/mysql.rb')
end

run 'bundle install'

if mongoid
  apply temple.join('setup/mongoid.rb')
end

if mysql
  apply temple.join('setup/mysql.rb')
end

puts "Running some generators (steak, rspec, simple_form, devise)".yellow
generate('steak:install')
generate('rspec:install')
generate('simple_form:install')
generate('devise:install')
generate('devise:views')

puts "Setting up Devise Mailer".yellow
apply temple.join('setup/devise_mailer.rb')


puts "Prevent logging of passwords".yellow
gsub_file 'config/application.rb', /:password/, ':password, :password_confirmation'

puts "Adding jquery, jquery-ui and rails to the js defaults.".yellow
gsub_file 'config/application.rb', /%w\(\)/, '%w(jquery jquery_ui rails)'

puts "Generating a Home controller with an index action. Adding it as the root_url.".yellow
generate(:controller, "home index")
gsub_file 'config/routes.rb', /get \"home\/index\"/, 'root :to => "home#index"'

puts "Installing compass".yellow
run "compass init rails"


puts "Checking our changes into git.".yellow
git :add    => '.'
git :commit => "-am 'first commit!'"

puts "Abbey has setup everything for you.".yellow