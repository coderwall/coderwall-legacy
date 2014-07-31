class EnableCitextForUserUserName < ActiveRecord::Migration
  def up
    execute 'CREATE EXTENSION IF NOT EXISTS "citext"'
    change_column :users, :username, :citext, unique: true #, index:true
    change_column :users, :email, :citext, unique: true, index:true
  end
end
