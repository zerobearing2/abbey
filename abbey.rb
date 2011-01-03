require 'pathname'
require "colored"

temple = Pathname.new(File.expand_path(File.dirname(__FILE__)))

# Require our helpers
require temple.join('helpers/javascripts.rb')

# Check to see if mysql is being used.
@mysql_in_use   = true if File.exists?(File.join(Dir.pwd, 'config/database.yml'))
@jquery_in_use  = true if !File.exists?(File.join(Dir.pwd, 'public/javascripts/prototype.js'))

# ============================================================================
# Remove unnecessary files
# ============================================================================
run 'rm README'
run 'rm public/index.html'
run 'rm public/favicon.ico'
run 'rm public/images/rails.png'
run 'cp config/database.yml config/datbase.yml.example' if @mysql_in_use
run 'touch README.mkd'
run 'mkdir -p app/views/layout_partials'

# ============================================================================
# Setup the gitignore file
# ============================================================================
append_file '.gitignore' do
  '.DS_Store'
  '.rvmrc'
  'config/database.yml'
  '.bundle-cache'
  'gems/*'
  'log/*.log'
  '.sass-cache/'
  'public/assets'
  'public/system'
  'public/uploads'
  'coverage/*'
end

# ============================================================================
# Setup the Seeding
# ============================================================================
run 'mkdir -p db/seeds'
append_file 'db/seeds.rb' do
  'require "colored"'
  'Dir[Rails.root.join("db/seeds/**/*.rb")].each {|f| require f}'
end

# ============================================================================
# Setup the application helper
# ============================================================================
run 'rm app/helpers/application_helper.rb'
apply temple.join('app/helpers/application_helper.rb')

# ============================================================================
# Adding jquery, jqueryui, rails.js
# ============================================================================
javascript_install_file = 'public/javascripts'
if @jquery_in_use
  puts "Adding jQuery, jQuery UI and Rails js for jQuery.".yellow

  Abbey::JavaScript.fetch('jquery',       javascript_install_file)
  Abbey::JavaScript.fetch('jquery_ui',    javascript_install_file)
  Abbey::JavaScript.fetch('jquery_rails', javascript_install_file)

  run "mv #{javascript_install_file}/jquery_rails.js #{javascript_install_file}/rails.js"
  
  puts "Adding jquery, jquery-ui and rails to the js defaults.".yellow
  gsub_file 'config/application.rb', /%w\(\)/, '%w(jquery jquery_ui rails)'
end

puts "Installing Modernizr".yellow.bold
Abbey::JavaScript.fetch('modernizr', javascript_install_file)

# ============================================================================
# Add the app module for project details to the lib folder
# ============================================================================
gsub_file 'config/application.rb', /# Custom directories with classes and modules you want to be autoloadable\./ do
<<-RUBY
config.autoload_paths += %W(\#{config.root}/lib)
RUBY
end

file 'config/build.version', '0.0.1'

file 'lib/app.rb', <<-CODE
require 'colored'
module App
  class Project
    class << self
    
      def name
        'Project Name'.yellow
      end
    
      def domain
        'Domain Name'.yellow
      end
    
      def version
        Version.current
      end
    
    end
  end
  
  class VersionError < StandardError; end

  class Version
    class << self
    
      ##
      # The location of the version number file
      VERSION_CONFIG  = File.expand_path(File.join(File.dirname(__FILE__), "..", "config"))
      VERSION_FILE    = File.expand_path(File.join(VERSION_CONFIG, "build.version"))
      @@releases      = %w[major minor point].freeze
  
  
      # Generate a build.version file to the config/ directory of a rails application.
      def generate_build_file
        
        # create the config directory if it doesn't already exist
        FileUtils.mkdir_p(VERSION_CONFIG) unless File.exists?(VERSION_CONFIG)
        
        # create the build.version file and add the first version, 0.0.1
        File.open(VERSION_FILE, 'w') { |f| f.write '0.0.1' }
        print "Created a build version file (build.version) located at \#{VERSION_FILE.to_s}"
      end
  

      # Return the current version number from the build version file.
      def current
        ver = read_build_file
        "\#{ver}".green
      end
      
      
      # Read the Build File
      def read_build_file
        (File.read(VERSION_FILE).chomp rescue 0)
      end

  
      # Verison up or down for major, minor, and point releases
      def versioning(direction, release)
        version     = read_build_file
        int_ver     = version.split('.').join().to_i
        
        # case to determine versioning release
        new_version = case release
        when :major then update_build_version(int_ver, direction, 100)
        when :minor then update_build_version(int_ver, direction, 10)
        when :point then update_build_version(int_ver, direction, 1)
        else
          raise ArgumentError, "You can only increase the version number by major, minor, or point."
        end
        
        # save the version number to the build version file
        File.open(VERSION_FILE, 'w') { |f| f.write new_version }
        
        # give the user a message that it has completed and show the previous/current version.
        print "Previous Version: \#{version} - New Version: \#{new_version}".green
      end
  
  
      # Method Missing for capturing the Version.up and Version.down
      def method_missing(direction, release)
        raise VersionError.new("You can only version up or down.") unless ['up', 'down'].include?(direction)
        
        # if major/minor/point is requested
        if @@releases.include?(release.to_s.downcase)
          versioning(direction, release)
        else
          super
        end
        
      end
  
  
      private
    
        # Does the actual updating of the version numbers
        def update_build_version(version, direction, points)
          
          # what direction is being requested
          new_version = case direction
          
          # add version points to the current version
          when :up    then ("%03d" % (version + points)).split(//).join('.')
            
          # minus version points from the current version
          when :down  then ("%03d" % (version - points unless version == 0)).split(//).join('.')
          
          else
            
            # the current version
            "%03d" % version
          end
          
          new_version
        end
    end
  end
end
CODE

# ============================================================================
# Apply the rake tasks associated with App::Project
# ============================================================================
apply temple.join('tasks/version.rb')

# ============================================================================
# Git initial checking
# ============================================================================
puts "checking everything into git...".yellow
git :init
git :add => '.'
git :commit => "-am 'Initial commit of a clean rails application.'"

# ============================================================================
# Setup for specific database
# ============================================================================
run 'rm Gemfile'


if @mysql_in_use
  puts "Running some setup tasks for MySQL.".green.bold
  apply temple.join('gemfiles/mysql.rb')
  run 'bundle install'
  apply temple.join('setup/mysql.rb')
  apply temple.join('tasks/reseed.rb')
else
  if mongoid = yes?('Use mongodb?')
    puts "Running some setup tasks for MongoDB.".green.bold
    apply temple.join('gemfiles/mongoid.rb')
    run 'bundle install'
    apply temple.join('setup/mongoid.rb')
  end
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

# ============================================================================
# Use haml
# ============================================================================
if haml = yes?("Would you like to use haml?")
  puts "Setting the template language to use haml".yellow
  gsub_file 'config/application.rb', /g.template_engine\s{5}:erb/ do
<<-RUBY
g.template_engine     :haml
RUBY
  end
  
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
else
  apply temple.join('layouts/application.rb')
  apply temple.join('layouts/include_javascripts.rb')
end


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
puts "Checking our changes into git.".green
git :add    => '.'
git :commit => "-am 'first commit!'"

puts "Abbey has setup everything for you.".green
