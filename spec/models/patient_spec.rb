require 'rails_helper'

RSpec.describe Patient, type: :model do
  it "is valid with valid attributes" do
    patient = Patient.new(name: "Jane Doe", age: 80, room_number: "202A", status: 'active', dietary_restrictions: [ "gluten", "vegetarian" ])
    expect(patient).to be_valid
  end

  it "is not valid without a name" do
    patient = Patient.new(age: 80, room_number: "202A", status: 'active')
    expect(patient).to_not be_valid
  end

  it "is not valid without an age" do
    patient = Patient.new(name: "Jane Doe", room_number: "202A", status: 'active')
    expect(patient).to_not be_valid
  end

  it "is not valid with a negative age" do
    patient = Patient.new(name: "Jane Doe", age: -1, room_number: "202A", status: 'active')
    expect(patient).to_not be_valid
  end

  it "is not valid with a non-integer age" do
    patient = Patient.new(name: "Jane Doe", age: 75.5, room_number: "202A", status: 'active')
    expect(patient).to_not be_valid
  end

  it "is not valid without a room_number" do
    patient = Patient.new(name: "Jane Doe", age: 80, status: 'active')
    expect(patient).to_not be_valid
  end

  it "is not valid without a status" do
    patient = Patient.new(name: "Jane Doe", age: 80, room_number: "202A")
    expect(patient).to_not be_valid
  end

  it "raises an ArgumentError for an invalid status" do
    expect { Patient.new(name: "Jane Doe", age: 80, room_number: "202A", status: 'invalid_status') }
    .to raise_error(ArgumentError)
  end

  it "rejects invalid dietary restrictions" do
    patient = Patient.new(name: "Jane Doe", age: 80, room_number: "202A", status: 'active', dietary_restrictions: [ "bread", "pasta" ])
    expect(patient).not_to be_valid
  end
end
