require 'test_helper'

class SiteTest < ActiveSupport::TestCase
  subject do
    Factory(:site)
  end
  
  should_act_as_url :name
  
  should_have_states :pending, :deploying, :complete
  
  should_validate_uniqueness_of :domain
  should_validate_presence_of   :name
  
  context 'A Site' do
    setup do
      @site = Factory(:site)
    end
    
    should 'generate a token' do
      assert_not_nil @site.token
    end
    
    should 'use the url as to_param' do
      assert_equal @site.url, @site.to_param
    end
    
    should 'know where to install at' do
      assert_equal "#{App.server[:sites_directory]}/#{@site.url}", @site.install_path
    end
    
    should 'know where it can be accessed' do
      assert_equal "#{@site.url}.#{App.server[:domain]}", @site.sub_domain
    end
    
    should 'know where to keep its log file' do
      assert_equal "#{Rails.root}/log/deploys/#{@site.url}.log", @site.log_file
    end
    
    context 'being deployed' do
      setup do
        @site.expects(:run_deploy_task).returns(true)
        @site.deploy!
      end
      
      should_change('the state', :to => 'deploying') { @site.state }
    end
  end
  
end
