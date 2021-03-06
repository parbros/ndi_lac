class ExportDocx
  def initialize(contacts, cols, labels = nil)
    @contacts = contacts
    @cols = cols
    @html = ["<html><head></head><body>"]
    if labels
      render_labels
    else
      render_contacts
    end
  end
  
  def render_contacts
    @contacts.each do |contact|
      @cols.each do |col|
        if col == 'country_code'
          country_code = contact.send col
          if country_code.present?
            text "#{col.humanize}: #{Carmen::Country.coded(country_code).name} (#{country_code})"
          else
            text "#{col.humanize}: N/A"
          end
        elsif col == 'tags'
          text "#{col.humanize}: #{contact.tag_list}"
        elsif col == 'organization'
          text "#{col.humanize}: #{contact.organization.name if contact.organization.present?}"
        elsif col == 'emails'
          text "#{col.humanize}: #{contact.emails.map(&:email).join(',')}"
        elsif col == 'telephones'
          text "#{col.humanize}:"
          contact.telephones.each do |telephone| 
            text "#{telephone.kind.humanize}: #{telephone.number}"
          end
        else
          text "#{col.humanize}: #{contact.send col}"
        end
      end
      text "<br/>"
    end
  end
  
  def text(content)
    @html << "<p>#{content}</p>"
  end
  
  def render
    @html.join('').to_s + "</body></html>"
  end
  
  def render_labels
    @contacts.each do |contact|
      text contact.name
      text contact.address
      text contact.address_2
      text "#{contact.city}, #{contact.country_code.present? ? Carmen::Country.coded(contact.country_code).name : "N/A"}"
    end
  end
  
end