class MealPlansController < ApplicationController
  include Authentication

  def generate
    patient = Patient.find(params[:patient_id])
    job_id = MealPlanWorker.perform_async(
      patient.id,
      params[:period_days] || 7,
      params[:target_calories] || 2000,
      params[:target_protein] || 50,
      patient.dietary_restrictions || []

    )

    render json: {
      message: "Meal plan geneation started",
      job_id: job_id
    }, status: :accepted
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Patient not found" }, status: :not_found
  rescue => e
    render json: { error: "Failed to generate meal plan: #{e.message}" }, status: :unprocessable_content
  end

  def status
    job_id = params[:job_id]
    if job_id.nil?
      render json: { error: "Job ID is required" }, status: :bad_request
      return
    end
    if Sidekiq::Status.working?(job_id)
      render json: { status: "processing", job_id: job_id }
    elsif Sidekiq::Status.complete?(job_id)
      render json: { status: "completed", job_id: job_id }
    elsif Sidekiq::Status.failed?(job_id)
      render json: { status: "failed", job_id: job_id }
    else
      render json: { status: "not_found", job_id: job_id }, status: :not_found
    end
  end

  private

  def call_meal_planner_lambda(payload)
    puts "DEBUG: LAMBDA_ACCESS_KEY_ID = #{ENV['LAMBDA_ACCESS_KEY_ID']}"
    puts "DEBUG: LAMBDA_REGION = #{ENV['LAMBDA_REGION']}"
    puts "DEBUG: Function name = meal-planner-basic"
    puts "DEBUG: Payload = #{payload.to_json}"
    lambda_client = Aws::Lambda::Client.new(
      region: ENV["LAMBDA_REGION"],
      access_key_id: ENV["LAMBDA_ACCESS_KEY_ID"],
      secret_access_key: ENV["LAMBDA_SECRET_ACCESS_KEY"]
    )

    resp = lambda_client.invoke({
      function_name: "meal-planner-basic",
      payload: payload.to_json
    })

    JSON.parse(resp.payload.read)
  end
end
