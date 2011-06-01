module Formageddon
  class IncomingEmailHandler < ActionMailer::Base
    def receive(email)
      to_email = email.to.select{|e| e =~ /formageddon/ }.first
      
      return if to_email.nil?
      
      recipient, domain = to_email.split(/@/)
      tag, thread_id = recipient.split(/\+/)
      
      thread = FormageddonThread.find_by_id(thread_id)
      return if thread.nil?
      
      letter = FormageddonLetter.new
      letter.status = 'RECEIVED'
      letter.direction = 'TO_RECEIPIENT'
      
      letter.subject = email.subject
      letter.message = email.body.raw_source
      
      letter.formageddon_thread = thread
      letter.save
    end
  end
end