class CreateResourceAs < ActiveRecord::Migration[4.2]
  def change
    create_table :resource_as do |t|
      t.string :name

      t.timestamps
    end
  end
end
