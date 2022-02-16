# frozen_string_literal: true

namespace :rabbitmq do
  desc 'Setup routing'
  task setup: :environment do
    require 'bunny'

    conn = Bunny.new(hostname: Settings.rabbitmq.hostname,
                     vhost: Settings.rabbitmq.vhost,
                     username: Settings.rabbitmq.username,
                     password: Settings.rabbitmq.password).tap(&:start)

    channel = conn.create_channel

    # connect topic to the queue

    # These messages look like this: { druid: step.druid, action: 'workflow updated' }
    # and they have a routing key like this: 'end-accession.completed')
    # So if the volume here is too high, we can filter the routing keys to *.errored and end-accession.*
    exchange = channel.topic('sdr.workflow')
    queue = channel.queue('dor.indexing-by-druid', durable: true)
    queue.bind(exchange, routing_key: '#')

    # These messages look like this: { model: model.to_h }
    update_exchange = channel.topic('sdr.objects.updated')
    create_exchange = channel.topic('sdr.objects.created')
    queue = channel.queue('dor.indexing-with-model', durable: true)
    queue.bind(update_exchange, routing_key: '#')
    queue.bind(create_exchange, routing_key: '#')

    # These messages look like this: { druid: 'druid:bc123kh8976', deleted_at: 'timestamp here' }
    delete_exchange = channel.topic('sdr.objects.deleted')
    queue = channel.queue('dor.deleting-by-druid', durable: true)
    queue.bind(delete_exchange, routing_key: '#')

    conn.close
  end
end
