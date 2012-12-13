class CreateResourceCs < ActiveRecord::Migration
  def change
    create_table :resource_cs do |t|
      t.string :name

      t.timestamps
    end
  end
end
