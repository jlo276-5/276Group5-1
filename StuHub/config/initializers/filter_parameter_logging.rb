# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [:password, :email, :dropbox_token, :dropbox_secret, :dropbox_uid, :cas_identifier]
