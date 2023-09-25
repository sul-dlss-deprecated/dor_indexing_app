# frozen_string_literal: true

require 'stanford-mods'

# rubocop:disable Metrics/ClassLength
class DescriptiveMetadataIndexer
  attr_reader :cocina, :stanford_mods_record

  def initialize(cocina:, **)
    @cocina = cocina
    mods_ng = Cocina::Models::Mapping::ToMods::Description.transform(cocina.description, cocina.externalIdentifier)
    @stanford_mods_record = Stanford::Mods::Record.new.from_nk_node(mods_ng.root)
  end

  # rubocop:disable Metrics/MethodLength
  # @return [Hash] the partial solr document for descriptive metadata
  def to_solr
    {
      'sw_language_ssim' => stanford_mods_record.sw_language_facet, # language,
      'mods_typeOfResource_ssim' => resource_type,
      'sw_format_ssim' => sw_format,
      'sw_genre_ssim' => stanford_mods_record.sw_genre,
      'sw_author_tesim' => author,
      'contributor_orcids_ssim' => orcids,
      'sw_display_title_tesim' => title,
      'sw_subject_temporal_ssim' => stanford_mods_record.era_facet, # subject_temporal,
      'sw_subject_geographic_ssim' => stanford_mods_record.geographic_facet, # subject_geographic,
      'sw_pub_date_facet_ssi' => stanford_mods_record.pub_year_int.to_s,
      'originInfo_date_created_tesim' => creation_date,
      'originInfo_publisher_tesim' => publisher_name,
      'originInfo_place_placeTerm_tesim' => event_place,
      'topic_ssim' => stanford_mods_record.topic_facet,
      'topic_tesim' => stemmable_topics,
      'metadata_format_ssim' => 'mods' # NOTE: seriously? for cocina????
    }.select { |_k, v| v.present? }
  end
  # rubocop:enable Metrics/MethodLength

  private

  def language
    LanguageBuilder.build(Array(cocina.description.language))
  end

  def subject_temporal
    TemporalBuilder.build(subjects)
  end

  def subject_geographic
    GeographicBuilder.build(subjects)
  end

  def subjects
    @subjects ||= Array(cocina.description.subject)
  end

  def author
    AuthorBuilder.build(Array(cocina.description.contributor))
  end

  def orcids
    OrcidBuilder.build(Array(cocina.description.contributor))
  end

  def title
    Cocina::Models::Builders::TitleBuilder.build(cocina.description.title)
  end

  def forms
    @forms ||= Array(cocina.description.form)
  end

  def resource_type
    @resource_type ||= forms.select do |form|
      form.source&.value == 'MODS resource types' &&
        %w[collection manuscript].exclude?(form.value)
    end.map(&:value)
  end

  # See https://github.com/sul-dlss/stanford-mods/blob/master/lib/stanford-mods/searchworks.rb#L244
  FORMAT = {
    'cartographic' => 'Map',
    'manuscript' => 'Archive/Manuscript',
    'mixed material' => 'Archive/Manuscript',
    'moving image' => 'Video',
    'notated music' => 'Music score',
    'software, multimedia' => 'Software/Multimedia',
    'sound recording-musical' => 'Music recording',
    'sound recording-nonmusical' => 'Sound recording',
    'sound recording' => 'Sound recording',
    'still image' => 'Image',
    'three dimensional object' => 'Object',
    'text' => 'Book'
  }.freeze

  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def sw_format
    return stanford_mods_record.format_main unless stanford_mods_record.format_main.empty?
    return ['Map'] if has_resource_type?('software, multimedia') && has_resource_type?('cartographic')
    return ['Dataset'] if has_resource_type?('software, multimedia') && has_genre?('dataset')
    return ['Archived website'] if has_resource_type?('text') && has_genre?('archived website')
    return ['Book'] if has_resource_type?('text') && has_issuance?('monographic')
    return ['Journal/Periodical'] if has_resource_type?('text') && (has_issuance?('continuing') || has_issuance?('serial') || has_frequency?)

    resource_type_formats = flat_forms_for('resource type').map { |form| FORMAT[form.value&.downcase] }.uniq.compact
    resource_type_formats.delete('Book') if resource_type_formats.include?('Archive/Manuscript')

    return resource_type_formats if resource_type_formats == ['Book']

    genre_formats = flat_forms_for('genre').map { |form| form.value&.capitalize }.uniq

    (resource_type_formats + genre_formats).presence
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity

  def has_resource_type?(type)
    flat_forms_for('resource type').any? { |form| form.value == type }
  end

  def has_genre?(genre)
    flat_forms_for('genre').any? { |form| form.value == genre }
  end

  def has_issuance?(issuance)
    flat_event_notes.any? { |note| note.type == 'issuance' && note.value == issuance }
  end

  def has_frequency?
    flat_event_notes.any? { |note| note.type == 'frequency' }
  end

  def flat_forms_for(type)
    forms.flat_map do |form|
      if form.type == type
        flat_value(form)
      else
        flat_value(form).select { |form_value| form_value.type == type }
      end
    end
  end

  def flat_event_notes
    @flat_event_notes ||= events.flat_map { |event| flat_event(event) }.flat_map { |event| Array(event.note).flat_map { |note| flat_value(note) } }
  end

  def pub_year
    PubYearSelector.build(events)
  end

  def creation_date
    @creation_date ||= EventDateBuilder.build(creation_event, 'creation')
  end

  def event_place
    place_event = events.find { |event| event.type == 'publication' } || events.first
    EventPlaceBuilder.build(place_event)
  end

  def publisher_name
    publish_events = events.map { |event| event.parallelEvent&.first || event }
    return if publish_events.blank?

    PublisherNameBuilder.build(publish_events)
  end

  def stemmable_topics
    TopicBuilder.build(Array(cocina.description.subject), filter: 'topic')
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

  def flat_event(event)
    event.parallelEvent.presence || Array(event)
  end

  def flat_value(value)
    value.parallelValue.presence || value.groupedValue.presence || value.structuredValue.presence || Array(value)
  end
end
# rubocop:enable Metrics/ClassLength
