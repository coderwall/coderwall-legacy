class EnableCitextForUserUserName < ActiveRecord::Migration
  def up
    execute 'CREATE EXTENSION IF NOT EXISTS "citext"'
    change_column :users, :username, :citext, index:true # , unique: true
    change_column :users, :email, :citext, index:true #, unique: true
  end
end
