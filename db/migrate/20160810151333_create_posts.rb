class CreatePosts < ActiveRecord::Migration
	def change
		create_table :posts do |t|
			t.references :user, foreign_key: true
			t.string :name
			t.timestamps
		end
	end
end