module Formageddon
  class CaptchaImageController < ApplicationController
    def show
      letter_id = params[:id]
      letter = FormageddonLetter.find(letter_id)
      
      unless letter_id.blank?
        send_file("#{Formageddon::configuration.tmp_captcha_dir}#{letter.id}.jpg",
              :type => 'image/jpeg',
              :disposition => 'inline',
              :filename => "#{letter.id}.jpg")
      end
    end
  end
end