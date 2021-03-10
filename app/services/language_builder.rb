# frozen_string_literal: true

# Finds the language value to index from the cocina languages
class LanguageBuilder
  # @param [Array<Cocina::Models::Language>] languages
  # @returns [String] The partial solr document
  def self.build(languages)
    languages.map do |lang|
      if lang.source&.code&.start_with?('iso639')
        language_for_code(lang.code)
      else
        lang.value
      end
    end
  end

  def self.language_for_code(code)
    name = ISO_639.find(code)
    name ? name.english_name : "Obsolete language: #{code}"
  end
end
