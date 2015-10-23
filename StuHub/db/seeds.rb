# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create!(name:  "Administrator",
             email: "example@railstutorial.org",
             password: "adminuser",
             password_confirmation: "adminuser",
             role: 2,
             activated: true,
             activated_at: Time.zone.now)
