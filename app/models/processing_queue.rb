class ProcessingQueue < ActiveRecord::Base

  belongs_to :queueable, polymorphic: true

  validates :queueable, presence: true
  validates :queue, presence: true

  scope :queue, lambda { |queue_name| where(queue: queue_name.to_s).where(dequeued_at: nil).order('queued_at ASC') }
  scope :queue_for_type, lambda { |queue_name, queue_type| queue(queue_name.to_s).where(queueable_type: queue_type) }

  class << self
    def enqueue(queueable, queue)
      self.create!(queueable_id: queueable.id, queueable_type: queueable.class.name, queue: queue.to_s, queued_at: Time.now.utc)
    end

    def dequeue(queue, queueable_type = nil)
      item = queueable_type.nil? ? queue(queue.to_s).first : queue_for_type(queue.to_s, queueable_type).first
      unless item.nil?
        item.dequeued_at = Time.now.utc
        item.save
      end
      item
    end

    def unqueue(queueable, queue)
      item = queue_for_type(queue.to_s, queueable.class.name).where(queueable_id: queueable.id).first
      item.destroy unless item.nil?
    end

    def queued?(queueable, queue)
      queue_for_type(queue.to_s, queueable.class.name).where(queueable_id: queueable.id).any?
    end

    def clear(queue, queueable_type = nil)
      items = queueable_type.nil? ? queue(queue.to_s) : queue_for_type(queue.to_s, queueable_type)
      items.map(&:destroy)
    end
  end

  def dequeue
    self.dequeued_at = Time.now.utc
    save
  end

end

# == Schema Information
# Schema version: 20140713193201
#
# Table name: processing_queues
#
#  id             :integer          not null, primary key
#  queueable_id   :integer
#  queueable_type :string(255)
#  queue          :string(255)
#  queued_at      :datetime
#  dequeued_at    :datetime
#
