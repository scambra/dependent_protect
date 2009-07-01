# DependentProtect

module DependentProtect
  def self.append_features(base)
    super
    base.extend(ClassMethods)

    ripe_class = Class.new(ActiveRecord::ActiveRecordError)
    k = ActiveRecord.const_set('ReferentialIntegrityProtectionError', ripe_class)

    base.class_eval do
      class << self
        alias_method_chain :has_many, :protect
        alias_method_chain :has_one, :protect
        alias_method_chain :belongs_to, :protect
      end
    end
  end

  module ClassMethods
    # We should be aliasing configure_dependency_for_has_many but that method
    # is private so we can't. We alias has_many instead trying to be as fair
    # as we can to the original behaviour.
    def has_many_with_protect(association_id, options = {}, &extension) #:nodoc:
      reflection = create_reflection(:has_many, association_id, options, self)

      if reflection.options[:dependent] == :protect
        module_eval "before_destroy 'raise ActiveRecord::ReferentialIntegrityProtectionError, \"Can\\'t destroy because there\\'s at least one #{reflection.class_name} in this #{self.class_name}\" if self.#{reflection.name}.find(:first)'"
        options = options.clone
        options.delete(:dependent)
      end

      has_many_without_protect(association_id, options, &extension)
      write_inheritable_hash :reflections, association_id => reflection
    end

    # We should be aliasing configure_dependency_for_has_one but that method
    # is private so we can't. We alias has_many instead trying to be as fair
    # as we can to the original behaviour.
    def has_one_with_protect(association_id, options = {}, &extension) #:nodoc:
      reflection = create_reflection(:has_one, association_id, options, self)

      if reflection.options[:dependent] == :protect
        module_eval "before_destroy 'raise ActiveRecord::ReferentialIntegrityProtectionError, \"Can\\'t destroy because there\\'s a #{reflection.class_name} in this #{self.class_name}\" if self.#{reflection.name}'"
        options = options.clone
        options.delete(:dependent)
      end

      has_one_without_protect(association_id, options, &extension)
      write_inheritable_hash :reflections, association_id => reflection
    end

    # We should be aliasing configure_dependency_for_belongs_to but that method
    # is private so we can't. We alias has_many instead trying to be as fair
    # as we can to the original behaviour.
    def belongs_to_with_protect(association_id, options = {}, &extension) #:nodoc:
      reflection = create_reflection(:belongs_to, association_id, options, self)

      if reflection.options[:dependent] == :protect
        module_eval "before_destroy 'raise ActiveRecord::ReferentialIntegrityProtectionError, \"Can\\'t destroy because there\\'s a #{reflection.class_name} in this #{self.class_name}\" if self.#{reflection.name}'"
        options = options.clone
        options.delete(:dependent)
      end

      belongs_to_without_protect(association_id, options, &extension)
      write_inheritable_hash :reflections, association_id => reflection
    end
  end
end
