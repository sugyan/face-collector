class ProxyController < ApplicationController
  def index
    url = URI(params[:url])
    if url.host != 'pbs.twimg.com'
      return head :bad_request
    end
    res = Net::HTTP.get_response(url)
    send_data res.body, disposition: 'inline', type: res.header.content_type
  end
end
