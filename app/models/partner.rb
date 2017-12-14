# A Partner can be either a Driver or an Owner

class Partner < ActiveRecord::Base
  has_many :driver_insurances, foreign_key: "driver_id"
  has_many :owned_vehicles, class_name: "Vehicle", foreign_key: "owner_id"

  def total_days_charged_for_all_driver_insurance_policies
  	driver_insurances = DriverInsurance.where("driver_id = ?", self.id)
  	total = 0
  	driver_insurances.each do |driver_insurance|
  		total += (driver_insurance.end_date - driver_insurance.start_date).to_i
  	end
  	return total
 	end

 	# Removed this because functionality moved to Partner, but keeping commented version here to show prior changes made
=begin
	def self.driver_insurance_p(driver_insurance)
  	vehicle = Vehicle.find(driver_insurance.vehicle_id)
  	(driver_insurance.end_date - driver_insurance.start_date).to_f * vehicle.driver_insurance_daily_rate_pounds
  end
=end

	def total_driver_insurance_price
		driver_insurances = DriverInsurance.where("driver_id = ?", self.id)
  	total = 0
  	driver_insurances.each do |driver_insurance|
  		total += driver_insurance.total_price
  	end
  	return total
	end

  def total_vehicle_owner_insurance_v2_charges_pounds
  	vehicles = Vehicle.where("owner_id = ?", self.id)
  	vehicle_owner_insurances = []
  	vehicles.each do |vehicle|
  		vehicle_owner_insurances += VehicleOwnerInsurance.where("vehicle_id = ?", vehicle.id)
  	end
  	total = 0
  	if vehicles.length >= 3
  		vehicle_owner_insurances.each do |vehicle_owner_insurance|
  			total += (vehicle_owner_insurance.total_charge_pounds * 1.1)
  		end
  	else
  		vehicle_owner_insurances.each do |vehicle_owner_insurance|
  			total += vehicle_owner_insurance.total_charge_pounds
  		end
  	end

  	return total
  end
end
