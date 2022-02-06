class BikesController < ApplicationController

  def index
    if @current_user.role == "Manager" || @current_user.role == "Admin"
      @bikes = Bike.all
    else
      @bikes = Bike.where(is_available: true)
    end

    render json: { bikes: @bikes }, status: 200
  end

  def show
    @bike = Bike.find_by(id: params[:id])

    if @bike.present?
      render json: { bike: @bike }, status: 200
    else
      render json: { message: 'Bike not found' }, status: 404
    end
  end

  def create
    @bike = Bike.new(bike_params)

    if @bike.save
      render json: { bike: @bike, message: "Bike Created Successfully" }, status: 200
    else
      render json: { message: 'Something Went Wrong' }, status: 500
    end
  end

  def update
    @bike = Bike.find(params[:id])

    if @bike.update(bike_params)
      render json: { bike: @bike, message: "Bike Updated Successfully" }, status: 200
    else
      render json: { message: 'Something Went Wrong' }, status: 500
    end
  end

  def destroy
    @bike = Bike.find_by_id(params[:id])

    if @bike.destroy
      render json: { message: "Bike Deleted Successfully" }, status: 200
    else
      render json: { message: 'Something Went Wrong' }, status: 500
    end
  end

  def search
    @bikes = []

    if params[:reservation_day].present?
      Bike.where(is_available: true).each do |single_bike|
        is_reserved = Reservation.where(bike_id: single_bike.id, reservation_day: params[:reservation_day])

        if is_reserved.present?
          # Bike has reservation for given date. Check if bike is reserved for complete day, then, do not return it
          # Otherwise, if it is available even for 1 hour, then, return it
          is_available = single_bike.get_available_slots(params[:reservation_day])
          if is_available.present?
            # Slots are available. Return it in array
            @bikes << single_bike
          end
        else
          @bikes << single_bike
        end
      end
    else
      # Other Search Filters

      @bikes << Bike.where("lower(model) like ?", "%#{params[:search][:model].downcase}%").pluck(:id) if params[:search][:model].present?
      @bikes << Bike.where("lower(color) like ?", "%#{params[:search][:color].downcase}%").pluck(:id) if params[:search][:color].present?
      @bikes << Bike.where("lower(location) like ?", "%#{params[:search][:location].downcase}%").pluck(:id) if params[:search][:location].present?
      @bikes << Bike.where("rating = ?", params[:search][:rating]).pluck(:id) if params[:search][:rating].present?

      @bikes = @bikes.flatten
      @bikes = @bikes.uniq
      if @current_user.role == "Manager" || @current_user.role == "Admin"
        @bikes = Bike.where(id: @bikes)
      else
        @bikes = Bike.where(id: @bikes, is_available: true)
      end
    end

    render json: { bikes: @bikes }, status: 200
  end

  def rent_bike
    is_available = true
    @reservation = params[:reservation]
    previous_reservations = Reservation.where(reservation_day: @reservation[:reservation_day], bike_id: params[:id])

    previous_reservations.each do |single_reservation|
      param_start_time = @reservation[:start_time].split(":")[0].to_i
      param_end_time = @reservation[:end_time].split(":")[0].to_i

      prev_reservation_start_time = single_reservation.start_time.strftime("%H").to_i
      prev_reservation_end_time = single_reservation.end_time.strftime("%H").to_i

      if ((param_start_time...param_end_time).cover? prev_reservation_start_time) || ((param_start_time + 1...param_end_time).cover? prev_reservation_end_time) || ((prev_reservation_start_time...prev_reservation_end_time).cover? param_start_time) || ((prev_reservation_start_time...prev_reservation_end_time).cover? param_end_time)
        is_available = false
      end
    end

    if is_available == false
      render json: { message: 'Slot Not Aavailable' }, status: 500
    else
      Reservation.create(user_id: @current_user.id, bike_id: params[:id], start_time: @reservation[:start_time], end_time: @reservation[:end_time], reservation_day: @reservation[:reservation_day])
      render json: { message: 'Reservation created successfully' }, status: 200
    end

  end

  private

  def bike_params
    params.require(:bike).permit(:model, :color, :location, :rating, :is_available)
  end

end
