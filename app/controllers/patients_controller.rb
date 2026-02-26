class PatientsController < ApplicationController
  include Authentication

  def index
    @patients = Patient.all
    render json: @patients
  end

  def show
    @patient = Patient.find(params[:id])
    render json: @patient
  end

  def create
    @patient = Patient.new(patient_params)
    if @patient.save
      render json: @patient, status: :created
    else
      render json: @patient.errors, status: :unprocessable_content
    end
  end

  def update
    @patient = Patient.find(params[:id])

    if @patient.update(patient_params)
      render json: @patient, status: :ok
    else
      render json: @patient.errors, status: :unprocessable_content
    end
  end

  def destroy
    @patient = Patient.find(params[:id])
    @patient.destroy
    head :no_content
  end

  private
  def patient_params
    params.require(:patient).permit(:name, :age, :room_number, :admition_date, :status, dietary_restrictions: [])
  end
end
