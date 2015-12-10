class PhotosController < ApplicationController
  before_action :set_photo, only: [:show]

  def index
    @photos = Photo.where.not(detected: nil).take(10)
  end

  def show
  end

  private
    def set_photo
      @photo = Photo.find(params[:id])
    end
end
