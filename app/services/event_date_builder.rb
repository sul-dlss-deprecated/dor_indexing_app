# frozen_string_literal: true

class EventDateBuilder
  # @param [Array<Cocina::Models::Event>] single event selected as publication event
  # @returns [String, nil] the pub date value for Solr
  def self.build(publication_event, date_type)
    event_dates = Array(publication_event&.date) + Array(publication_event&.parallelEvent&.map(&:date))

    pub_date = matching_date_value_with_status_primary(event_dates, date_type)
    return pub_date if pub_date.present?

    matching_date_value(event_dates, date_type)
  end

  # @return [String, nil] date.value from a date of type of date_type and of status primary
  def self.matching_date_value_with_status_primary(event_dates, date_type)
    event_dates.flatten.compact.find do |date|
      next if date.type != date_type
      return date.value if date.status == 'primary' && date&.value.present?

      Array(date&.structuredValue).find do |structured_date|
        return structured_date.value if structured_date.status == 'primary'
      end
    end
  end
  private_class_method :matching_date_value_with_status_primary

  # @return [String, nil] date.value from a date of type of date_type
  def self.matching_date_value(event_dates, date_type)
    event_dates.flatten.compact.find do |date|
      next if date.type != date_type
      return date.value if date&.value.present?

      Array(date&.structuredValue).find do |structured_date|
        return structured_date.value if structured_date&.value.present?
      end
    end
  end
  private_class_method :matching_date_value
end
