# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Institution.create!(name: "Simon Fraser University",
                    city: "Burnaby",
                    state: "British Columbia",
                    country: "Canada",
                    email_constraint: "sfu.ca",
                    website: "http://www.sfu.ca",
                    uses_cas: true,
                    cas_endpoint: "https://cas.sfu.ca/cas")

User.create!(name:  "Superuser",
             email: "email@example.me",
             password: "superuser",
             password_confirmation: "superuser",
             role: 2,
             activated: true,
             activated_at: Time.zone.now)
