class InferencesController < ApplicationController
  def index
    @inferences = Inference
      .includes(:face)
      .includes(:label)
      .order(score: :desc)
      .page(params[:page])
      .per(50)
  end
end
