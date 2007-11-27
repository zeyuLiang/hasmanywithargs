module Dweebd
  module HasManyWithArgs
    def self.included base #:nodoc:#
      base.extend ClassMethods
    end

    module ClassMethods
      # Define an association that takes arguments other than force_reload.
      # An arbitrary number of arguments can be specified and they will all be mandatory.
      # Optional arguments are not currently supported.
      #
      # First the association name is defined, followed by the arguments the method takes
      #   class Referee
      #     has_many_with_args :officiated_fights_between :fighter1, :fighter2
      #   end
      #
      # Then it can be accessed on instances of Referee
      #   ref = Referee.find(1)
      #   ali     = Boxer.find(1)
      #   foreman = Boxer.find(2)
      #
      #   ref.officiated_fights_between(ali, foreman)
      def has_many_with_args(association_id, *args, &extension)
        include HasManyWithArgs::InstanceMethods
        options = args.extract_options!
        raise ArgumentError, 'Must specify at least one argument for association to take' if args.empty?
        raise ArgumentError, 'Must specify class name of association objects.  Use :class_name in has_many_with_args options' unless options.has_key?(:class_name)

        args_and_accessors = args_and_accessors_for(association_id, args)
        create_attr_readers args_and_accessors.values
        new_options = remapped_options options, args_and_accessors

        mapped_association_id = "has_many_with_args_mapped_association_#{association_id}"
        has_many mapped_association_id, new_options, &extension

        InstanceMethods.define_association_accessor mapped_association_id, association_id, args_and_accessors
      end

      def create_attr_readers accessors #:nodoc:#
        accessors.each do |accessor|
          attr_reader accessor
        end
      end

      def args_and_accessors_for association_id, args #:nodoc:#
        args_and_accessors = {}

        args.each do |arg|
          accessor = "has_many_with_args_#{association_id}_reader_#{arg.to_s}"
          args_and_accessors[arg.to_s] = accessor
        end

        args_and_accessors
      end

      def remapped_options options, args_and_accessors #:nodoc:#
        new_options = {}
        args_and_accessors.each_pair do |arg, arg_accessor|
          remappings_count = 0

          options.each_pair do |option, value|
            if remapped_value = interpolate_value(value, arg, arg_accessor)
              new_options[option] = remapped_value
              remappings_count += 1
            else
              new_options[option] = value
            end
          end

          raise ArgumentError, "At least one option must include a dynamic interpolation of the #{arg} argument" unless remappings_count > 0
        end

        new_options
      end

      def interpolate_value value, arg, arg_accessor #:nodoc:#
        remap_performed = false

        remapped_value = value.dup.to_s
        while to_interpolate = /\#\{(#{arg}).*\}/.match(remapped_value)
          b, e = to_interpolate.offset(to_interpolate.length - 1)
          remapped_value.slice!(b..(e - 1))
          remapped_value.insert(b, arg_accessor)
          remap_performed = true
        end

        remap_performed ? remapped_value : nil
      end

    end

    module InstanceMethods
      def self.define_association_accessor mapped_association_id, association_id, args_and_accessors #:nodoc:#
        argument_list = args_and_accessors.keys.join(', ')

        setters = []
        args_and_accessors.each do |arg, accessor|
          setters << "@#{accessor} = #{arg}"
        end

        method_definition = <<-DEFINE_INSTANCE_METHOD
        def #{association_id} #{argument_list}, force_reload = false, &block
          #{setters.join("\n")}
          #{mapped_association_id} force_reload, &block
        end
        DEFINE_INSTANCE_METHOD

        eval method_definition
      end
    end

  end
end

ActiveRecord::Base.send :include, Dweebd::HasManyWithArgs
