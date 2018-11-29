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

module Y2ConfigurationManagement
  module Salt
    class FormState
      attr_reader :form

      def initialize(form)
        @state = state_from_form(form)
        @form = form
      end

      def get(path)
        @state.dig(*path_to_parts(path)) || default_for(path)
      end

      def add(path, value)
        collection = get(path)
        collection.push(value)
      end

      def update(path, value)
        parts = path_to_parts(path)
        parent = @state.dig(*parts[0..-2])
        parent[parts.last] = value
      end

      def remove(path, index)
        collection = get(path)
        collection.delete_at(index)
      end

      def to_h
        @state
      end

    private

      def default_for(path)
        element = form.find_element_by(path: path)
        element ? element.default : nil
      end

      def path_to_parts(path)
        path[1..-1].split(".")
      end

      def state_from_form(form)
        state_from_element(form.root)
      end

      def state_from_element(element)
        if element.is_a?(Container)
          defaults = element.elements.reduce({}) { |h, e| h.merge(state_from_element(e)) }
          { element.name => defaults }
        else
          { element.name => element.default }
        end
      end
    end
  end
end
