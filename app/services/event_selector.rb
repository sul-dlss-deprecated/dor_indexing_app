# frozen_string_literal: true

class EventSelector
  # @param [Array<Cocina::Models::Event>] events
  # @param [String] date_type a string to match the date.type in a Cocina::Models::Event
  # @return [Cocina::Models::Event, nil] event best matching selected
  def self.select(events, date_type)
    date_type_matches_and_primary(events, date_type) ||
      date_and_event_type_match(events, date_type) ||
      event_has_date_type(events, date_type)
  end

  # @return [Cocina::Models::Event, nil] event with date of type date_type and of status primary
  def self.date_type_matches_and_primary(events, date_type)
    events.find do |event|
      event_dates = Array(event.date) + Array(event.parallelEvent&.map(&:date))
      event_dates.flatten.compact.find do |date|
        next if date.type != date_type

        structured_primary = Array(date.structuredValue).find do |structured_date|
          structured_date.status == 'primary'
        end
        date.status == 'primary' || structured_primary
      end
    end
  end
  private_class_method :date_type_matches_and_primary

  # @return [Cocina::Models::Event, nil] event with date of type date_type and the event has matching type
  # rubocop:disable Metrics/PerceivedComplexity
  def self.date_and_event_type_match(events, date_type)
    events.find do |event|
      next unless event.type == date_type || event.parallelEvent&.find { |parallel_event| parallel_event.type == date_type }

      event_dates = Array(event.date) + Array(event.parallelEvent&.map(&:date))
      event_dates.flatten.compact.find do |date|
        date.type == date_type
      end
    end
  end
  # rubocop:enable Metrics/PerceivedComplexity
  private_class_method :date_and_event_type_match

  # @return [Cocina::Models::Event, nil] event with date of type date_type
  def self.event_has_date_type(events, date_type)
    events.find do |event|
      event_dates = Array(event.date) + Array(event.parallelEvent&.map(&:date))
      event_dates.flatten.compact.find do |date|
        date.type == date_type
      end
    end
  end
  private_class_method :event_has_date_type
end
