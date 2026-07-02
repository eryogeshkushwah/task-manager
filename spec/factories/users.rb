FactoryBot.define do 
  factory :user do
    email { "test@gmail.com" }
    name { "My name" }
    password { "123456"}
  end
end