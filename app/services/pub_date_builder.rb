# frozen_string_literal: true

class PubDateBuilder
  # @param [Array<Cocina::Models::Event>] single event selected as publication event
  # @returns [String, nil] the pub date value for Solr
  def self.build(publication_event, date_type)
    event_dates = Array(publication_event&.date) + Array(publication_event&.parallelEvent&.map(&:date))

    pub_date = pub_date_from_status_primary(event_dates, date_type)
    return pub_date if pub_date.present?

    date_from_type_publication(event_dates, date_type)
  end

  # @return [String, nil] date.value from a date of type of publication and status primary
  def self.pub_date_from_status_primary(event_dates, date_type)
    event_dates.flatten.compact.find do |date|
      next if date.type != date_type
      return date.value if date.status == 'primary' && date&.value.present?

      Array(date&.structuredValue).find do |structured_date|
        return structured_date.value if structured_date.status == 'primary'
      end
    end
  end
  private_class_method :pub_date_from_status_primary

  # @return [String, nil] date.value from a date of type of publication
  def self.date_from_type_publication(event_dates, date_type)
    event_dates.flatten.compact.find do |date|
      next if date.type != date_type
      return date.value if date&.value.present?

      Array(date&.structuredValue).find do |structured_date|
        return structured_date.value if structured_date&.value.present?
      end
    end
  end
  private_class_method :date_from_type_publication
end
