use Rack::MethodOverride

enable :sessions

DEFAULT_SEARCH_QUERIES = ["dog", "cat", "bear", "parrot", "dragon", "bird", "eagle", "beer", "leeroy_jenkins"]

words = {
afraid: "brave",
playful: "dancing",
hopeful: "dancing",
loving: "dancing",
joyful: "dancing",
energetic: "dancing",
important: "dancing", 
confident: "dancing",
optimistic: "dancing",
powerful: "dancing",
proud: "dancing",
respected: "dancing",
sarcastic: "dancing",
happy: "dancing",
rejected: "happy",
inferior: "happy",
inadequate: "happy",
anxious: "happy",
depressed: "happy",
apathetic: "happy",
sad: "happy",
scared: "happy",
frightened: "happy",
shocked: "happy",
horrified: "happy",
startled: "happy",
terrified: "happy",
threatened: "happy",
victimized: "happy",
vulnerable: "happy",
withdrawn: "happy",
worried: "happy",
worthless: "happy",
judgemental: "happy",
lonely: "happy",
loathing: "happy",
isolated: "happy",
jealous: "happy",
irritated: "happy",
insignificant: "happy",
insecure: "happy",
infuriated: "happy",
hateful: "happy",
angry: "happy",
pissed: "happy",
furious: "happy",
hostile: "happy",
hurt: "happy",
ignored: "happy",
mad: "happy",
dull: "weird",
disamused: "weird",
bored: "weird",
empty: "weird",
trippy: "weird",
crazy: "weird"
}

helpers do
	def logged_in?
		!session[:id].nil?
	end

	def current_user
		if logged_in?
			@current_user = User.find_by(id: session[:id])
		end
	end
end

def result_limit(mode)
  if mode == "stickers"
    return 25 
  else
    return 25
  end
end

def search_by(mode, param1, param2)
  limit = result_limit(mode)

  url = "https://api.giphy.com/v1/#{mode}/search?q=#{param1}+#{param2}&api_key=dc6zaTOxFJmzC&limit=#{limit}&rating=pg-13"
  resp = Net::HTTP.get_response(URI.parse(url))
  buffer = resp.body
  JSON.parse(buffer)
end

def search_single_sticker(param1)
  param2 = " "
  url = "https://api.giphy.com/v1/stickers/search?q=#{param1}+#{param2}&api_key=dc6zaTOxFJmzC&limit=10"
  resp = Net::HTTP.get_response(URI.parse(url))
  buffer = resp.body
  JSON.parse(buffer)
end

get '/' do
 @classes = "full_page"
 @parallax_class = "parallax_class"
 erb :start
end

post '/' do
  if params[:switchbox] == "on"
    mode = "gifs"
  else
    mode = "stickers"
  end

  @classes = "full_page"
  @parallax_class = "parallax_class"
  	if words.include?(params[:name].to_sym)
  		mood1 = words[params[:name].to_sym]
  		if mood1 == "dancing"
  			mood2 = nil
  		elsif mood1 == "happy"
  			mood2 = params[:name]
  		elsif mood1 == "weird"
  			mood2 = params[:name]
  		end
  	else
  		mood1 = "cat"
  		mood2 = ["stupid", "clumsy", "sleepy", "cute", "excited", "angry", "fluffy"].sample
  	end
  @result = search_by(mode, mood1, mood2)
  erb :home, :locals => { :mood1 => mood1, :mood2 => mood2 }
end

post '/default' do
  erb :default #this will display when the public wall is refreshed 
end

get '/login' do
	@parallax_class = "parallax_class_other"
	@card_class = "card-small"
	if logged_in?
		redirect "/users/#{session[:id]}"
	else
		erb :'sessions/new'
	end
end

post '/login' do
	@user = User.find_by(name: params[:name].downcase)
	if @user && @user.authenticate(params[:password])
    session.delete(:login_error)
		session[:id] = @user.id
		redirect "/users/#{session[:id]}" #it should redirect to the users profile
	else
    session[:login_error] = "You are not who you say you are!!"
		redirect back
	end
end

get '/logout' do
	session[:id] = nil
	redirect '/'
end

get '/signup' do
	@parallax_class = "parallax_class_other"
	@card_class = "card-small"
	if logged_in?
		redirect "/users/#{session[:id]}"#it should redirect to the users profile
	else
		@user = User.new
		erb :'users/new'
	end
end

post '/signup' do
	@user = User.new(
		name: params[:name].downcase,
		password: params[:password]
	)

	if @user.save
    session.delete(:sign_up_error)
		session[:id] = @user.id
		redirect "/users/#{session[:id]}"
	else
    session[:sign_up_error] = "Your name is not as unique as you think!! Try another one!!!"
		redirect back
	end
end 

get '/users/:id' do
	@parallax_class = "parallax_class"
	@parallax_class = "parallax_class_other"
	@card_class = "card-small"
	@user = User.find params[:id]
  @friends = User.where.not(id: @user.id && current_user.id)
	@all_users = User.all
  @post = Post.where(tagged_user_id: @user.id)
	erb :'users/show'
end

post '/users/:id' do
  results = []
  parameters = [ params[:url_one], params[:url_two], params[:url_three], params[:url_four] ]
  
  parameters.each do |url|
    if search_single_sticker(url)["data"] == []
      results << search_single_sticker(DEFAULT_SEARCH_QUERIES.sample)
    else
      results << search_single_sticker(url)
    end
  end

	@post = Post.new(
		user_id: current_user.id,
		tagged_user_id: params[:tagged_user_id],
		url_one: results[0]["data"][rand(0..9)]["embed_url"],
		url_two: results[1]["data"][rand(0..9)]["embed_url"],
		url_three: results[2]["data"][rand(0..9)]["embed_url"],
		url_four: results[3]["data"][rand(0..9)]["embed_url"]
	)
	@post.save
	redirect back
end

delete '/delete/:id' do
  @post = Post.find params[:id]
  @post.destroy
  redirect "/users/#{session[:id]}"
end











