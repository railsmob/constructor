# encoding: utf-8

module ConstructorPages
  module Types
    # HTML type. Render ckeditor wysiwyg.
    class HtmlType < ActiveRecord::Base
      belongs_to :field
      belongs_to :page, touch: true
    end
  end
end