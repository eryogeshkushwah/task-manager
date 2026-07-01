class User < ApplicationRecord
  has_secure_password

  has_many :projects, dependent: :destroy
  has_many :assigned_tasks, class_name: "Task", foreign_key: "assigned_user_id", dependent: :nullify
  has_many :sessions, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, 
                    uniqueness: { case_sensitive: false }, 
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  def as_json(options = {})
    super(options.merge(except: [:password_digest]))
  end
end
