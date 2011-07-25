module FormageddonHelper
  def predict_selection(page, input)
    case input.name
    when /textarea/i
      return :message
    when /select/i
      case input.attributes["name"].value + label_text_for(page, input)
      when /salutation/i, /prefix/i
        return :title
      when /state/i
        return :state
      when /response/i
        return :get_response
      when /topic/i, /subject/i
        return :issue_area
      end
    when /input/i
      if !input.attributes['type'].nil? &&
         (input.attributes['type'] =~ /image/i or input.attributes['type'] =~ /submit/i)
         return :submit_button
      else
        case input.attributes['name'].value + label_text_for(page, input)
        when /prefix/i
          return :title
        when /subject/i
          return :subject
        when /captcha/i
          return :captcha_solution
        when /email/i
          return :email
        when /phone/i
          return :phone
        when /zip4/i, /zipplus4/i, /plusfour/i, /zipfour/i
          return :zip4
        when /zipcode/i, /zip/i
          return :zip5
        when /city/i
          return :city
        when /state/i
          return :state
        when /address2/i, /address 2/i, /address_2/i, /street2/i
          return :address2
        when /address/i, /address 1/i, /street/i
          return :address1
        when /firstname/i, /first name/i, /first_name/i, /fname/i, /first/i
          return :first_name
        when /lastname/i, /last name/i, /last_name/i, /lname/i, /lname/i, /last/i
          return :last_name
        end
      end
    end
    
    return :leave_blank
  end
  
  def label_for(field)
    case field.to_s
    when :title, 'title', 'sender_title'
      'Title/Salutation'
    when :first_name, 'first_name', 'sender_first_name'
      'First Name'
    when :last_name, 'last_name', 'sender_last_name'
      'Last Name'
    when :email, 'email', 'sender_email'
      'Email address'
    when :address1, 'address1', 'sender_address1'
      'Address'
    when :address2, 'address2', 'sender_address2'
      'Address (cont.)'
    when :city, 'city', 'sender_city'
      'City'
    when :state, 'state', 'sender_state'
      'State'
    when :zip5, 'zip5', 'sender_zip5'
      'Zip Code'
    when :zip4, 'zip4', 'sender_zip4'
      'Zip+4'
    when :phone, 'phone', 'sender_phone'
      'Phone'
    when :issue_area, 'issue_area'
      'Issue Area'
    when :subject, 'subject'
      'Subject'
    when :message, 'message'
      'Message'
    end
  end
  
  def label_text_for(page, node)
    if node.attributes['id']
      l = page.parser.css("label[@for=#{node.attributes['id'].value }]")
      return l.text if l
    end
    
    return ""
  end
end
