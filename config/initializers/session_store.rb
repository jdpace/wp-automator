# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_wp-automator_session',
  :secret      => '8097ca174dab1d1c168f9de7557025e310410f90482f7335abf58f2253ce5c5fc9b90b364ac236e86e1fc4eca5e4e35240eceb6b565abd9a2d0d6908b0c81bbd'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
