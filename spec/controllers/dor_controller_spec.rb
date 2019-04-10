require 'rails_helper'

RSpec.describe DorController, type: :controller do
  describe '#reindex' do
    before :each do
      @mock_druid     = 'asdf:1234'
      @mock_logger    = double(Logger)
      @mock_solr_conn = double(Dor::SearchService.solr)
      @mock_solr_doc  = { id: @mock_druid, text_field_tesim: 'a field to be searched' }

      expect(Dor::IndexingService).to receive(:generate_index_logger).and_return(@mock_logger)
    end

    it 'should reindex an object' do
      expect(Dor::IndexingService).to receive(:reindex_pid)
        .with(@mock_druid, logger: @mock_logger, add_attributes: { commitWithin: 1000 }).and_return(@mock_solr_doc)
      expect(Dor::SearchService).to receive(:solr).and_return(@mock_solr_conn)
      expect(@mock_solr_conn).to receive(:commit)
      get :reindex, params: { pid: @mock_druid }
      expect(response.body).to eq "Successfully updated index for #{@mock_druid}"
      expect(response.code).to eq '200'
    end

    it 'can be used with asynchronous commits' do
      expect(Dor::IndexingService).to receive(:reindex_pid)
        .with(@mock_druid, logger: @mock_logger, add_attributes: { commitWithin: 2 }).and_return(@mock_solr_doc)
      expect(Dor::SearchService).not_to receive(:solr)
      get :reindex, params: { pid: @mock_druid, commitWithin: 2 }
      expect(response.body).to eq "Successfully updated index for #{@mock_druid}"
      expect(response.code).to eq '200'
    end

    it 'should give the right status if an object is not found' do
      expect(Dor::IndexingService).to receive(:reindex_pid)
        .with(@mock_druid, logger: @mock_logger, add_attributes: { commitWithin: 1000 }).and_raise(ActiveFedora::ObjectNotFoundError)
      get :reindex, params: { pid: @mock_druid }
      expect(response.body).to eq 'Object does not exist in Fedora.'
      expect(response.code).to eq '404'
    end
  end

  describe '#delete_from_index' do
    it 'removes an object from the index' do
      expect(Dor::SearchService.solr).to receive(:delete_by_id).with('asdf:1234', commitWithin: 1000)
      expect(Dor::SearchService.solr).to receive(:commit)
      get :delete_from_index, params: { pid: 'asdf:1234' }
    end

    it 'passes through the commitWithin parameter' do
      expect(Dor::SearchService.solr).to receive(:delete_by_id).with('asdf:1234', commitWithin: 5000)
      expect(Dor::SearchService.solr).not_to receive(:commit)
      get :delete_from_index, params: { pid: 'asdf:1234', commitWithin: 5000 }
    end
  end

  describe '#queue_size' do
    let(:mock_status) { instance_double(QueueStatus::All, queue_size: 15) }
    it 'retrives the size of the backing message queues' do
      expect(QueueStatus).to receive(:all).and_return(mock_status)
      get :queue_size
      expect(JSON.parse(response.body)).to include('value' => 15)
    end
  end
end
