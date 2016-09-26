require 'rubygems'
require 'bundler/setup'

require 'active_support/all'

# Load Sinatra Framework (with AR)
require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/contrib/all' # Requires cookies, among other things
require 'google_custom_search_api'
require 'net/http'
require 'json'
require 'pry' if development?

APP_ROOT = Pathname.new(File.expand_path('../../', __FILE__))
APP_NAME = APP_ROOT.basename.to_s

GOOGLE_API_KEY = "AIzaSyB9Z0xW7IphpZSX2dKH1dX-_Eq_UCRtqEE"
GOOGLE_SEARCH_CX = "012566321244451956668:l3l-v-ipxhg"

# Global Sinatra configuration
configure do
  set :root, APP_ROOT.to_path
  set :server, :puma

  enable :sessions
  set :session_secret, ENV['SESSION_KEY'] || 'lighthouselabssecret'

  set :views, File.join(Sinatra::Application.root, "app", "views")
end

# Development and Test Sinatra Configuration
configure :development, :test do
  require 'pry'
end

# Production Sinatra Configuration
configure :production do
  # NOOP
end

# Set up the database and models
require APP_ROOT.join('config', 'database')

# Load the routes / actions
require APP_ROOT.join('app', 'actions')
