require 'test_helper'

class FaceTest < ActiveSupport::TestCase
  test 'binary' do
    label = Label.create(id: 1)
    face = Face.create(
      data: [%w(
        89504e470d0a1a0a0000000d49484452
        00000003000000030802000000d94a22
        e80000001c49444154081d05c1010100
        0008c320dedce613865856b6622aeeee
        01880b0a7e294fdb0e0000000049454e
        44ae426082
      ).join].pack('H*'),
      label_id: label.id
    )
    assert_equal face.binary(3), [%w(
      00
      00FF00FF00FF00FF7F
      0000FFFF0000FFFF7F
      00000000FFFFFFFF7F
    ).join].pack('H*')
  end
end
