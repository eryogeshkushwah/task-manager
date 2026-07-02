FactoryBot.define do
  factory :task do
    association :project

    assigned_user { nil }

    title { "Learn RSpec" }
    status { :pending }
    priority { :medium }
    completed_at { nil }
  end
end