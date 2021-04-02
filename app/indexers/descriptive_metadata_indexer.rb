# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class DescriptiveMetadataIndexer
  attr_reader :cocina

  def initialize(cocina:, **)
    @cocina = cocina
  end

  # @return [Hash] the partial solr document for descriptive metadata
  def to_solr
    {
      'sw_language_ssim' => language,
      'mods_typeOfResource_ssim' => resource_type,
      'sw_format_ssim' => sw_format,
      'sw_genre_ssim' => display_genre,
      'sw_author_tesim' => author,
      'sw_display_title_tesim' => title,
      'sw_subject_temporal_ssim' => subject_temporal,
      'sw_subject_geographic_ssim' => subject_geographic,
      'sw_pub_date_facet_ssi' => pub_year,
      'originInfo_date_created_tesim' => [creation_date].compact,
      'originInfo_publisher_tesim' => publisher_name,
      'originInfo_place_placeTerm_tesim' => publication_location,
      'topic_ssim' => topics,
      'topic_tesim' => topics,
      'metadata_format_ssim' => 'mods' # NOTE: seriously? for cocina????
    }.select { |_k, v| v.present? }
  end

  private

  def language
    LanguageBuilder.build(Array(cocina.description.language))
  end

  def subject_temporal
    subjects.flat_map do |subject|
      Array(subject.structuredValue).select { |node| node.type == 'time' }.map(&:value)
    end
  end

  def subject_geographic
    subjects.flat_map do |subject|
      Array(subject.structuredValue).select { |node| node.type == 'place' }.map(&:value)
    end
  end

  def subjects
    @subjects ||= Array(cocina.description.subject)
  end

  def author
    AuthorBuilder.build(Array(cocina.description.contributor))
  end

  def title
    TitleBuilder.build(cocina.description.title)
  end

  def forms
    @forms ||= Array(cocina.description.form)
  end

  def resource_type
    @resource_type ||= forms.select { |form| form.type == 'resource type' }.map(&:value)
  end

  def display_genre
    return [] unless genres

    val = genres.map(&:to_s)
    val << 'Thesis/Dissertation' if (genres & %w[thesis Thesis]).any?
    val << 'Conference proceedings' if (genres & ['conference publication', 'Conference publication', 'Conference Publication']).any?
    val << 'Government document' if (genres & ['government publication', 'Government publication', 'Government Publication']).any?
    val << 'Technical report' if (genres & ['technical report', 'Technical report', 'Technical Report']).any?

    val.uniq
  end

  def genres
    @genres ||= forms.select { |form| form.type == 'genre' }.map(&:value)
  end

  FORMAT = {
    'cartographic' => 'Map',
    'mixed material' => 'Archive/Manuscript',
    'moving image' => 'Video',
    'notated music' => 'Music score',
    'software, multimedia' => 'Software/Multimedia',
    'sound recording-musical' => 'Music recording',
    'sound recording-nonmusical' => 'Sound recording',
    'sound recording' => 'Sound recording',
    'still image' => 'Image',
    'three dimensional object' => 'Object'
  }.freeze

  def sw_format
    FORMAT.fetch(resource_type.first) { sw_format_for_text }
  end

  def archived_website?
    genres.include?('archived website')
  end

  # TODO: part of https://github.com/sul-dlss/dor_indexing_app/issues/567
  # From Arcadia, it should be:
  #  typeOfResource is "text" and any of: issuance is "continuing", issuance is "serial", frequency has a value
  def periodical?
    publication_event&.note&.any? { |note| note.type == 'issuance' && note.value == 'serial' }
  end

  def pub_year
    date = EventDateBuilder.build(publication_event, 'publication') || creation_date
    ParseDate.earliest_year(date).to_s if date.present?
  end

  def creation_date
    @creation_date ||= EventDateBuilder.build(creation_event, 'creation')
  end

  def sw_format_for_text
    return 'Archived website' if archived_website?
    return 'Journal/Periodical' if periodical?

    'Book'
  end

  def publisher_name
    publisher = Array(publication&.contributor).find { |contributor| contributor.role.any? { |role| role.value == 'publisher' } }
    Array(publisher&.name).map(&:value)&.compact
  end

  def publication
    @publication ||= events.find { |event| event.type == 'publication' }
  end

  def publication_location
    publication&.location&.map(&:value)&.compact
  end

  def topics
    @topics ||= Array(cocina.description.subject).select { |subject| subject.type == 'topic' }.map(&:value).compact
  end

  def publication_event
    @publication_event ||= EventSelector.select(events, 'publication')
  end

  def creation_event
    @creation_event ||= EventSelector.select(events, 'creation')
  end

  def events
    @events ||= Array(cocina.description.event).compact
  end
end
# rubocop:enable Metrics/ClassLength
