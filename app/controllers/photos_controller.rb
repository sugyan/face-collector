class PhotosController < ApplicationController
  before_action :set_photo, only: [:show]

  def index
    @photos = Photo.where.not(faces: nil).take(20)
  end

  def show
  end

  private
    def set_photo
      @photo = Photo.find(params[:id])
    end
end
