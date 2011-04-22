module Formageddon
  class FormageddonFormCaptchaImage < ActiveRecord::Base
    belongs_to :formageddon_form
  end
end