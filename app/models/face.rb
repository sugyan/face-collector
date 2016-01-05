class Face < ActiveRecord::Base
  belongs_to :photo
  belongs_to :label

  def cifar10_binary(size)
    buf = String.new
    buf << [label_id - 1].pack('C')
    img = Magick::Image.from_blob(data).first.resize(size, size)
    %w(red green blue).each do |color|
      img.each_pixel do |px|
        buf << [px.send(color) >> 8].pack('C')
      end
    end
    buf
  end
end
