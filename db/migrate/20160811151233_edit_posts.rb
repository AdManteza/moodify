class EditPosts < ActiveRecord::Migration
	def change
		remove_column :posts, :name
		add_column :posts, :tagged_user_id, :integer
		add_column :posts, :url_one, :string 
		add_column :posts, :url_two, :string
		add_column :posts, :url_three, :string
		add_column :posts, :url_four, :string
	end
end