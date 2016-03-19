class FacesController < ApplicationController
  before_action :set_face, only: [:show, :label, :image]
  before_action :authenticate_user!, only: [:label]

  def index
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
  end

  def show
  end

  # def destroy
  #   photo = @face.photo
  #   @face.destroy
  #   photo.destroy if photo.faces.empty?
  #   respond_to do |format|
  #     format.html { redirect_to faces_url, notice: 'Face was successfully destroyed.' }
  #   end
  # end

  def label
    p = params.require(:face).permit(:label_id)
    @face.update(label_id: p['label_id'], edited_user_id: current_user.id)
    @face.inference.destroy if @face.inference
    if !params[:random].blank?
      url = random_faces_url
      redirect_to url
    else
      redirect_to face_url(@face)
    end
  end

  def random
    count = Face.where(label_id: nil).count
    @face = Face.where(label_id: nil).offset(rand(count)).first
    @random = true
    render :show
  end

  def collage
    labeled = Face.where.not(label_id: nil).where.not(label_id: 0)
    count = labeled.count

    img = Magick::Image.new(120, 120)
    [[0, 0], [0, 60], [60, 0], [60, 60]].each do |offsets|
      face = Magick::Image.from_blob(labeled.offset(rand(count)).first.data).first
      img.composite!(face.resize!(60, 60), offsets[0], offsets[1], Magick::OverCompositeOp)
      face.destroy!
    end
    data = img.to_blob { self.format = 'JPG' }
    img.destroy!

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
