module Collector
  class FacesController < CollectorController
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

    def show
    end

    # def destroy
    #   photo = @face.photo
    #   @face.destroy
    #   photo.destroy if photo.faces.empty?
    #   respond_to do |format|
    #     format.html { redirect_to collector_faces_url, notice: 'Face was successfully destroyed.' }
    #   end
    # end

    def label
      p = params.require(:face).permit(:label_id)
      @face.update(label_id: p['label_id'], edited_user_id: current_user.id)
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
end
