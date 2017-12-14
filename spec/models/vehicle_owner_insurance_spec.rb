require "rails_helper"

RSpec.describe VehicleOwnerInsurance, type: :model do
  it "calculates the days covered (only covered not charged for)" do
    vehicle_owner_insurance = VehicleOwnerInsurance.create(start_date: Date.today, end_date: Date.today + 7.days)
    expect(vehicle_owner_insurance.total_days_covered).to eq 8
  end

  it "calculates the total charge for a vehicle owner insurance (excludes any day charged for on the driver insurance for that vehicle)" do
    vehicle = Vehicle.create(vehicle_owner_insurance_daily_rate_pounds: 1.1)
    vehicle_owner_insurance = VehicleOwnerInsurance.create(start_date: Date.today, end_date: Date.today + 20.days, vehicle: vehicle)
    driver_insurance = DriverInsurance.create(start_date: Date.today, end_date: Date.today + 4.days, vehicle: vehicle)
    driver_insurance2 = DriverInsurance.create(start_date: Date.today + 10.days, end_date: Date.today + 15.days, vehicle: vehicle)

    expect(vehicle_owner_insurance.total_charge_pounds).to eq 13.2
  end

  it "calculates the total charges for the owner using the version2 calculations" do
    # Version 2 of the vehicle owner pricing has been devised
    # On any day when the number of vehicles (per owner) on cover (whether they are charged for or not) is 3 or more the price per vehicle
    # increases by 10%. Eg 3 vehicle charged for for 3 days at a standard rate of £1 per vehicle will cost £9.90

    owner = Partner.create

    vehicle1 = Vehicle.create(vehicle_owner_insurance_daily_rate_pounds: 1.0, owner: owner)
    vehicle2 = Vehicle.create(vehicle_owner_insurance_daily_rate_pounds: 1.0, owner: owner)
    vehicle3 = Vehicle.create(vehicle_owner_insurance_daily_rate_pounds: 1.0, owner: owner)
    vehicle4 = Vehicle.create(vehicle_owner_insurance_daily_rate_pounds: 1.0, owner: owner)

    vehicle_owner_insurance1 = VehicleOwnerInsurance.create(start_date: Date.today, end_date: Date.today + 7.days, vehicle: vehicle1)
    vehicle_owner_insurance2 = VehicleOwnerInsurance.create(start_date: Date.today + 3.days, end_date: Date.today + 4.days, vehicle: vehicle2)
    vehicle_owner_insurance3 = VehicleOwnerInsurance.create(start_date: Date.today + 3.days, end_date: Date.today + 7.days, vehicle: vehicle3)
    vehicle_owner_insurance4 = VehicleOwnerInsurance.create(start_date: Date.today, end_date: Date.today + 15.days, vehicle: vehicle4)

    driver_insurance = DriverInsurance.create(start_date: Date.today, end_date: Date.today + 11.days, vehicle: vehicle1)
    driver_insurance2 = DriverInsurance.create(start_date: Date.today, end_date: Date.today + 5.days, vehicle: vehicle4)
    # Vehicle Owner Insurance 1 has no charges as all days are charged for on the driver insurance
    # Vehicle Owner Insurance 2 is charged for 2 days at the higher +10% rate
    # Vehicle Owner Insurance 3 is charged for 5 days at the higher +10% rate

    expect(owner.total_vehicle_owner_insurance_v2_charges_pounds).to eq (2.0 * 1.1) + (5.0 * 1.1) + (11 * 1.1)
  end
end
