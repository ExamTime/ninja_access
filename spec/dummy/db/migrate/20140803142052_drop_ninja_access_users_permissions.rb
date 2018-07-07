class DropNinjaAccessUsersPermissions < ActiveRecord::Migration
  def self.up
    drop_table :ninja_access_users_permissions
  end

  def self.down
    create_table :ninja_access_users_permissions do |t|
      t.column "user_id", :integer
      t.column "permission_id", :integer
    end
    add_index :ninja_access_users_permissions,
              [:user_id, :permission_id],
              :unique => true,
              :name => "index_na_users_permissions_on_user_id_and_permission_id"
    add_foreign_key :ninja_access_users_permissions,
                    :users
    add_foreign_key :ninja_access_users_permissions,
                    :ninja_access_permissions,
                    :column => :permission_id
  end
end
