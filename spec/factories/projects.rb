FactoryBot.define do
  factory :project do
    description { "Learn Rspec"}
    name { "Rspec" }
    association :user
  end
end