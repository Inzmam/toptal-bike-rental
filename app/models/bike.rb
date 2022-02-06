class Bike < ApplicationRecord
  has_many :reservations, dependent: :destroy

  def get_available_slots(day_for_reservation)
    bike_reservations = Reservation.where(bike_id: self.id, reservation_day: day_for_reservation)
    temp_reservations = Array.new

    bike_reservations.each do |single_reservation|
      start_time = single_reservation.start_time.strftime("%H").to_i
      end_time = single_reservation.end_time.strftime("%H").to_i
      temp_reservations << (start_time..end_time).to_a
    end

    temp_reservations.flatten!
    available_slots = (0..23).to_a - temp_reservations

    available_slots
  end

end
