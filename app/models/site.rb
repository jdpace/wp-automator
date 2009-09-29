class Site < ActiveRecord::Base
  include AASM
  
  acts_as_url :name
  
  before_validation_on_create :generate_token
  
  validates_presence_of   :name
  validates_uniqueness_of :domain, :allow_blank => true
  
  aasm_column :state
  aasm_initial_state :pending
  aasm_state :pending
  aasm_state :deploying
  aasm_state :complete
  
  aasm_event :deploy do
    transitions :from => :pending, :to => :deploying, :guard => :run_deploy_task
  end
  
  aasm_event :complete do
    transitions :from => :deploying, :to => :complete
  end
  
  def to_param
    url
  end
  
  def install_path
    File.join(App.server[:sites_directory], self.url)
  end
  
  def sub_domain
    [self.url, App.server[:domain]].join('.')
  end
  
  def log_file
    File.join(Rails.root, 'log', 'deploys', "#{self.url}.log")
  end
  
  protected
  
    def generate_token
      self.token = ActiveSupport::SecureRandom.base64(10)
    end
    
    def run_deploy_task
      puts 'uh oh'
      options = {
        :rails_env  => Rails.env,
        :site_id    => self.id
      }
      args = options.map { |n, v| "#{n.to_s.upcase}='#{v}'" }
      system "#{App.server[:rake]} sites:deploy #{args.join(' ')} --trace 2>&1 >> #{self.log_file} &"
    end
  
    
end
