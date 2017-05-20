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

  # POST /inferences/:id/accept
  def accept
    inference = Inference.find(params[:id])
    label = inference.label
    # TODO: logging
    unless inference.rejected?
      inference.face.update(label_id: inference.label.id, edited_user_id: current_user.id)
      inference.destroy
    end
    respond_to do |format|
      format.html { redirect_back fallback_location: inferences_label_path(label) }
      format.json { render json: { success: inference.destroyed? } }
    end
  end

  # POST /inferences/:id/reject
  def reject
    inference = Inference.find(params[:id])
    label = inference.label
    # TODO: logging
    inference.rejected = true
    result = inference.changed?
    inference.save
    respond_to do |format|
      format.html { redirect_back fallback_location: inferences_label_path(label) }
      format.json { render json: { success: result } }
    end
  end
end
