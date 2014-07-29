ActiveRecord::Base.connection.execute 'CREATE EXTENSION IF NOT EXISTS "citext"'
ActiveRecord::Base.connection.change_column :users, :username, :citext, unique: true, index:true
ActiveRecord::Base.connection.change_column :users, :email, :citext, unique: true, index:true