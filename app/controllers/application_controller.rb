# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  before_filter :authenticate

  protected
  
     def authenticate
       authenticate_or_request_with_http_basic('Enventys Wordpress Admin') do |username, password|
         username == App.authentication[:username] && password == App.authentication[:password]
       end
     end
end
