class CreateNinjaAccessPermissions < ActiveRecord::Migration
  def change
    create_table :ninja_access_permissions do |t|
      t.string :action, :null => false
      t.references :accessible, :polymorphic => true
      t.timestamps
    end
    add_index :ninja_access_permissions,
              [:accessible_id, :accessible_type, :action],
              :unique => true,
              :name => "index_na_permissions_on_accessible_and_action"

    create_table :ninja_access_groups_permissions do |t|
      t.column "group_id", :integer
      t.column "permission_id", :integer
    end
    add_index :ninja_access_groups_permissions,
              [:group_id, :permission_id],
              :unique => true,
              :name => "index_na_groups_permissions_on_group_id_and_permission_id"
    add_foreign_key :ninja_access_groups_permissions,
                    :ninja_access_groups,
                    :column => :group_id
    add_foreign_key :ninja_access_groups_permissions,
                    :ninja_access_permissions,
                    :column => :permission_id
  end

  def self.down
    drop_table :ninja_access_groups_permissions
    drop_table :ninja_access_permissions
  end
end
