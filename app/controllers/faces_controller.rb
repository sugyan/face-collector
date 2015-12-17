class FacesController < ApplicationController
  before_action :set_face, only: [:show, :image]

  def index
    @faces = Face
             .order(id: :desc)
             .page(params[:page])
             .per(100)
  end

  def show
  end

  def image
    send_data @face.data, :disposition => "inline", :type => "image/jpeg"
  end

  private
    def set_face
      @face = Face.find(params[:id])
    end
end
