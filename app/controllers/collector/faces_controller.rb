module Collector
  class FacesController < CollectorController
    before_action :set_face, only: [:show, :destroy, :label, :image]

    def index
      @faces = Face
        .order(id: :desc)
        .page(params[:page])
        .per(100)
    end

    def labeled
      @label = Label.find(params[:label_id])
      @faces = Face
        .joins(:photo)
        .where(label_id: params[:label_id])
        .order('photos.posted_at DESC')
        .page(params[:page])
        .per(100)
      render :index
    end

    def sample
      num = [params.fetch(:num, '100').to_i, 1000].min
      @label = Label.find(params[:label_id])
      ids = Face.where(label_id: params[:label_id])
        .pluck(:id)
        .sample(num)
      @faces = Face.where(id: ids)
      respond_to do |format|
        format.json
      end
    end

    def show
    end

    def destroy
      photo = @face.photo
      @face.destroy
      photo.destroy if photo.faces.empty?
      respond_to do |format|
        format.html { redirect_to collector_faces_url, notice: 'Face was successfully destroyed.' }
      end
    end

    def label
      p = params.require(:face).permit(:label_id)
      @face.update(label_id: p['label_id'])
      if !params[:random].blank?
        url = random_collector_faces_url
        redirect_to url
      else
        redirect_to collector_face_url(@face)
      end
    end

    def random
      count = Face.where(label_id: nil).count
      @face = Face.where(label_id: nil).offset(rand(count)).first
      @random = true
      render :show
    end

    def image
      send_data @face.data, disposition: 'inline', type: 'image/jpeg'
    end

    private

    def set_face
      @face = Face.find(params[:id])
    end
  end
end