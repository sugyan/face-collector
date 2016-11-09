module Recognizer
  class ApiController < ApplicationController
    respond_to :json

    include ControllerImage

    def image
      # decode requested image
      data = params.require(:image)
      image = MiniMagick::Image.read(Base64.decode64(data.split(',')[1])).auto_orient
      faces = recognize(image)
      render json: { faces: faces, message: format('detected %d faces.', faces.size) }
    end

    def faces
      # TODO: logging
      image_url = params.require(:image_url)
      image = MiniMagick::Image.open(image_url).auto_orient
      faces = recognize(image)
      render json: { faces: faces, message: format('detected %d faces.', faces.size) }
    end

    private

    def recognize(image)
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
    end
  end
end
