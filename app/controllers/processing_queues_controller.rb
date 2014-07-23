class ProcessingQueuesController < BaseAdminController
  before_action :lookup_queue, only: [:show, :dequeue]

  def index
    @queues = ProcessingQueue.select('DISTINCT(queue)')
  end

  def show
    cleanup_deleted_items(@items)
    @items.compact!
  end

  def dequeue
    @item = ProcessingQueue.queue(@queue).where(id: params[:item]).first
    if @item.nil?
      redirect_to :back
    else
      @item.dequeue
      redirect_to processing_queue_path(@item.queue)
    end
  end

  private

  def lookup_queue
    @items = ProcessingQueue.queue(params[:id])
    @queue = params[:id]
  end

  def cleanup_deleted_items(items)
    items.select { |item| item.queueable.nil? }.map(&:destroy)
  end
end
