# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RoleMetadataIndexer do
  let(:apo_id) { 'druid:gf999hb9999' }
  let(:cocina) do
    Cocina::Models.build(
      'externalIdentifier' => apo_id,
      'type' => Cocina::Models::Vocab.admin_policy,
      'version' => 1,
      'label' => 'testing',
      'administrative' => {
        'hasAdminPolicy' => apo_id,
        'roles' => [
          { 'name' => 'dor-apo-manager',
            'members' => [
              {
                'type' => 'workgroup',
                'identifier' => 'dlss:dor-admin'
              },
              {
                'type' => 'workgroup',
                'identifier' => 'sdr:developer'
              },
              {
                'type' => 'sunetid',
                'identifier' => 'tcramer'
              }
            ] }
        ]
      },
      'description' => {
        'title' => [{ 'value' => 'APO title' }]
      }
    )
  end

  let(:indexer) do
    described_class.new(cocina: cocina)
  end

  describe '#to_solr' do
    subject(:doc) { indexer.to_solr }

    it 'has the fields used by argo' do
      expect(doc['apo_register_permissions_ssim']).to eq ['workgroup:dlss:dor-admin', 'workgroup:sdr:developer', 'sunetid:tcramer']
      expect(doc['apo_role_dor-apo-manager_ssim']).to eq ['workgroup:dlss:dor-admin', 'workgroup:sdr:developer']
      expect(doc['apo_role_person_dor-apo-manager_ssim']).to eq ['sunetid:tcramer']
    end
  end
end
