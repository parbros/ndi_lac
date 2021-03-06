module SolrSearch
  module Contacts

    def self.included(base)
      base.class_eval do
        searchable do
          integer :id, stored: true
          text :first_name, stored: true do
            first_name.to_s.downcase if first_name.present?
          end
          text :last_name, stored: true do
            last_name.downcase if last_name.present?
          end
          string :emails, stored: true, multiple: true do
            emails.map &:email
          end
          string :address,  stored: true
          string :address_2,  stored: true
          string :country_code
          string :state_code
          string :city, stored: true
          string :telephones, stored: true, multiple: true do
            telephones.map &:number
          end
          integer :organization_id, stored: true
          integer :organization_kind, stored: true do
            organization.try(:kind)
          end
          string :position, stored: true
          integer :political_position, stored: true
          integer :level_trust, stored: true
          string :tags, stored: true, multiple: true do
            tags.map {|tag| tag.name}
          end
        end

        def self.filters(filters)
          (search do
            with(:id).any_of(filters[:ids].split(',')) if filters[:ids].present?
            keywords filters[:first_name].downcase, fields: :first_name if filters[:first_name].present?
            keywords filters[:last_name].downcase, fields: :last_name if filters[:last_name].present?
            with(:emails).any_of([filters[:email].downcase]) if filters[:email].present?
            if filters[:countries_code].present?
              if filters[:countries_code].is_a? Array
                with(:country_code).any_of(filters[:countries_code])
              else
                with(:country_code, filters[:countries_code])
              end
            end
            with(:organization_id).any_of(filters[:organizations]) if filters[:organizations].present?
            with(:organization_kind).any_of(filters[:organization_kinds]) if filters[:organization_kinds].present?
            with(:political_position).any_of(filters[:political_positions]) if filters[:political_positions].present?
            with(:level_trust).any_of(filters[:level_of_trust]) if filters[:level_of_trust].present?
            with(:tags).any_of(filters[:tags]) if filters[:tags].present?

            if filters[:page] == 'all'
              paginate(:page => 1, :per_page => Contact.count)
            else
              paginate(:page => filters[:page] || 1, :per_page => 50)
            end

          end).results
        end
      end
    end

  end
end
