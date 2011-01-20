gsub_file 'config/environments/development.rb', /# Don't care if the mailer can't send/, '# Devise Mailer Setup'
gsub_file 'config/environments/development.rb', /config.action_mailer.raise_delivery_errors = false/ do
<<-RUBY
config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  # A dummy setup for development - no deliveries, but logged
  config.action_mailer.delivery_method        = :smtp
  config.action_mailer.perform_deliveries     = false
  config.action_mailer.raise_delivery_errors  = true
  config.action_mailer.default :charset => "utf-8"
RUBY
end

gsub_file 'config/environments/production.rb', /config.i18n.fallbacks = true/ do
<<-RUBY
config.i18n.fallbacks = true

  config.action_mailer.default_url_options = { :host => App::Project.domain }
  ### ActionMailer Config
  # Setup for production - deliveries, no errors raised
  config.action_mailer.delivery_method        = :smtp
  config.action_mailer.perform_deliveries     = true
  config.action_mailer.raise_delivery_errors  = false
  config.action_mailer.default :charset => "utf-8"
RUBY
end

gsub_file 'config/environments/test.rb', /# Don't care if the mailer can't send/, '# Devise Mailer Setup'
gsub_file 'config/environments/test.rb', /# Settings specified here will take precedence over those in config\/application.rb/ do
<<-RUBY
config.action_mailer.default_url_options = { :host => 'localhost:3000' }
RUBY
end