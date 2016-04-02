class InferencesController < ApplicationController
  before_action :authenticate_user!

  def index
    @inferences = Inference
      .includes(face: :photo)
      .includes(:label)
      .order(score: :desc)
      .page(params[:page])
      .per(10)
  end

  def accept
    inference = Inference.find(params[:id])
    inference.face.update(label_id: inference.label.id, edited_user_id: current_user.id)
    inference.destroy
    redirect_to :back
  end
end
