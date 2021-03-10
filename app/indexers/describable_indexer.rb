# frozen_string_literal: true

class DescribableIndexer
  attr_reader :cocina

  def initialize(cocina:, **)
    @cocina = cocina
  end

  # @return [Hash] the partial solr document for describable concerns
  def to_solr
    add_metadata_format_to_solr_doc.merge(add_mods_to_solr_doc)
  end

  def add_metadata_format_to_solr_doc
    { 'metadata_format_ssim' => 'mods' }
  end

  def add_mods_to_solr_doc
    {
      'sw_language_ssim' => language,
      'mods_typeOfResource_ssim' => resource_type,
      'sw_format_ssim' => sw_format,
      'sw_genre_ssim' => display_genre,
      'sw_author_tesim' => author,
      'sw_display_title_tesim' => title,
      'sw_subject_temporal_ssim' => subject_temporal,
      'sw_subject_geographic_ssim' => subject_geographic,
      'sw_pub_date_facet_ssi' => pub_date
    }.select { |_k, v| v.present? }
  end

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
    contributors = Array(cocina.description.contributor)
    contributors.flat_map do |contributor|
      contributor.name.map do |name|
        next unless name.structuredValue

        name_value = name.structuredValue.find { |val| val.type == 'name' }.value
        life_dates = name.structuredValue.find { |val| val.type == 'life dates' }
        life_dates ? "#{name_value} (#{life_dates.value})" : name_value
      end
    end
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

  def publication_event
    Array(cocina.description.event).find { |form| form.type == 'publication' }
  end

  def periodical?
    publication_event&.note&.any? { |note| note.type == 'issuance' && note.value == 'serial' }
  end

  def pub_date
    Array(publication_event&.date).map(&:value).first
  end

  def sw_format_for_text
    return 'Archived website' if archived_website?
    return 'Journal/Periodical' if periodical?

    'Book'
  end
end
