# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DataIndexer do
  let(:cocina) do
    instance_double(Cocina::Models::DRO, externalIdentifier: 'druid:xx999xx9999',
                                         label: 'test label',
                                         version: 4,
                                         type: Cocina::Models::Vocab.map,
                                         administrative: administrative,
                                         structural: structural)
  end

  let(:administrative) do
    instance_double(Cocina::Models::Administrative, hasAdminPolicy: 'druid:vv888vv8888')
  end
  let(:structural) do
    instance_double(Cocina::Models::DROStructural, isMemberOf: ['druid:bb777bb7777', 'druid:dd666dd6666'])
  end

  before do
    allow(WorkflowFields).to receive(:for).and_return({ 'milestones_ssim' => %w[foo bar] })
  end

  describe '#to_solr' do
    let(:metadata) { { 'Last-Modified' => 'Thu, 04 Mar 2021 23:05:34 GMT' } }
    let(:indexer) do
      CompositeIndexer.new(
        described_class
      ).new(id: 'druid:ab123cd4567', cocina: cocina, metadata: metadata)
    end
    let(:doc) { indexer.to_solr }

    context 'with collections' do
      let(:structural) do
        instance_double(Cocina::Models::DROStructural, isMemberOf: ['druid:bb777bb7777', 'druid:dd666dd6666'])
      end

      it 'makes a solr doc' do
        expect(doc).to eq(
          'obj_label_tesim' => 'test label',
          'current_version_isi' => 4,
          'milestones_ssim' => %w[foo bar],
          'has_model_ssim' => 'info:fedora/afmodel:Dor_Item',
          'is_governed_by_ssim' => 'info:fedora/druid:vv888vv8888',
          'is_member_of_collection_ssim' => ['info:fedora/druid:bb777bb7777', 'info:fedora/druid:dd666dd6666'],
          'modified_latest_dttsi' => '2021-03-04T23:05:34Z',
          :id => 'druid:xx999xx9999'
        )
      end
    end

    context 'with no collections' do
      let(:structural) do
        instance_double(Cocina::Models::DROStructural, isMemberOf: nil)
      end

      it 'makes a solr doc' do
        expect(doc).to eq(
          'obj_label_tesim' => 'test label',
          'current_version_isi' => 4,
          'milestones_ssim' => %w[foo bar],
          'has_model_ssim' => 'info:fedora/afmodel:Dor_Item',
          'is_governed_by_ssim' => 'info:fedora/druid:vv888vv8888',
          'is_member_of_collection_ssim' => [],
          'modified_latest_dttsi' => '2021-03-04T23:05:34Z',
          :id => 'druid:xx999xx9999'
        )
      end
    end
  end
end
