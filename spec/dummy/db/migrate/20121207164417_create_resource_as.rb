class CreateResourceAs < ActiveRecord::Migration
  def change
    create_table :resource_as do |t|
      t.string :name

      t.timestamps
    end
  end
end
