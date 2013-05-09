# encoding: utf-8

module ConstructorPages
  class Page < ActiveRecord::Base
    attr_accessible :name, :title, :keywords, :description,
                    :url, :full_url, :active, :auto_url,
                    :parent_id, :link, :in_menu, :in_map,
                    :in_nav, :template_id

    has_many :string_types,:dependent => :destroy, :class_name => "Types::StringType"
    has_many :float_types, :dependent => :destroy, :class_name => "Types::FloatType"
    has_many :boolean_types, :dependent => :destroy, :class_name => "Types::BooleanType"
    has_many :integer_types, :dependent => :destroy, :class_name => "Types::IntegerType"
    has_many :text_types, :dependent => :destroy, :class_name => "Types::TextType"
    has_many :date_types, :dependent => :destroy, :class_name => "Types::DateType"
    has_many :html_types, :dependent => :destroy, :class_name => "Types::HtmlType"
    has_many :image_types, :dependent => :destroy, :class_name => "Types::ImageType"

    belongs_to :template

    default_scope order(:lft)

    validates_presence_of :name

    before_save :url_prepare, :content_filter
    after_update :full_url_descendants_change

    before_update :full_url_change
    before_create :full_url_create

    after_create :create_fields
    
    acts_as_nested_set
    
    def self.children_of(page)
      Page.where(:parent_id => page)
    end

    def field(code_name, meth = "value")
      field = ConstructorPages::Field.where(:code_name => code_name, :template_id => self.template_id).first

      if field
        f = "constructor_pages/types/#{field.type_value}_type".classify.constantize.where(:field_id => field.id, :page_id => self.id).first
        f ? f.send(meth) : ""
      end
    end

    def method_missing(name, *args, &block)
      field(name)
    end

    private

    def full_url_change
      if parent_id
        self.full_url = '/' + Page.find(parent_id).self_and_ancestors.map {|c| c.url}.append(self.url).join('/')
      else
        self.full_url = '/' + self.url
      end
    end

    def full_url_create
      if self.parent.nil?
        self.full_url = '/' + self.url
      else
        self.full_url = self.parent.full_url + '/' + self.url
      end
    end

    def full_url_descendants_change
      self.descendants.each { |c| c.save }
    end

    def url_prepare
      if self.auto_url or self.url.empty?
        self.url = self.name.parameterize
      else
        self.url = self.url.parameterize
      end
    end

    def create_fields
      template.fields.each do |field|
        "constructor_pages/types/#{field.type_value}_type".classify.constantize.create(
            :page_id => id,
            :field_id => field.id)
      end
    end
  end
end