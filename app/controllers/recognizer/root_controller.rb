# coding: utf-8
module Recognizer
  class RootController < ApplicationController
    layout 'recognizer'

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
  end
end
