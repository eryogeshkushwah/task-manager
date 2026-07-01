class TasksQuery
  attr_reader :relation, :params

  def initialize(relation = Task.all, params = {})
    @relation = relation
    @params = params
  end

  def results
    @results ||= paginate(sorted_scope)
  end

  def total_count
    @total_count ||= filtered_scope.count
  end

  def total_pages
    (total_count.to_f / per_page).ceil
  end

  def current_page
    [params[:page].to_i, 1].max
  end

  def per_page
    p = params[:per_page].present? ? params[:per_page].to_i : 20
    [[p, 1].max, 100].min
  end

  def pagination_metadata
    {
      current_page: current_page,
      per_page: per_page,
      total_count: total_count,
      total_pages: total_pages
    }
  end

  private

  def filtered_scope
    @filtered_scope ||= begin
      scope = relation
      scope = filter_by_project(scope)
      scope = filter_by_assigned_user(scope)
      scope = filter_by_status(scope)
      scope = filter_by_priority(scope)
      scope = filter_by_due_date(scope)
      scope = search(scope)
      scope
    end
  end

  def sorted_scope
    sort(filtered_scope)
  end

  def filter_by_project(scope)
    return scope if params[:project_id].blank?
    scope.where(project_id: params[:project_id])
  end

  def filter_by_assigned_user(scope)
    return scope if params[:assigned_user_id].blank?
    if params[:assigned_user_id] == 'unassigned'
      scope.where(assigned_user_id: nil)
    else
      scope.where(assigned_user_id: params[:assigned_user_id])
    end
  end

  def filter_by_status(scope)
    return scope if params[:status].blank?
    scope.where(status: params[:status])
  end

  def filter_by_priority(scope)
    return scope if params[:priority].blank?
    scope.where(priority: params[:priority])
  end

  def filter_by_due_date(scope)
    return scope if params[:due_date].blank?
    scope.where(due_date: params[:due_date])
  end

  def search(scope)
    return scope if params[:search].blank?
    query = "%#{params[:search]}%"
    scope.where("title ILIKE :q OR description ILIKE :q", q: query)
  end

  def sort(scope)
    sort_by = params[:sort_by] || 'created_at'
    sort_dir = params[:sort_dir] || 'desc'

    allowed_sort_fields = %w[title status priority due_date completed_at created_at updated_at]
    allowed_sort_directions = %w[asc desc]

    sort_by = 'created_at' unless allowed_sort_fields.include?(sort_by.to_s.downcase)
    sort_dir = 'desc' unless allowed_sort_directions.include?(sort_dir.to_s.downcase)

    scope.order("#{sort_by} #{sort_dir}")
  end

  def paginate(scope)
    scope.limit(per_page).offset((current_page - 1) * per_page)
  end
end
