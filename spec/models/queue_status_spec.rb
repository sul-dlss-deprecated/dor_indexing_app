require 'rails_helper'

RSpec.describe QueueStatus do
  let(:queue_size_url) { 'http://example.com/queue/size' }
  let(:mock_response) { instance_double(Faraday::Response, body: { 'value' => 123 }.to_json) }
  let(:mock_client) { instance_double(Faraday::Connection, get: mock_response) }

  before do
    allow(Faraday).to receive(:new).with(queue_size_url).and_return(mock_client)
  end
  subject(:queue_status) { QueueStatus.new(queue_size_url: queue_size_url) }

  describe '#queue_size' do
    it 'retrieves the queue size' do
      expect(subject.queue_size).to eq 123
    end
  end

  describe '.all' do
    subject { QueueStatus.all }

    let(:queue) { double(QUEUE_SIZE_URL: queue_size_url) }

    before do
      allow(Settings).to receive(:MESSAGE_QUEUES).and_return([queue, queue])
    end

    describe '#queue_size' do
      it 'sums the queue sizes of all the message queues' do
        expect(subject.queue_size).to eq 246
      end
    end
  end
end
