class CreateNinjaAccessSubGroups < ActiveRecord::Migration
  def self.up
    create_table :ninja_access_sub_groups do |t|
      t.integer :parent_id, :null => false
      t.integer :child_id, :null => false

      t.timestamps
    end
    add_foreign_key :ninja_access_sub_groups,
                    :ninja_access_groups,
                    :column => :parent_id,
                    :name => "ninja_access_sub_groups_parent_id_fk"
    add_foreign_key :ninja_access_sub_groups,
                    :ninja_access_groups,
                    :column => :child_id,
                    :name => "ninja_access_sub_groups_child_id_fk"
    add_index :ninja_access_sub_groups,
              [:parent_id, :child_id],
              :unique => true
  end

  def self.down
    drop_table :ninja_access_sub_groups
  end
end
