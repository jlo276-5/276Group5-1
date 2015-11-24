class UpdateTerm < ActiveJob::Base
  queue_as :default

  require 'net/http'
  require 'dullard'

  def perform(term)
    term.with_lock do
      term.update_from_database
    end
  end
end
