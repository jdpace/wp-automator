class SitesController < ApplicationController
  
  def index
    @sites = Site.all
  end
  
  def show
    @site = Site.find_by_url!(params[:id])
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
  
end
