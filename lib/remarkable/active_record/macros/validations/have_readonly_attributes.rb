module Remarkable
  module Syntax

    module RSpec
      class HaveReadonlyAttributes
        include Remarkable::Private
        
        def initialize(*attributes)
          get_options!(attributes)
          @attributes = attributes
        end

        def matches?(klass)
          @klass = klass

          begin
            @attributes.each do |attribute|
              attribute = attribute.to_sym
              readonly = klass.readonly_attributes || []

              unless readonly.include?(attribute.to_s)
                fail readonly.empty? ?
                "#{klass} attribute #{attribute} is not read-only" :
                "#{klass} is making #{readonly.to_a.to_sentence} read-only, but not #{attribute}"
              end
            end

            true
          rescue Exception => e
            false
          end
        end

        def description
          "make #{@attributes.to_sentence} read-only"
        end

        def failure_message
          @failure_message || "expected that #{@attributes.to_sentence} cannot be changed once the record has been created, but it did"
        end

        def negative_failure_message
          "expected that #{@attributes.to_sentence} cann be changed once the record has been created, but it didn't"
        end
      end

      # Ensures that the attribute cannot be changed once the record has been created.
      #
      #   it { User.should have_readonly_attributes(:password, :admin_flag) }
      #
      def have_readonly_attributes(*attributes)
        Remarkable::Syntax::RSpec::HaveReadonlyAttributes.new(*attributes)
      end
    end

    module Shoulda
      # Ensures that the attribute cannot be changed once the record has been created.
      #
      #   should_have_readonly_attributes :password, :admin_flag
      #
      def should_have_readonly_attributes(*attributes)
        get_options!(attributes)
        klass = model_class

        attributes.each do |attribute|
          attribute = attribute.to_sym
          it "should make #{attribute} read-only" do
            readonly = klass.readonly_attributes || []

            unless readonly.include?(attribute.to_s)
              fail_with(readonly.empty? ?
                        "#{klass} attribute #{attribute} is not read-only" :
                        "#{klass} is making #{readonly.to_a.to_sentence} read-only, but not #{attribute}.")
            end
          end
        end
      end
    end

  end
end