class CreateBikes < ActiveRecord::Migration[6.1]
  def change
    create_table :bikes do |t|
      t.string :model
      t.string :color
      t.string :location
      t.decimal :rating, default: 0.0
      t.boolean :is_available, default: false

      t.timestamps
    end
  end
end
