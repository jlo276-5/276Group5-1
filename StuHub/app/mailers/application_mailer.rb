class ApplicationMailer < ActionMailer::Base
  default from: ENV["MAILER_ADDRESS"] || "noreply@example.com"
  layout 'mailer'
end
