module Formageddon
  class IncomingEmailFetcher
    require 'net/pop'

    def self.fetch(ssl = true)
      puts "Running Mail Importer..."
      port = nil
      if ssl
        port = 995
        Net::POP3.enable_ssl(OpenSSL::SSL::VERIFY_NONE)
      end
      
      Net::POP3.start(Formageddon::configuration.incoming_email_config['server'], port, 
                      Formageddon::configuration.incoming_email_config['username'], 
                      Formageddon::configuration.incoming_email_config['password']) do |pop|
        if pop.mails.empty?
          puts "NO MAIL" 
        else
          pop.mails.each do |email|
            begin
              puts "receiving mail..." 
              
              letter = Formageddon::IncomingEmailHandler.receive(email.pop)
              if letter
                # yield letter to the caller for processing in app
                yield(letter)
              end
              
              email.delete
            rescue Exception => e
              puts e.message
            end
          end
        end
      end
      puts "Finished Mail Importer."
    end
  end
end