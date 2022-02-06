json.reservations @reservations do |single_reservation|
  bike = Bike.find(single_reservation.bike_id)

  json.id single_reservation.id
  json.model bike.model
  json.color bike.color
  json.location bike.location
  json.start_time single_reservation.start_time.strftime('%I:00 %p')
  json.end_time single_reservation.end_time.strftime('%I:00 %p')
  json.reservation_day single_reservation.reservation_day.strftime('%b %d, %Y')
  json.rating single_reservation.rating

  if Time.now.strftime("%Y-%m-%d") < single_reservation.reservation_day.strftime("%Y-%m-%d")
    # Current Date is behind the reservation date. Reservation date is in the future
    json.reservation_type 'Current'
    single_reservation.update(status: 'Current')
  elsif Time.now.strftime("%Y-%m-%d") == single_reservation.reservation_day.strftime("%Y-%m-%d")
    # Reservation date is for today. Check if reservation start time has started or not
    if Time.now.strftime("%H") < single_reservation.start_time.strftime("%H")
      json.reservation_type 'Current'
      single_reservation.update(status: 'Current')
    end
  end

  if single_reservation.reservation_day.strftime("%Y-%m-%d") < Time.now.strftime("%Y-%m-%d")
    # Reservation Date is behind the Current date. Reservation date is in the past
    json.reservation_type 'Old'
    single_reservation.update(status: 'Old')
  elsif Time.now.strftime("%Y-%m-%d") == single_reservation.reservation_day.strftime("%Y-%m-%d")
    # Reservation date is for today
    # Check if reservation start time has started or not
    if Time.now.strftime("%H").to_i >= single_reservation.start_time.strftime("%H").to_i
      json.reservation_type 'Old'
      single_reservation.update(status: 'Old')
    end
  end
end
