class Site < ActiveRecord::Base
  acts_as_url :name
  
  before_validation_on_create :generate_token
  
  validates_presence_of   :name
  validates_uniqueness_of :domain, :allow_blank => true
  
  def to_param
    url
  end
  
  protected
  
    def generate_token
      self.token = ActiveSupport::SecureRandom.base64(10)
    end
end
