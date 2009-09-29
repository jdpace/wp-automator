ActionController::Routing::Routes.draw do |map|
  map.resources :sites, :member => {:deploy => :put, :log => :get}
  map.root      :controller => :sites
end
