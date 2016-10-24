class RootController < ApplicationController
  def index
    @added = Face
      .select('DATE(created_at) as DATE', 'COUNT(*)')
      .where('created_at >= ?', Time.zone.today - 7)
      .group('DATE')
      .order('DATE DESC')
  end

  def feed
    @faces = Face
      .includes(:edited_user)
      .where.not(label_id: nil)
      .order(updated_at: :desc)
      .page(params[:page] || 1)
      .per(50)
    respond_to do |format|
      format.html
      format.rss
    end
  end
end
