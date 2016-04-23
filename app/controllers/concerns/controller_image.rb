require 'rvg/rvg'

module ControllerImage
  def detect_faces(image)
    url = URI(ENV['GOOGLE_CLOUD_VISION_API_ENDPOINT'])
    res = HTTPClient.new.post(url, generate_json(image), 'Content-Type' => 'application/json')
    results = JSON.parse(res.body)['responses'][0]['faceAnnotations']
    (results || []).map do |annotation|
      {
        bounding: annotation['fdBoundingPoly']['vertices'],
        angle: {
          roll: annotation['rollAngle'],
          yaw: annotation['panAngle'],
          pitch: annotation['tiltAngle']
        }
      }
    end
  end

  def classify_faces(faces)
    images = faces.map do |data|
      ['images', data]
    end
    res = HTTPClient.new.post(ENV['CLASSIFIER_API_ENDPOINT'], images)
    JSON.parse(res.body)['results']
  end

  def face_image(image, face, size)
    x = face[:bounding].map { |v| v['x'] }
    y = face[:bounding].map { |v| v['y'] }
    srt = [
      "#{(x.min + x.max) * 0.5},#{(y.min + y.max) * 0.5}",
      1.0 * size / [x.max - x.min, y.max - y.min].max / 1.1,
      -face[:angle][:roll],
      "#{size * 0.5},#{size * 0.5}"
    ].join(' ')
    face_image = MiniMagick::Image.open(image.path)
    face_image.mogrify do |convert|
      convert.background('black')
      convert.virtual_pixel('background')
      convert.distort(:SRT, srt)
      convert.crop("#{size}x#{size}+0+0")
    end
  end

  private

  def generate_json(image)
    {
      requests: [
        {
          image: { content: Base64.strict_encode64(image.to_blob) },
          features: [{ type: 'FACE_DETECTION', maxResults: 10 }]
        }
      ]
    }.to_json
  end
end
