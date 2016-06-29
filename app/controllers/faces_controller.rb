class FacesController < ApplicationController
  before_action :set_face, only: [:show, :destroy, :label, :image]
  before_action :authenticate_user!, only: [:destroy, :label]

  def index
    if (q = params[:q])
      where = [
        'photos.caption like ?', format('%%%s%%', q.gsub(/[\\%_]/) { |m| "\\#{m}" })
      ]
    end
    @faces = Face
      .where(where)
      .order(id: :desc)
      .page(params[:page])
      .per(100)
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

  def labeled
    # group by, and order by count
    @ids = Face
      .select(:label_id)
      .where.not(label_id: nil)
      .group(:label_id)
      .having('label_id >= 0')
      .order(count: :desc).order(:label_id)
      .page(params[:page])
      .per(10)
    labels = Label.where(id: @ids).index_by(&:id)
    @labels = @ids.map(&:label_id).map do |id|
      labels[id]
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
    labeled = Face.where.not(label_id: nil).where.not(label_id: 0)
    if (label_id = params[:label_id])
      labeled = labeled.where(label_id: label_id)
    end
    count = labeled.count
    raise ActionController::RoutingError, 'Not Found' if count == 0

    data = Tempfile.create(%w(collage .jpg)) do |tempfile|
      MiniMagick::Tool::Montage.new do |convert|
        convert.geometry('60x60+0+0')
        4.times do
          convert << MiniMagick::Image.read(labeled.offset(rand(count)).first.data).path
        end
        convert << tempfile.path
      end
      tempfile.read
    end
    send_data data, disposition: 'inline', type: 'image/jpeg'
  end

  def image
    send_data @face.data, disposition: 'inline', type: 'image/jpeg'
  end

  def tfrecords
    label = Label.find_by(index_number: params[:index_number])
    return head :not_found unless label

    sample = [params.fetch(:sample, '100').to_i, 10_000].min
    faces = label.faces.to_a
    # faces of index "0"?
    if label.index_number == 0
      faces.concat(Face.joins(:label).where('labels.index_number is null').to_a)
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
