class FacesController < ApplicationController
  before_action :set_face, only: [:show, :destroy, :label, :image]
  skip_before_action :authenticate_user_from_token!, only: [:image, :collage]

  def index
    @faces = Face
      .order(id: :desc)
      .page(params[:page])
      .per(100)
  end

  def search
    if (q = params[:q])
      where = [
        'photos.caption like ?', format('%%%s%%', q.gsub(/[\\%_]/) { |m| "\\#{m}" })
      ]
    end
    @faces = Face
      .joins(:photo)
      .where(where)
      .order(id: :desc)
      .page(params[:page])
      .per(100)
    render :index
  end

  def show
  end

  def destroy
    @face.destroy
    respond_to do |format|
      format.html { redirect_to faces_url, notice: 'Face was successfully destroyed.' }
    end
  end

  def label
    p = params.require(:face).permit(:label_id)
    @face.update(label_id: p['label_id'], edited_user_id: current_user.id)
    @face.inference.destroy if @face.inference
    if !params[:random].blank?
      redirect_to random_faces_url
    else
      redirect_to face_url(@face)
    end
  end

  def random
    count = Face.where(label_id: nil).count
    @face = Face.where(label_id: nil).offset(rand(count)).first
    @random = true
    respond_to do |format|
      # retry to pick a single face photo
      format.html do
        retry_count = 0
        while @face.photo.faces.where(label_id: nil).size > 1
          break if (retry_count += 1) > 5
          @face = Face.where(label_id: nil).offset(rand(count)).first
        end
      end
      format.json {}
    end
    render :show
  end

  def collage
    size = params.fetch(:size, '60').to_i
    if (ids = params[:face_ids])
      faces = ids.split(/-/).map { |id| Face.find(id) }
    else
      labeled = Face.where.not(label_id: nil).where.not(label_id: 0)
      if (label_id = params[:label_id])
        labeled = labeled.where(label_id: label_id)
      end
      count = labeled.count
      raise ActionController::RoutingError, 'Not Found' if count.zero?
      faces = Array.new(4).map { labeled.offset(rand(count)).first }
    end

    imgs = faces.map { |face| MiniMagick::Image.read(face.data) }
    data = Tempfile.create(%w(collage .jpg)) do |tempfile|
      MiniMagick::Tool::Montage.new do |convert|
        convert.geometry("#{size}x#{size}+0+0")
        imgs.each { |img| convert << img.path }
        convert << tempfile.path
      end
      tempfile.read
    end
    imgs.map(&:destroy!)
    send_data data, disposition: 'inline', type: 'image/jpeg'
  end

  def image
    send_data @face.data, disposition: 'inline', type: 'image/jpeg'
  end

  def tfrecords
    label = Label.find_by(index_number: params[:index_number])
    unless label
      return head :not_found if params[:index_number] != '-1'
    end

    sample = [params.fetch(:sample, '100').to_i, 10_000].min
    faces = if label.nil?
              Face.joins(:label).includes(:label).where('labels.index_number is null')
            else
              label.faces
            end
    # sample and generate tfrecords
    data = String.new
    faces.sample(sample).each do |face|
      data << face.tfrecord
    end
    send_data data
  end

  private

  def set_face
    @face = Face.find(params[:id])
  end
end
