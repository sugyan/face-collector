require 'rvg/rvg'

module ModelImage
  def detect_faces(url, size)
    detector = Faraday.new(url: ENV['FACE_DETECT_API_ENDPOINT']) do |faraday|
      faraday.adapter :net_http
    end
    data = JSON.parse(detector.get('/api', url: url).body)
    return if data['error']

    faces = data['faces']
    faces.each do |face|
      face['w'] *= 1.2
      face['h'] *= 1.2
    end
    faces.select do |face|
      face['w'] < 100 && face['h'] < 100 &&
        (face['w'] * data['image']['width'] / 100.0 > size / 2 &&
         face['h'] * data['image']['height'] / 100.0 > size / 2)
    end
  end
end
