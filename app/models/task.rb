class Task < ApplicationRecord
  belongs_to :project
  belongs_to :assigned_user, class_name: "User", optional: true

  # Enums using string values for PostgreSQL readability and compatibility
  enum :status, { pending: "pending", in_progress: "in_progress", completed: "completed" }, default: "pending"
  enum :priority, { low: "low", medium: "medium", high: "high" }, default: "medium"

  # Validations
  validates :title, presence: true
  validates :status, presence: true, inclusion: { in: statuses.keys }
  validates :priority, presence: true, inclusion: { in: priorities.keys }

  # Callbacks to manage completed_at based on status changes
  before_save :manage_completed_at, if: :status_changed?

  private

  def manage_completed_at
    if completed?
      self.completed_at ||= Time.current
    else
      self.completed_at = nil
    end
  end
end
