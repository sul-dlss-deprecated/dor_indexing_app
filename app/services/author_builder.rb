# frozen_string_literal: true

class AuthorBuilder
  # @param [Array<Cocina::Models::Contributor>] contributors
  # @returns [String] The partial solr document
  def self.build(contributors)
    contributors
      .reject { |contributor| contributor.role && contributor.role.first.value != 'creator' }
      .flat_map do |contributor|
        contributor.name.map do |name|
          next unless name.structuredValue

          build_name(name.structuredValue)
        end
      end
  end

  def self.build_name(name)
    name_value = name.find { |val| val.type == 'name' }.value
    life_dates = name.find { |val| val.type == 'life dates' }
    life_dates ? "#{name_value} (#{life_dates.value})" : name_value
  end
  private_class_method :build_name
end
