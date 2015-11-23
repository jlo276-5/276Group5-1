class UpdateTerm < ActiveJob::Base
  queue_as :default

  require 'net/http'
  require 'dullard'

  def perform(term)
    term.update_from_database
  end
end
