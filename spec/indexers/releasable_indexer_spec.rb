# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReleasableIndexer do
  let(:apo_id) { 'druid:gf999hb9999' }

  let(:cocina) do
    Cocina::Models.build(
      'externalIdentifier' => 'druid:pz263ny9658',
      'type' => Cocina::Models::Vocab.image,
      'version' => 1,
      'label' => 'testing',
      'access' => {},
      'administrative' => {
        'hasAdminPolicy' => apo_id,
        'releaseTags' => [
          { 'to' => 'Project', 'release' => true },
          { 'to' => 'test_target', 'release' => true },
          { 'to' => 'test_nontarget', 'release' => false }
        ]
      },
      'description' => {
        'title' => [{ 'value' => 'Test obj' }]
      },
      'structural' => {},
      'identification' => {
        'catalogLinks' => [{ 'catalog' => 'symphony', 'catalogRecordId' => '1234' }]
      }
    )
  end

  describe 'to_solr' do
    let(:doc) { described_class.new(cocina: cocina).to_solr }

    it 'indexes release tags' do
      expect(doc).to eq('released_to_ssim' => %w[Project test_target])
    end
  end
end
