# frozen_string_literal: true

class EventDateBuilder
  # @param [Array<Cocina::Models::Event>] single selected  event
  # @returns [String, nil] the date value for Solr
  def self.build(event, date_type)
    event_dates = Array(event&.date) + Array(event&.parallelEvent&.map(&:date))

    matching_date_value_with_status_primary(event_dates, date_type) ||
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
