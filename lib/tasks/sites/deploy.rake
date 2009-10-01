require 'active_support'
require 'action_view'
include ActionView::Helpers::NumberHelper

namespace :sites do
  
  desc 'Deploy a given WordPress site'
  task :deploy do
    Rake::Task['sites:deploy:stack'].invoke
  end
  
  namespace :deploy do
    
    desc 'Run the entire deploy stack'
    task :stack => [
      :clear_log,
      :download_wordpress,
      :extract_wordpress,
      :create_config,
      :create_database,
      :create_virtual_host,
      :restart_apache,
      :install_wordpress,
      :complete_site,
      :close_log
    ]
    
    desc 'Clear the log file we will be using'
    task :clear_log => :environment do
      clear_log
    end
    
    desc 'Download the latest version of WordPress to tmp/latest.zip'
    task :download_wordpress => :environment do
      logger.info "Downloading WordPress from #{App.wordpress[:package]}"
      curb = Curl::Easy.download(App.wordpress[:package], downloaded_package_path)
      logger.info ">> Finished downloading #{number_to_human_size curb.downloaded_bytes} at an average of #{number_to_human_size curb.download_speed}/S"
    end
    
    desc 'Extract WordPress to the install directory'
    task :extract_wordpress => :environment do
      logger.info "Extracting #{downloaded_package_path} to #{site.install_path}"
      output = `unzip -o #{downloaded_package_path} -d #{site.install_path}`
      output.split("\n").each {|line| logger.info ERB::Util.html_escape(">> #{line}")}
    end
    
    desc 'Create a WordPress Config file'
    task :create_config => :environment do
      logger.info "Generating config file: #{File.join(site.install_path,'wordpress','wp-config.php')}"
      File.open(File.join(site.install_path,'wordpress','wp-config-sample.php')) do |sample|
        File.open(File.join(site.install_path,'wordpress','wp-config.php'), 'w') do |config|
          sample.each_line do |line|
            updated = update_config(line)
            logger.info ">> #{ERB::Util.html_escape updated}"
            config.puts updated
          end
        end
      end
    end
    
    desc 'Create a database and a user for the WordPress install'
    task :create_database => :environment do
      begin
        logger.info "Setting up database for WordPress"
        logger.info ">> creating mysql database '#{site.database}'"
        ActiveRecord::Base.connection.create_database(site.database)
        logger.info ">> creating mysql user '#{site.database}' on database"
        create_user_sql = <<-SQL
          GRANT ALL PRIVILEGES 
          ON #{site.database}.* 
          TO '#{site.database}'@'localhost'
          IDENTIFIED BY '#{site.token}' 
          WITH GRANT OPTION;
        SQL
        ActiveRecord::Base.connection.execute(create_user_sql)
      rescue
        logger.error "!! #{$!}"
      end
    end
    
    desc 'Create an Apache Virtual Host'
    task :create_virtual_host => :environment do
      logger.info 'Creating Apache vhost'
      begin
        if File.exists?(App.server[:apache_root])
          unless File.exists?(available_dir = File.join(App.server[:apache_root], 'sites-available'))
            logger.info ">> mkdir #{available_dir}"
            FileUtils.mkdir(available_dir)
          end
          unless File.exists?(enabled_dir = File.join(App.server[:apache_root], 'sites-enabled'))
            logger.info ">> mkdir #{enabled_dir}"
            FileUtils.mkdir(enabled_dir)
          end
          
          erb = File.read(File.join(Rails.root,'app','views','sites','_vhost.erb'))
          vhost = ERB.new(erb).result
          logger.info ">> writing vhost to #{File.join(available_dir,site.url)}"
          vhost.split("\n").each {|line| logger.info ">> #{ERB::Util.html_escape line}"}
          File.open(File.join(available_dir,site.url),'w') {|f| f << vhost}
          
          logger.info ">> enabling vhost"
          FileUtils.ln_s File.join(available_dir,site.url), File.join(enabled_dir,site.url), :force => true
        else
          logger.error "!! Skipping Apache vhost - #{App.server[:apache_root]} doesn't exist"
        end
      rescue
        logger.error "!! #{$!}"
      end
    end
    
    desc 'Attempt to reload apache'
    task :reload_apache => :environment do
      logger.info 'Attempting to reload apache config'
      output = `#{App.server[:apache_reload]}`
      output.split("\n").each {|line| logger.info "<< #{line}"}
    end
    
    desc 'POST to the install script'
    task :install_wordpress => :environment do
      logger.info 'Attempting to install WordPress'
      begin
        target = "http://#{site.sub_domain}/wp-admin/install.php?step=2"
        logger.info "<< POSTing install info to #{target}"
        response = Curl::Easy.http_post(
          target,
          Curl::PostField.content('weblog_title', site.name),
          Curl::PostField.content('admin_email', App.wordpress[:admin_email]),
          Curl::PostField.content('blog_public', App.wordpress[:public])
        )
      rescue
        logger.info "!! #{$!}"
      end
    end
    
    desc 'Mark the site as complete'
    task :complete_site do
      logger.info "\n\nFinished"
      site.complete!
    end
    
    desc 'Close the log file'
    task :close_log do
      logger && logger.close
    end
    
  end
  
end

def clear_log
  system(":> #{site.log_file}") if site
end

def logger
  @logger ||= ActiveSupport::BufferedLogger.new(site.log_file) if site
end

def site
  if ENV['SITE_ID']
    @site ||= Site.find(ENV['SITE_ID'])
  end
end

def downloaded_package_path
  File.join(Rails.root, 'tmp', "wordpress.zip")
end

def update_config(line)
  case line
  when /DB_NAME/
    update_definition(line, site.database)
  when /DB_USER/
    update_definition(line, site.database)
  when /DB_PASSWORD/
    update_definition(line, site.token)
  when /AUTH_KEY/
    update_definition(line, ActiveSupport::SecureRandom.base64(20))
  when /SECURE_AUTH_KEY/
    update_definition(line, ActiveSupport::SecureRandom.base64(20))
  when /LOGGED_IN_KEY/
    update_definition(line, ActiveSupport::SecureRandom.base64(20))
  when /NONCE_KEY/
    update_definition(line, ActiveSupport::SecureRandom.base64(20))
  else
    line
  end
end

def update_definition(line, new_definition)
  line.gsub(/define\('(.+)', '(.+)'\);/, 'define(\'\1\', \''+new_definition+'\');')
end