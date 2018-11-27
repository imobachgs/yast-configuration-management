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

require "cwm"

module Y2ConfigurationManagement
  module Widgets
  # This class represents a select widget
    class Select < ::CWM::ComboBox
      # @return [String] Widget name
      attr_reader :name
      # @return [String] Widget items
      attr_reader :items
      # @return [String] Form element path
      attr_reader :path

      class << self
        # Builds a selector widget from a FormElement specification.
        #
        # @param spec       [Y2ConfigurationManagement::Salt::FormElement] Element specification
        # @param controller [Y2ConfigurationManagement::Salt::FormController] Form controller
        # @return [Select] New select widget
        def from_spec(spec, controller)
          items = spec.values.each_with_index.map { |v, i| [i.to_s, v] }
          new(spec.name, items, controller, spec.path)
        end
      end

      # Constructor
      #
      # @param name       [String] Widget name
      # @param items      [Array<String>] Selectable values
      # @param controller [Y2ConfigurationManagement::Salt::FormController] Form controller
      # @param path       [String] Form element path
      # @param items [Array<Array<String,Symbol>>] List of options
      def initialize(name, items, controller, path)
        @name = name
        @items = items
        @controller = controller
        @path = path
        self.widget_id = "select:#{name}"
      end

      # Widget label
      #
      # @return [String]
      # @see CWM::AbstractWidget
      def label
        widget_id.to_s
      end

    private

      attr_reader :controller
    end
  end
end
