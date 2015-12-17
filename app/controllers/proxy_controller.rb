class ProxyController < ApplicationController
  def index
    url = URI(params[:url])
    case url.host
    when 'pbs.twimg.com'
    when 'stat.ameba.jp'
    else
      return head :bad_request
    end
    res = Net::HTTP.get_response(url)
    send_data res.body, disposition: 'inline', type: res.header.content_type
  end
end
