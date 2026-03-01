class MealPlanWorker
  include Sidekiq::Worker

  def perform(patient_id, period_days, target_calories, target_protein, dietary_restrictions)
    job_id = self.jid  # Get the current job ID
    puts "🔥 WORKER STARTED: job_id=#{job_id}, patient_id=#{patient_id}"

    # Prepare payload for Lambda
    payload = {
      patient_id: patient_id,
      period_days: period_days,
      target_calories: target_calories,
      target_protein: target_protein,
      dietary_restrictions: dietary_restrictions
    }

    # Call Lambda function
    lambda_response = call_meal_planner_lambda(payload)

      puts "🔥 WORKER FINISHED: job_id=#{job_id}, patient_id=#{patient_id}"

    {
      patient_id: patient_id,
      period_days: period_days,
      generated_at: Time.current,
      status: "completed",
      meal_plan: lambda_response
    }
  end

  private

  def call_meal_planner_lambda(payload)
    puts "🔥 CALLING LAMBDA with payload: #{payload.inspect}"
    lambda_client = Aws::Lambda::Client.new(
      region: ENV["LAMBDA_REGION"],
      access_key_id: ENV["LAMBDA_ACCESS_KEY_ID"],
      secret_access_key: ENV["LAMBDA_SECRET_ACCESS_KEY"]
    )

    resp = lambda_client.invoke({
      function_name: "meal-planner-basic",
      payload: payload.to_json
    })

    lambda_response = JSON.parse(resp.payload.read)
    puts "🔥 LAMBDA RESPONSE: #{lambda_response.inspect}"

    lambda_response
  rescue => e
    puts "🔥 LAMBDA ERROR: #{e.message}"
    puts "🔥 ERROR DETAILS: #{e.class} - #{e.backtrace.first(3).join(', ')}"
    raise e
  end
end
