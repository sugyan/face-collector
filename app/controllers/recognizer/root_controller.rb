module Recognizer
  class RootController < RecognizerController
    include ControllerImage

    FACE_SIZE = 112

    def index
    end

    def api
      # decode requested image
      data = params.require(:image)
      image = Magick::Image.from_blob(Base64.decode64(data.split(',')[1])).first.auto_orient
      # detect faces by Cloud Vision API
      faces = detect_faces(image).select do |face|
        face[:bounding].all? { |v| v['x'] && v['y'] }
      end
      # create face images
      requests = faces.map do |face|
        img = face_image(image, face, FACE_SIZE)
        b64 = Base64.strict_encode64(img.to_blob { self.format = 'JPG' })
        img.destroy!
        'data:image/jpeg;base64,' + b64
      end
      # classify faces
      classified = classify_faces(requests).map do |r|
        r.map { |v| format('%.3f', v * 100.0).to_f }
      end
      labels = Label.where.not(index_number: nil).index_by(&:index_number)
      faces.each.with_index do |face, i|
        face[:recognize] = classified[i].map.with_index do |e, j|
          [labels[j] ? labels[j].name : j, e]
        end
      end
      image.destroy!
      render json: { faces: faces, message: format('detected %d faces.', faces.size) }
    end
  end
end
