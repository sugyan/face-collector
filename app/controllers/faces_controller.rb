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
    data = String.new
    ids = Face.where.not(label_id: nil).pluck(:id).sample(100)
    Face.where(id: ids).each do |face|
      data << [face.label_id].pack('C')
      img = Magick::Image.from_blob(face.data).first
      img.each_pixel do |pixel|
        data << [pixel.red / 256, pixel.green / 256, pixel.blue / 256].pack('C*')
      end
      img.destroy!
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
