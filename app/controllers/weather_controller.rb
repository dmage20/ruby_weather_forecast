class WeatherController < ApplicationController
  def index
    @address = params[:address]
    if @address.present?
      begin
        @forecast = WeatherService.call(@address)
      rescue StandardError => e
        flash[:alert] = e.message
      end
    end
  end
end
