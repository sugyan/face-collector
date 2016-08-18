# coding: utf-8
module Recognizer
  class RootController < ApplicationController
    protect_from_forgery except: :api
    layout 'recognizer'

    include ControllerImage

    def index
    end

    def about
      keys = %w(あ か さ た な は ま や ら わ)
      @dict = keys.each_with_object({}) { |key, hash| hash[key] = [] }
      labels = Label
        .where.not(index_number: nil)
        .where('id >= ?', 0)
        .sort_by { |label| label.tags.presence || 'ん' }
      labels.each do |label|
        @dict[keys.reverse.find { |key| key < (label.tags.presence || 'ん') }] << label
      end
      @feedback = Feedback.new
    end

    def api
      # decode requested image
      data = params.require(:image)
      image = MiniMagick::Image.read(Base64.decode64(data.split(',')[1])).auto_orient
      # detect faces by Cloud Vision API
      faces = detect_faces(image).select do |face|
        face[:bounding].all? { |v| v['x'] && v['y'] }
      end
      # create face images
      requests = faces.map do |face|
        img = face_image(image, face, 96)
        "data:image/jpeg;base64,#{Base64.strict_encode64(img.to_blob)}"
      end
      # classify faces
      classified = classify_faces(requests)
      faces.each.with_index do |face, i|
        face[:recognize] = classified[i]['top']
      end
      render json: { faces: faces, message: format('detected %d faces.', faces.size) }
    end
  end
end
