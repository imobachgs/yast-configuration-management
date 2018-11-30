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
  # This module contains the widgets which are used to display forms for Salt formulas
  module Widgets
    # Represents a collection of elements
    #
    # This widget uses a table to display a collection of elements and offers
    # buttons to add, remove and edit them.
    class Collection < ::CWM::CustomWidget
      attr_reader :label, :min_items, :max_items, :controller, :path

      # Constructor
      #
      # @param spec       [Y2ConfigurationManagement::Salt::FormElement] Element specification
      # @param controller [Y2ConfigurationManagement::Salt::FormController] Form controller
      def initialize(spec, controller)
        textdomain "configuration_management"
        @label = spec.label
        @min_items = spec.min_items
        @max_items = spec.max_items
        @controller = controller
        @path = spec.path # form element path
        self.widget_id = "collection:#{spec.id}"
      end

      # Widget contents
      #
      # @return [Term]
      def contents
        VBox(
          Table(
            Id("table:#{path}"),
            Opt(:notify, :immediate),
            Header(*headers),
            rows
          ),
          HBox(
            HStretch(),
            PushButton(Id(:add), Yast::Label.AddButton),
            PushButton(Id(:edit), Yast::Label.EditButton),
            PushButton(Id(:remove), Yast::Label.RemoveButton)
          )
        )
      end

      # Forces the widget to inspect all events
      #
      # @return [TrueClass]
      def handle_all_events
        true
      end

      # Events handler
      #
      # @todo Partially implemented only
      #
      # @param event [Hash] Event specification
      def handle(event)
        case event["ID"]
        when :add
          controller.add(path)
        when :edit
          # TODO
          # controller.edit(path, selected_row) if selected_row
        when :remove
          # TODO
          # controller.remove(path, selected_row) if selected_row
        end
        nil
      end

    private

      def rows
        controller.get(path).map do |item|
          Item(Id(item.values.first), *item.values)
        end
      end

      def headers
        # FIXME: Get this information from the spec
        values = controller.get(path)
        return values.first.keys if values.first
        []
      end

      # Returns the index of the selected row
      #
      # @return [Integer,nil] Index of the selected row or nil if no row is selected
      def selected_row
        row_id = UI.QueryWidget(Id("table_#{name}"), :CurrentItem)
        row_id ? row_id.to_i : nil
      end
    end
  end
end
