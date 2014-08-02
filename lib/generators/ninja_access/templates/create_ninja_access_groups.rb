class CreateNinjaAccessGroups < ActiveRecord::Migration
  def change
    create_table :ninja_access_groups do |t|
      t.column "name", :string, :limit => 255
      t.timestamps
    end

    create_table :ninja_access_groups_users do |t|
      t.column "group_id", :integer
      t.column "user_id", :integer
    end
    add_index :ninja_access_groups_users,
              [:group_id, :user_id],
              :unique => true,
              :name => "index_na_groups_users_on_group_id_and_user_id"
    add_foreign_key :ninja_access_groups_users,
                    :ninja_access_groups,
                    :column => :group_id
    add_foreign_key :ninja_access_groups_users,
                    :users
  end
end
