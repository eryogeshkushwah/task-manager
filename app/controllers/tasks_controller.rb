class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task, only: [:show, :update, :destroy, :complete, :change_status]

  # GET /tasks
  def index
    # Scope tasks to projects owned by the current user
    project_ids = current_user.projects.pluck(:id)
    scope = Task.where(project_id: project_ids)

    # Use Query Object for search, filter, sort, and pagination
    query = TasksQuery.new(scope, params)

    render json: {
      tasks: query.results.as_json(include: {
        project: { only: [:id, :name] },
        assigned_user: { only: [:id, :name, :email] }
      }),
      meta: query.pagination_metadata
    }
  end

  # GET /tasks/:id
  def show
    render json: @task.as_json(include: {
      project: { only: [:id, :name] },
      assigned_user: { only: [:id, :name, :email] }
    })
  end

  # POST /tasks
  def create
    # Ensure project_id is provided and owned by the current user
    project = current_user.projects.find(task_params[:project_id])
    @task = project.tasks.build(task_params)

    if @task.save
      render json: @task, status: :created
    else
      render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /tasks/:id
  def update
    # If changing the project, ensure the new project is owned by the current user
    if task_params[:project_id].present? && task_params[:project_id].to_i != @task.project_id
      current_user.projects.find(task_params[:project_id])
    end

    if @task.update(task_params)
      render json: @task
    else
      render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /tasks/:id
  def destroy
    @task.destroy
    render json: { message: "Task deleted successfully." }, status: :ok
  end

  # PATCH/PUT /tasks/:id/complete
  def complete
    if @task.completed!
      render json: { message: "Task marked as completed.", task: @task }
    else
      render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /tasks/:id/status
  def change_status
    status = params[:status]
    if Task.statuses.key?(status)
      if @task.update(status: status)
        render json: { message: "Task status updated successfully.", task: @task }
      else
        render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { errors: ["Invalid status. Allowed values are: #{Task.statuses.keys.join(', ')}"] }, status: :bad_request
    end
  end

  private

  def set_task
    # Restrict task lookups to projects owned by the current user
    project_ids = current_user.projects.pluck(:id)
    @task = Task.where(project_id: project_ids).find(params[:id])
  end

  def task_params
    params.require(:task).permit(
      :title,
      :description,
      :status,
      :priority,
      :due_date,
      :project_id,
      :assigned_user_id
    )
  end
end
