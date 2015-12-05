class PhotosController < ApplicationController
  before_action :set_photo, only: [:show]

  def index
    @photos = Photo.take(20)
  end

  def show
  end

  private
    def set_photo
      @photo = Photo.find(params[:id])
    end
end
