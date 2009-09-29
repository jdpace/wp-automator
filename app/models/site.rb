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
    transitions :from => :pending, :to => :deploying
  end
  
  aasm_event :complete do
    transitions :from => :deploying, :to => :complete
  end
  
  def to_param
    url
  end
  
  protected
  
    def generate_token
      self.token = ActiveSupport::SecureRandom.base64(10)
    end
end
