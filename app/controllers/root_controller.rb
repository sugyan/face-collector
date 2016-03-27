class RootController < ApplicationController
  def index
    @added = Face
      .select('DATE(created_at) as DATE', 'COUNT(*)')
      .where('created_at >= ?', Time.zone.today - 7)
      .group('DATE')
      .order('DATE DESC')
  end
end
