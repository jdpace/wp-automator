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
  
  context 'GET /sites/new' do
    setup do
      @site = Site.new
      Site.expects(:new).returns(@site)
      get :new
    end
    
    should_assign_to(:site) { @site }
  end
  
  context 'POST /sites/new' do
    setup do
      @site = Factory.build(:site, :url => 'site')
      Site.expects(:new).returns(@site)
    end
    
    context 'sending valid data' do
      setup do
        @site.stubs(:save).returns(true)
        post :create, :site => @site.attributes
      end
      
      should_assign_to(:site) {@site}
      should_redirect_to('the site show page') { site_path(@site) }
    end
    
    context 'sending invalid data' do
      setup do
        @site.stubs(:save).returns(false)
        post :create, :site => @site.attributes
      end
      
      should_assign_to(:site) { @site }
      should_render_template :new
    end
  end
  
  context 'GET /sites/:url' do
    setup do
      @site = Factory.build(:site, :url => 'site')
      Site.expects(:find_by_url!).with(@site.url).returns(@site)
    end
    
    %w(pending deploying complete).each do |state|
      context "when the site is #{state}" do
        setup do
          @site.state = state
          get :show, :id => @site.to_param
        end
      
        should_assign_to(:site) {@site}
        should_render_template :"show_#{state}"
      end
    end
  end
  
end
