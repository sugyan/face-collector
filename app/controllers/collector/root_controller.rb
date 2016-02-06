module Collector
  class RootController < CollectorController
    def index
      # group by, and order by count
      @ids = Face
        .select(:label_id)
        .where.not(label_id: nil)
        .group(:label_id)
        .order(count: :desc).order(:label_id)
        .page(params[:page])
        .per(10)
      labels = Label.where(id: @ids).index_by(&:id)
      @labels = @ids.map(&:label_id).map do |id|
        labels[id]
      end
    end
  end
end
