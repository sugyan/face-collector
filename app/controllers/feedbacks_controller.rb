class FeedbacksController < ApplicationController
  skip_before_action :authenticate_user_from_token!, only: [:create]

  def index
    @feedbacks = Feedback
      .order(created_at: :desc)
      .page(params[:page])
      .per(20)
  end

  def create
    Feedback.create!(feedback_params.merge(from_ip: request.remote_ip))
    redirect_back fallback_location: recognizer_about_path, notice: I18n.t('feedback.create')
  end

  private

  def feedback_params
    params.require(:feedback).permit(:body)
  end
end
