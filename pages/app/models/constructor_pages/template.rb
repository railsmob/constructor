# encoding: utf-8

module ConstructorPages
  # Template model. Template allows assing different design for pages.
  #
  # Templates has many fields.
  # For example:
  #   template "Product" should has fields like "price", "description", "size" etc.
  class Template < ActiveRecord::Base
    # Adding code_name_uniqueness method
    include CodeNameUniq

    validates_presence_of :name, :code_name
    validates_uniqueness_of :code_name
    validate :code_name_uniqueness

    default_scope -> { order :lft }

    has_many :pages, dependent: :destroy
    has_many :fields, dependent: :destroy

    acts_as_nested_set

    # Return child corresponding child_id or children first
    def child
      if child_id
        self.class.find(child_id)
      else
        children.first if !leaf?
      end
    end

    # Convert name to genetive
    def to_genetive
      name.mb_chars.downcase.genitive
    end

    private

    # Check if there is code_name in same branch
    def check_code_name(cname)
      [cname.pluralize, cname.singularize].each {|name|
        return false if root.descendants.map{|t| t.code_name unless t.code_name == cname}.include?(name)}
      true
    end
  end
end