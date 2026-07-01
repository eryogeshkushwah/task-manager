class DashboardController < ApplicationController
  before_action :authenticate_user!

  # GET /dashboard
  def show
    project_ids = current_user.projects.pluck(:id)
    tasks = Task.where(project_id: project_ids)

    render json: {
      total_projects: project_ids.count,
      total_tasks: tasks.count,
      pending_tasks: tasks.where(status: "pending").count,
      in_progress_tasks: tasks.where(status: "in_progress").count,
      completed_tasks: tasks.where(status: "completed").count
    }, status: :ok
  end
end
