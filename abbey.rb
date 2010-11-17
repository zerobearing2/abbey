require 'pathname'
require "colored"

temple = Pathname.new(File.expand_path(File.dirname(__FILE__)))

# Require our helpers
require temple.join('helpers/javascripts.rb')

# ============================================================================
# Remove unnecessary files
# ============================================================================
run 'rm README'
run 'rm public/index.html'
run 'rm public/favicon.ico'
run 'rm public/images/rails.png'
run 'touch README'

# ============================================================================
# Setup the gitignore file
# ============================================================================
append_file '.gitignore' do
  '.DS_Store'
  '.rvmrc'
  'config/database.yml'
  '.bundle-cache'
  '.sass-cache/'
  'public/assets'
  'public/system'
  'public/uploads'
  'coverage/*'
end

# ============================================================================
# Adding jquery, jqueryui, rails.js
# ============================================================================
puts "Adding jQuery, jQuery UI and Rails js for jQuery.".yellow
javascript_install_file = 'public/javascripts'

Abbey::JavaScript.fetch('jquery', javascript_install_file)
Abbey::JavaScript.fetch('jquery_ui', javascript_install_file)
Abbey::JavaScript.fetch('jquery_rails', javascript_install_file)

run "mv #{javascript_install_file}/jquery_rails.js #{javascript_install_file}/rails.js"

# ============================================================================
# Add a "project" for project details to the lib folder
# ============================================================================
file 'lib/project.rb', <<-CODE
module Project
  class Version
    attr_reader :major, :minor, :tiny
    
    def initialize(major, minor, tiny)
      @major = major
      @minor = minor
      @tiny  = tiny
    end
    
    def ==(version)
      if version.is_a? Version
        version.major == major && version.minor == minor && version.tiny == tiny
      else
        version.to_s == to_s
      end
    end
    
    def to_s
      @string ||= [@major, @minor, @tiny] * '.'
    end
    
    alias_method :inspect, :to_s
  end

  def self.[](key)
    unless @config
      raw_config = File.read(RAILS_ROOT + "/config/application.yml")
      @config = YAML.load(raw_config)[RAILS_ENV].symbolize_keys
    end
    @config[key]
  end

  def self.[]=(key, value)
    @config[key.to_sym] = value
  end
  
  def self.domain
    [:domain]
  end
    
  def self.full_url
    "http://#{domain}"
  end 

  class << self
    attr_accessor :version, :project_name
  end

  self.version        = Version.new(0, 0, 1)
  self.project_name   = "Project Name (update this in lib/my_app.rb)" 

end
CODE

# ============================================================================
# Use haml
# ============================================================================
if yes?("Would you like to use haml?")
  run 'rm app/views/layouts/application.html.erb'
  file 'app/views/layouts/application.html.haml', <<-CODE
  !!! 5
  %html{:xmlns =>"http://www.w3.org/1999/xhtml", "xml:lang" => I18n.locale, :lang => I18n.locale}
    %head

      = display_meta_tags :site => Project.project_name, :reverse => true

      %meta{:name => "app_version", :content => Project.version}   
      %meta{:content => "text/html; charset=utf-8", "http-equiv" => "Content-Type"}

      = javascript_include_tag :all, :cache => true

      = stylesheet_link_tag 'compiled/screen', :media => :screen
      = stylesheet_link_tag 'compiled/print', :media => :print
      /[if lt IE 8]
        = stylesheet_link_tag 'compiled/ie', :media => :all

    %body{:id => "site-id", :class => body_class}
      .flash
        - flash.each do |key, value|
          %div{:id => "flash_#{key}"}
            =h value
      = yield
      %p 
        Version:
        = Project.version
  CODE
end



# ============================================================================
# Git initial checking
# ============================================================================
puts "checking everything into git...".yellow
git :init
git :add => '.'
git :commit => "-am 'Initial commit of a clean rails application.'"

# ============================================================================
# Add the appropriate gemfile
# ============================================================================
run 'rm Gemfile'

if mongoid = yes?('Use mongodb?')
  apply temple.join('gemfiles/mongoid.rb')
elsif mysql = yes?('Use mysql?')
  apply temple.join('gemfiles/mysql.rb')
end

run 'bundle install'

# ============================================================================
# setup for the database that is being used
# ============================================================================
if mongoid
  apply temple.join('setup/mongoid.rb')
end

if mysql
  apply temple.join('setup/mysql.rb')
end

# ============================================================================
# run the generators
# ============================================================================
puts "Running some generators (steak, rspec, simple_form, devise)".yellow
generate('steak:install')
generate('rspec:install')
generate('simple_form:install')
generate('devise:install')
generate('devise:views')


# ============================================================================
# setup devise mailer for dev/test/prod
# ============================================================================
puts "Setting up Devise Mailer".yellow
apply temple.join('setup/devise_mailer.rb')


# ============================================================================
# Modify config/application.rb file
# ============================================================================
puts "Prevent logging of passwords".yellow
gsub_file 'config/application.rb', /:password/, ':password, :password_confirmation'

puts "Adding jquery, jquery-ui and rails to the js defaults.".yellow
gsub_file 'config/application.rb', /%w\(\)/, '%w(jquery jquery_ui rails)'


# ============================================================================
# Generate a home controller with an index action
# ============================================================================
puts "Generating a Home controller with an index action. Adding it as the root_url.".yellow
generate(:controller, "home index")
gsub_file 'config/routes.rb', /get \"home\/index\"/, 'root :to => "home#index"'


# ============================================================================
# Run the compass init
# ============================================================================
puts "Installing compass".yellow
run 'compass init rails --css-dir=public/stylesheets/compiled --sass-dir=app/stylesheets --syntax sass'


# ============================================================================
# final git checkin
# ============================================================================
puts "Checking our changes into git.".yellow
git :add    => '.'
git :commit => "-am 'first commit!'"

puts "Abbey has setup everything for you.".yellow