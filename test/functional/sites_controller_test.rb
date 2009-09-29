require 'test_helper'

class SitesControllerTest < ActionController::TestCase
  
  context 'GET /sites' do
    setup do
      @sites = []
      3.times {|n| Factory.build(:site)}
      Site.expects(:all).returns(@sites)
      get :index
    end
    
    should_assign_to(:sites) { @sites }
  end
  
end
