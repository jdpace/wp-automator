class SitesController < ApplicationController
  
  def index
    @sites = Site.all
  end
  
  def new
    @site = Site.new
  end
  
end
