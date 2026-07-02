FactoryBot.define do
  factory :user do
    name { "John" }
    email { Faker::Internet.unique.email }
    password { "password123" }
  end
end
