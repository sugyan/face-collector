require 'tensorflow/core/example/example'

class Face < ActiveRecord::Base
  belongs_to :photo
  belongs_to :label

  def tfrecord
    return if label.blank?
    return if label.index_number.blank?

    example = Tensorflow::Example.new(
      features: Tensorflow::Features.new(
        feature: {
          'label' => Tensorflow::Feature.new(int64_list: Tensorflow::Int64List.new(value: [label.index_number])),
          'image_raw' => Tensorflow::Feature.new(bytes_list: Tensorflow::BytesList.new(value: [data]))
        }
      )
    )
    encoded = Tensorflow::Example.encode(example)
    length = [encoded.size].pack('Q')
    [
      length,
      masked_crc(Digest::CRC32c.checksum(length)),
      encoded,
      masked_crc(Digest::CRC32c.checksum(encoded))
    ].join
  end

  private

  def masked_crc(crc)
    [((crc >> 15) | (crc << 17)) + 0xa282ead8].pack('L')
  end
end
