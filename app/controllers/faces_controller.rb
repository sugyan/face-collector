class FacesController < ApplicationController
  before_action :set_face, only: [:show, :label, :image]

  def index
    @faces = Face
      .order(id: :desc)
      .page(params[:page])
      .per(100)
  end

  def labeled
    @faces = Face
      .where(label_id: params[:label_id])
      .order(updated_at: :desc)
      .page(params[:page])
      .per(100)
    render :index
  end

  def show
  end

  def label
    p = params.require(:face).permit(:label_id)
    @face.update(label_id: p['label_id'])
    if params[:random]
      redirect_to action: :random
    else
      redirect_to @face
    end
  end

  def random
    @face = Face.offset(rand(Face.count)).first
    @random = true
    render :show
  end

  def binary
    p = params.permit(:size, :num)
    size = p.fetch(:size, ENV['IMAGE_SIZE'] || '224').to_i
    num = [p.fetch(:num, '100').to_i, 500].min

    data = String.new
    ids = Face.where.not(label_id: nil).pluck(:id).sample(num)
    Face.where(id: ids).each do |face|
      data << face.binary(size)
    end
    send_data data, filename: 'faces.bin'
  end

  def image
    send_data @face.data, disposition: 'inline', type: 'image/jpeg'
  end

  private

  def set_face
    @face = Face.find(params[:id])
  end
end
