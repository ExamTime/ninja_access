class CreateResourceCs < ActiveRecord::Migration[4.2]
  def change
    create_table :resource_cs do |t|
      t.string :name

      t.timestamps
    end
  end
end
