class InferencesController < ApplicationController
  def index
    @inferences = Inference
      .includes(face: :photo)
      .includes(:label)
      .where(rejected: params[:rejected].present?)
      .order(score: :desc)
      .page(params[:page])
    if (label_id = params[:label_id])
      @inferences = @inferences.where(label_id: label_id)
    end
    if (min_score = params[:min_score])
      @inferences = @inferences.where('score > ?', min_score)
    end
    respond_to do |format|
      format.html { @inferences = @inferences.per(5)   }
      format.json { @inferences = @inferences.per(100) }
    end
  end

  def rejected
    redirect_to inferences_path(rejected: true)
  end

  def accept
    inference = Inference.find(params[:id])
    # TODO: logging
    inference.face.update(label_id: inference.label.id, edited_user_id: current_user.id)
    inference.destroy
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { render json: { result: 'OK' } }
    end
  end

  def reject
    inference = Inference.find(params[:id])
    # TODO: logging
    inference.update(rejected: true)
    respond_to do |format|
      format.html { redirect_to :back }
      format.json { render json: { result: 'OK' } }
    end
  end
end
