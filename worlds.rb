require "sinatra"
require "sinatra/content_for"
require "tilt/erubis"
require "sinatra/reloader"
also_reload "worlds_db"

require_relative "worlds_db"

configure do
  enable :sessions
  set :session_secret, 'b9ef0726ff440cf98862e243f7d4f5e5c67144ef2d4222c68885eeed89381232'
  set :erb, :escape_html => true
end

helpers do
  def alphabetize(list, &block)
    list.sort_by { |item| item[:name] }.each(&block)
  end
end

# Determine if new world has unique name
def unique_world_name?(name)
  @storage.all_worlds.none? { |world| world[:name].downcase == name.downcase }
end

# Create database interaction object
before do
  @storage = WorldsDatabase.new(logger)
end

after do
  @storage.disconnect
end

get "/" do
  redirect "/worlds"
end

# View list of worlds
get "/worlds" do
  @worlds = @storage.all_worlds
  erb :worlds, layout: :layout
end

# View create new worlds page
get "/worlds/new" do
  erb :new_world, layout: :layout
end

# Create a new world
post "/worlds/new" do
  name = params[:name].strip
  if unique_world_name?(name)
    @storage.new_world(params)
    session[:success] = "#{name} has been created!"
    redirect "/worlds"
  else
    session[:error] = "World name must be unique."
    erb :new_world, layout: :layout
  end
end

# View a world
get "/worlds/:id" do
  id = params[:id].to_i
  @world = @storage.world_by_id(id)[0]
  erb :world, layout: :layout
end

# View a world's character index
get "/worlds/:id/characters" do
  @world_id = params[:id].to_i
  @characters = @storage.characters_by_world_id(@world_id)
  erb :characters, layout: :layout
end

# View a page for a specific character
get "/worlds/:world_id/characters/:char_id" do
  @world_id = params[:world_id].to_i
  @char_id = params[:char_id].to_i
  @character = @storage.character_by_id(@char_id)[0]
  @events = @storage.character_events(@char_id)
  erb :character, layout: :layout
end

# View a world's place index
get "/worlds/:id/places" do
  @world_id = params[:id].to_i
  @places = @storage.places_by_world_id(@world_id)
end

# View a world's events index
get "/worlds/:id/events" do
  @world_id = params[:id].to_i
  @events = @storage.events_by_world_id(@world_id)
end