class MealPlanWorker
  include Sidekiq::Worker

  def perform(patient_id, period_days, target_calories, target_protein, dietary_restrictions)
    # TODO call lambda

    puts "🔥 WORKER STARTED: patient_id=#{patient_id}"

    # Simple processing without status tracking
    sleep 3

    puts "🔥 WORKER FINISHED: patient_id=#{patient_id}"
    {
      patient_id: patient_id,
      period_days: period_days,
      generated_at: Time.current,
      status: "completed"
    }
  end
end
