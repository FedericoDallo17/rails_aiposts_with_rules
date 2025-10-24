# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require "faker"

puts "🧹 Limpiando base de datos..."
Notification.destroy_all
Like.destroy_all
Comment.destroy_all
Follow.destroy_all
Post.destroy_all
User.destroy_all

puts "👥 Creando usuarios..."
users = []

# Usuario principal para pruebas
main_user = User.create!(
  username: "johndoe",
  email: "john@example.com",
  password: "password123",
  password_confirmation: "password123",
  first_name: "John",
  last_name: "Doe",
  bio: "Software developer and tech enthusiast 🚀",
  website: "https://johndoe.com",
  location: "San Francisco, CA"
)
users << main_user
puts "  ✓ Usuario principal: #{main_user.username}"

# Crear 20 usuarios adicionales
20.times do
  user = User.create!(
    username: Faker::Internet.unique.username(specifier: 3..15, separators: ["_"]),
    email: Faker::Internet.unique.email,
    password: "password123",
    password_confirmation: "password123",
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    bio: Faker::Lorem.sentence(word_count: 10),
    website: [Faker::Internet.url, nil].sample,
    location: [Faker::Address.city, nil].sample
  )
  users << user
end
puts "  ✓ #{users.count} usuarios creados"

puts "\n🔗 Creando relaciones de seguimiento..."
# Crear follows (cada usuario sigue entre 5 y 15 otros usuarios)
users.each do |user|
  other_users = (users - [user]).sample(rand(5..15))
  other_users.each do |followed_user|
    Follow.create!(follower: user, followed: followed_user)
  rescue ActiveRecord::RecordInvalid
    # Skip duplicates
  end
end
puts "  ✓ #{Follow.count} relaciones de seguimiento creadas"

puts "\n📝 Creando posts..."
posts = []
users.each do |user|
  # Cada usuario crea entre 3 y 10 posts
  rand(3..10).times do
    content = Faker::Lorem.paragraph(sentence_count: rand(2..5))

    # Agregar algunos hashtags aleatorios
    if rand < 0.7
      hashtags = (1..rand(1..3)).map { "##{Faker::Lorem.word}" }
      content += " #{hashtags.join(" ")}"
    end

    # Agregar algunas menciones aleatorias
    if rand < 0.5
      mentioned_users = users.sample(rand(1..3))
      mentions = mentioned_users.map { |u| "@#{u.username}" }
      content += " #{mentions.join(" ")}"
    end

    post = user.posts.create!(content: content)
    posts << post
  end
end
puts "  ✓ #{posts.count} posts creados"

puts "\n❤️  Creando likes..."
# Cada usuario le da like a entre 10 y 30 posts aleatorios
users.each do |user|
  posts.sample(rand(10..30)).each do |post|
    Like.create!(user: user, post: post)
  rescue ActiveRecord::RecordInvalid
    # Skip if already liked
  end
end
puts "  ✓ #{Like.count} likes creados"

puts "\n💬 Creando comentarios..."
# Crear entre 2 y 5 comentarios por post
posts.each do |post|
  rand(2..5).times do
    commenter = users.sample
    content = Faker::Lorem.sentence(word_count: rand(5..20))

    # Agregar menciones ocasionales
    if rand < 0.3
      mentioned_users = users.sample(rand(1..2))
      mentions = mentioned_users.map { |u| "@#{u.username}" }
      content += " #{mentions.join(" ")}"
    end

    Comment.create!(
      user: commenter,
      post: post,
      content: content
    )
  end
end
puts "  ✓ #{Comment.count} comentarios creados"

puts "\n📊 Estadísticas finales:"
puts "  • Usuarios: #{User.count}"
puts "  • Posts: #{Post.count}"
puts "  • Comentarios: #{Comment.count}"
puts "  • Likes: #{Like.count}"
puts "  • Follows: #{Follow.count}"
puts "  • Notificaciones: #{Notification.count}"

puts "\n✨ Seeds completados exitosamente!"
puts "\n📝 Usuario de prueba:"
puts "  Email: john@example.com"
puts "  Password: password123"
puts "  Username: johndoe"
