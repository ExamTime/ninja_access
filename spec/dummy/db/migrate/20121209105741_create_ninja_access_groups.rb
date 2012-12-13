class CreateNinjaAccessGroups < ActiveRecord::Migration
  def change
    create_table :ninja_access_groups do |t|
      t.column "name", :string, :limit => 255
   #   t.column "school_id", :integer
      t.timestamps
    end
=begin
    add_index :ninja_access_groups, [:school_id, :name], :unique => true
    add_foreign_key :ninja_access_groups,
                    :schools
=end

    create_table :ninja_access_groups_users do |t|
      t.column "group_id", :integer
      t.column "user_id", :integer
    end
    add_foreign_key :ninja_access_groups_users,
                    :ninja_access_groups,
                    :column => :group_id
    add_foreign_key :ninja_access_groups_users,
                    :users
  end
end
