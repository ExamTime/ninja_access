class CreateResourceBs < ActiveRecord::Migration
  def change
    create_table :resource_bs do |t|
      t.string :name

      t.timestamps
    end
  end
end
