require 'faker'

puts "Cleaning database..."
Task.destroy_all
Project.destroy_all
User.destroy_all

puts "Creating users..."
users = []

# Create a demo user for easy manual testing
users << User.create!(
  name: "Demo User",
  email: "demo@example.com",
  password: "password",
  password_confirmation: "password"
)

9.times do
  users << User.create!(
    name: Faker::Name.name,
    email: Faker::Internet.unique.email,
    password: "password",
    password_confirmation: "password"
  )
end

puts "Creating projects..."
projects = []
20.times do
  projects << Project.create!(
    name: Faker::Company.bs.titleize,
    description: Faker::Lorem.paragraph(sentence_count: 3),
    user: users.sample
  )
end

puts "Creating tasks..."
200.times do
  status = Task.statuses.keys.sample
  priority = Task.priorities.keys.sample
  due_date = [Faker::Date.backward(days: 10), Faker::Date.forward(days: 30)].sample
  
  task = Task.new(
    title: Faker::Lorem.words(number: 3).join(" ").titleize,
    description: Faker::Lorem.paragraph(sentence_count: 2),
    status: status,
    priority: priority,
    due_date: due_date,
    project: projects.sample,
    assigned_user: [users.sample, nil].sample
  )

  # Override completion time if completed to simulate historical data
  if status == "completed"
    task.completed_at = Faker::Time.backward(days: 5)
  end

  task.save!
end

puts "Database seeded successfully!"
puts "Summary:"
puts "- Users: #{User.count}"
puts "- Projects: #{Project.count}"
puts "- Tasks: #{Task.count}"
