ActionController::Routing::Routes.draw do |map|
  map.resources :sites, :member => {:deploy => :put}
  map.root      :controller => :sites
end
