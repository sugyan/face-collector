class PhotosController < ApplicationController
  before_action :set_photo, only: [:show, :destroy]

  def index
    q = params[:q]
    @photos = Photo
              .where('url LIKE ? OR media_url LIKE ?', "%#{q}%", "%#{q}%")
              .order(id: :desc)
              .page(params[:page])
  end

  def show
  end

  def destroy
    @photo.faces.destroy_all
    @photo.destroy
    redirect_to photos_url, notice: 'Photo was successfully destroyed.'
  end

  private
    def set_photo
      @photo = Photo.find(params[:id])
    end
end
