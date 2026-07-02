class Task < ApplicationRecord
  belongs_to :project
  belongs_to :assigned_user, class_name: "User", optional: true

  enum :status,
       {
         pending: "pending",
         in_progress: "in_progress",
         completed: "completed"
       },
       default: :pending

  enum :priority,
       {
         low: "low",
         medium: "medium",
         high: "high"
       },
       default: :medium

  validates :title, presence: true

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