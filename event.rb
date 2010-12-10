module WebGlue
  class Event
    NEW_TOPIC_EVENT_CODE = 1
    NEW_SUBSCRIPTION_EVENT_CODE = 2

    attr_reader :timestamp, :topic_id, :subscription_id

    def initialize(timestamp, code, topic_id, subscription_id)
      @timestamp = timestamp
      @code = code
      @topic_id = topic_id
      @subscription_id = subscription_id
    end

    def to_hash
      {
          :timestamp => @timestamp,
          :code => @code,
          :topic_id => @topic_id,
          :subscription_id => @subscription_id
      }
    end

    def self.from_hash(hash)
      case hash[:code]
        when NEW_TOPIC_EVENT_CODE
          NewTopicEvent.from_hash(hash)
        when NEW_SUBSCRIPTION_EVENT_CODE
          NewSubscriptionEvent.from_hash(hash)
      end
    end

    private

    @timestamp
    @code
    @topic_id
    @subscription_id
  end

  class NewTopicEvent < Event

    def initialize(timestamp, topic_id)
      super(timestamp, NEW_TOPIC_EVENT_CODE, topic_id, nil)
    end

    def self.from_hash(hash)
      self.new(hash[:timestamp], hash[:topic_id])
    end

    def to_string
      "New topic"
    end
  end

  class NewSubscriptionEvent < Event
    def initialize(timestamp, topic_id, subscription_id)
      super(timestamp, NEW_SUBSCRIPTION_EVENT_CODE, topic_id, subscription_id)
    end

    def self.from_hash(hash)
      self.new(hash[:timestamp], hash[:topic_id], hash[:subscription_id])
    end

    def to_string
      "New subscription"
    end
  end
end
