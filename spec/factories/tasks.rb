FactoryBot.define do
  factory :task do
    title { "Learn Rspec"}
    due_date { Date.tomorrow}
    description {"Learning Rspec"}
    status {"pending"}
    priority {"medium"}
    association :project
    assigned_user { nil }
  end
end