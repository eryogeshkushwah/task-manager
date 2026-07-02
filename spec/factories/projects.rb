FactoryBot.define do
  factory :project do
    association :user
    name { "Task Manager" }
  end
end