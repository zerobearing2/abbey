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
gsub_file 'config/application.rb', /# Custom directories with classes and modules you want to be autoloadable\./ do
<<-RUBY
config.autoload_paths += %W(\#{config.root}/lib)
RUBY
end

file 'config/build.version', '0.0.1'

file 'lib/project.rb', <<-CODE
module Project
  self.name     = 'Project name'
  self.domain   = 'Domain Name'
  self.version  = Project::Version.current

  class Version
    class << self
      
      ##
      # The location of the version number file
      VERSION_FILE  = File.join(File.dirname(__FILE__), "..", "config", "build.version")
      @@releases    = %w[major minor tiny].freeze
    
    
      ##
      # Generate build version file
      #
      def generate_build_file
        File.open(VERSION_FILE, 'w') { |f| f.write '0.0.1' }
        print "Created your build file (build.version) located at \#{VERSION_FILE.to_s}"
      end
    
      ##
      # Current Version
      #
      # Pulls the current build version 
      #
      def current
        ver = (File.read(VERSION_FILE).chomp rescue 0)
        "\#{ver}"
      end
 
    
      ##
      # Verion it
      #
      # @param  [String, Symbol]
      #
      def version_it(direction, release)
        version     = File.read(VERSION_FILE).chomp
        int_ver     = version.split('.').join().to_i
        new_version = case release
        when :major then update_build_version(int_ver, direction, 100)
        when :minor then update_build_version(int_ver, direction, 10)
        when :point then update_build_version(int_ver, direction, 1)
        else
          raise ArgumentError, "You can only increase the version number by major, minor, or point."
        end
 
        File.open(VERSION_FILE, 'w') { |f| f.write new_version }
        print "Previous Version: \#{version} - New Version: \#{new_version}" and return
      end
    
    
      ##
      # Method Missing
      #
      # @param  [String, Symbol]
      #
      # Project::Version.up(:point)
      # Project::Version.down(:point)
      # Project::Version.up(:minor)
      # Project::Version.down(:major)
      # 
      #
      def method_missing(direction, release)
        if @@releases.include?(release.to_s.downcase)
          version_it(direction, release)
        else
          super
        end
      end
    
      private
      
        ##
        # Update build version
        #
        # @param  [Integer, Symbol, Symbol]
        # @return [String]
        #
        def update_build_version(version, direction, points)
          new_version = case direction
          when :up    then ("%03d" % (version + points)).split(//).join('.')
          when :down  then ("%03d" % (version - points unless version == 0)).split(//).join('.')
          else
            "%03d" % version
          end
          new_version
        end
    end
  end
end
CODE

# ============================================================================
# Use haml
# ============================================================================
if haml = yes?("Would you like to use haml?")
  run 'rm app/views/layouts/application.html.erb'
  file 'app/views/layouts/application.html.haml', <<-CODE
!!! 5
%html{:xmlns =>"http://www.w3.org/1999/xhtml", "xml:lang" => I18n.locale, :lang => I18n.locale}
  %head

    = display_meta_tags :site => Project.name, :reverse => true

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
        %div{:id => "flash_\#{key}"}
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