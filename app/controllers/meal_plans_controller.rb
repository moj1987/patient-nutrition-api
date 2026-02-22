class MealPlansController < ApplicationController
  include Authentication

  def generate
    patient = Patient.find(params[:patient_id])

    # Prepare payload for Lambda
    payload = {
      patient_id: patient.id,
      period_days: params[:period_days] || 7,
      target_calories: params[:target_calories] || 2000,
      target_protein: params[:target_protein] || 50,
      dietary_restrictions: patient.dietary_restrictions || []
    }

    # Call Lambda function
    lambda_response = call_meal_planner_lambda(payload)

    render json: lambda_response
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Patient not found" }, status: :not_found
  rescue => e
    render json: { error: "Failed to generate meal plan: #{e.message}" }, status: :unprocessable_content
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
