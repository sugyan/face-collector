class FeedbacksController < ApplicationController
  def index
  end

  def create
    Feedback.create!(feedback_params.merge(from_ip: request.remote_ip))
    redirect_to :back, notice: I18n.t('feedback.create')
  end

  private

  def feedback_params
    params.require(:feedback).permit(:body)
  end
end
