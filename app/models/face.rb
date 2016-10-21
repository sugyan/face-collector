require 'tensorflow/core/example/example'

class Face < ApplicationRecord
  belongs_to :photo
  belongs_to :label
  belongs_to :edited_user, class_name: User, foreign_key: :edited_user_id
  has_one :inference, dependent: :destroy

  def tfrecord
    return if label.blank?

    example = Tensorflow::Example.new(
      features: Tensorflow::Features.new(
        feature: {
          'label' => Tensorflow::Feature.new(int64_list: Tensorflow::Int64List.new(value: [label.index_number || 0])),
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
