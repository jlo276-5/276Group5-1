class ApplicationMailer < ActionMailer::Base
  default from: ENV["MAILER_ADDRESS"] || "example@example.com"
  layout 'mailer'
end
