class CreateReservations < ActiveRecord::Migration[6.1]
  def change
    create_table :reservations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :bike, null: false, foreign_key: true
      t.time :start_time
      t.time :end_time
      t.date :reservation_day
      t.string :status
      t.decimal :rating, default: 0.0

      t.timestamps
    end
  end
end
