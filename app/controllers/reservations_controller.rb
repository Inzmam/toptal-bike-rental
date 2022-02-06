class ReservationsController < ApplicationController

  def index
    if params[:user_id].present?
      @reservations = Reservation.where(user_id: params[:user_id])
    else
      @reservations = Reservation.all
    end
  end

  def update
    @reservation = Reservation.find(params[:id])

    if @reservation.update(rating: params[:reservation][:rating])
      current_bike_reservations_ratings = Reservation.where(bike_id: @reservation.bike.id, status: 'Old').pluck(:rating)
      bike_avg_rating = (current_bike_reservations_ratings.sum)/current_bike_reservations_ratings.size
      @reservation.bike.update(rating: bike_avg_rating)

      render json: { bike: @reservation, message: "Reservation Updated Successfully" }, status: 200
    else
      render json: { message: 'Something Went Wrong' }, status: 500
    end
  end

  def destroy
    @reservation = Reservation.find_by_id(params[:id])

    if @reservation.destroy
      render json: { message: "#{@reservation.role} Deleted Successfully" }, status: 200
    else
      render json: { message: 'Something Went Wrong' }, status: 500
    end
  end

end
