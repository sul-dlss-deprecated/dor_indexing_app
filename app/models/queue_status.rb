# frozen_string_literal: true

# A plain-old-Ruby-object representing queue statuses
class QueueStatus
  def self.all
    All.new(find_each)
  end

  def self.find_each
    return to_enum(:find_each) unless block_given?

    Settings.MESSAGE_QUEUES.each do |mq|
      yield new(queue_size_url: mq.QUEUE_SIZE_URL)
    end
  end

  attr_reader :queue_size_url

  def initialize(queue_size_url:)
    @queue_size_url = queue_size_url
  end

  def queue_size
    client = Faraday.new(queue_size_url)
    data = JSON.parse(client.get.body)
    data['value']
  end

  # Act on all queues
  class All
    def initialize(queues = [])
      @queues = queues.to_a
    end

    def queue_size
      @queues.map(&:queue_size).sum
    end
  end
end
