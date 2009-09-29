require 'test_helper'

class SiteTest < ActiveSupport::TestCase
  subject do
    Factory(:site)
  end
  
  should_act_as_url :name
  
  should_validate_uniqueness_of :domain
  should_validate_presence_of   :name
  
  context 'Creating a Site' do
    setup do
      @site = Factory(:site)
    end
    
    should 'generate a token' do
      assert_not_nil @site.token
    end
  end
  
end
