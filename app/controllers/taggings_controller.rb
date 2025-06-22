class TaggingsController < UnitContextController
  def new
    @taggable = taggable
    @tags = ActsAsTaggableOn::Tag.for_tenant(current_unit.id)
  end

  def taggable
    klass, param = taggable_class
    klass.find(params[param.to_sym]) if klass
  end

  private

  def taggable_class
    params.each_key do |name|
      if name =~ /(.+)_id$/
        model = name.match(%r{([^\/.]+)_id$})
        return model[1].classify.constantize, name
      end
    end
    nil
  end
end
