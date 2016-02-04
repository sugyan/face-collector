class PhotosController < ApplicationController
  before_action :set_photo, only: [:destroy]

  def index
    q = params[:q]
    @photos = Photo
      .where('source_url LIKE ? OR photo_url LIKE ?', "%#{q}%", "%#{q}%")
      .order(id: :desc)
      .page(params[:page])
      .per(10)
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
