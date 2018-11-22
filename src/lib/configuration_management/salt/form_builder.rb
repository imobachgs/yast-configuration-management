# Copyright (c) [2018] SUSE LLC
#
# All Rights Reserved.
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of version 2 of the GNU General Public License as published
# by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, contact SUSE LLC.
#
# To contact SUSE LLC about this file by physical or electronic mail, you may
# find current contact information at www.suse.com.

require "configuration_management/widgets/form"


module Yast
  module ConfigurationManagement
    module Salt
      # This class builds a form according to a given specification
      #
      # For further information, see the forms specification at
      # https://github.com/SUSE/spacewalk/wiki/Writing-Salt-Formulas-for-SUSE-Manager
      class FormBuilder
        # @return [Hash]
        attr_reader :form_spec

        # Constructor
        #
        # @param form_spec [Hash] Form specification
        def initialize(form_spec)
          @form_spec = form_spec
        end

        # Build the form
        #
        # @return [Array<Yast::ConfigurationManagement::Widgets::Form>]
        def build
          form_spec.map do |name, element_spec|
            build_element(name, element_spec)
          end
        end

        private

        # Build a form element
        #
        # The form element can be a simple input control, a group or even a collection.
        # The type is determined by the `$type` key which should be included in the element
        # specification.
        #
        # @param name [String]
        # @param element_spec [Hash]
        # @return [Yast::ConfigurationManagement::Widgets::Group,
        #          Yast::ConfigurationManagement::Widgets::Text,
        #          Yast::ConfigurationManagement::Widgets::Collection]
        def build_element(name, element_spec)
          type = element_spec.fetch("$type", "text")
          if ["group", "namespace"].include?(type)
            build_group(name, element_spec)
          elsif type == "edit-group"
            build_collection(name, element_spec)
          else
            build_input(name, element_spec)
          end
        end

        # Build a form group
        #
        # @param name [String] Group name
        # @param group_spec [Hash] Group specification
        # @return [Yast::ConfigurationManagement::Widgets::Group]
        def build_group(name, group_spec)
          children = group_spec.reject { |k, _v| k.start_with?("$") }.map do |n, element_spec|
            build_element(n, element_spec)
          end
          Yast::ConfigurationManagement::Widgets::Group.new(name: name, children: children)
        end

        # Builds a simple input element
        #
        # TODO: to be extended with support for different elements
        #
        # @param name [String] Group name
        # @param input_spec [Hash] Group specification
        # @return [Yast::ConfigurationManagement::Widgets::Text]
        def build_input(name, input_spec)
          klass =
            case input_spec.fetch("$type", "text")
            when "text", "email", "number"
              Yast::ConfigurationManagement::Widgets::Text
            when "select"
              Yast::ConfigurationManagement::Widgets::Select
            end
          klass.new(name: name, spec: input_spec)
        end

        # Builds a collection
        #
        # @param name [String] Collection name
        # @param collection_spec [Hash] Collection specification
        # @return [Yast::ConfigurationManagement::Widgets::Collection]
        def build_collection(name, collection_spec)
          # NOTE: instead of using an array, we should consider having something like a row object
          # which is smart enough to clone itself in order to create new rows.
          elements = collection_spec["$prototype"].map do |n, element_spec|
            build_element(n, element_spec)
          end
          prototype = Yast::ConfigurationManagement::Widgets::Row.new(elements, name: name)
          Yast::ConfigurationManagement::Widgets::Collection.new(
            name: name, spec: collection_spec, prototype: prototype
          )
        end
      end
    end
  end
end
