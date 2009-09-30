class SitesController < ApplicationController
  before_filter :find_site, :only => [:show, :deploy, :log]
  
  def index
    @sites = Site.all
  end
  
  def show
    render :"show_#{@site.state}"
  end
  
  def new
    @site = Site.new
  end
  
  def create
    @site = Site.new(params[:site])
    
    if @site.save
      redirect_to site_path(@site)
    else
      render :new
    end
  end
  
  def deploy
    @site.deploy!
    redirect_to site_path(@site) 
  end
  
  def log
    if File.exists?(@site.log_file)
      render :text => `tail -n 2000 #{@site.log_file}`, :content_type => 'text/plain', :status => (@site.complete? ? :ok : :partial_content)
    else
      render :nothing => true
    end
  end
    
  
  protected
  
    def find_site
      @site = Site.find_by_url!(params[:id])
    end
    
end
