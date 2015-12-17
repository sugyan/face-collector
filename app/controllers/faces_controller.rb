class FacesController < ApplicationController
  before_action :set_face, only: [:show, :label, :image]

  def index
    @faces = Face
             .order(id: :desc)
             .page(params[:page])
             .per(100)
  end

  def show
  end

  def label
    p = params.require(:face).permit(:label_id)
    @face.update(label_id: p['label_id'])
    redirect_to @face
  end

  def image
    send_data @face.data, :disposition => "inline", :type => "image/jpeg"
  end

  private
    def set_face
      @face = Face.find(params[:id])
    end
end
