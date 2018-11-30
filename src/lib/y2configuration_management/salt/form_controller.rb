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

require "y2configuration_management/salt/form_builder"
require "y2configuration_management/salt/form_data"
require "y2configuration_management/widgets/form_popup"

Yast.import "CWM"
Yast.import "Wizard"

module Y2ConfigurationManagement
  module Salt
    # This class takes care of driving the form for a Salt Formula.
    #
    # @example Rendering a form
    #   form_form = Form.from_file("test/fixtures/form.yml")
    #   controller = FormController.new(form_form)
    #   controller.show_main_dialog
    class FormController
      include Yast::I18n
      include Yast::UIShortcuts

      # Constructor
      #
      # @param form [Y2ConfigurationManagement::Salt::Form] Form
      def initialize(form)
        @data = FormData.new(form)
        @form = form
      end

      # Renders the main form's dialog
      def show_main_dialog
        show_dialog(form.root.name, form_builder.build(form.root.elements))
      end

      def get(path)
        @data.get(path)
      end

      # Opens a new dialog in order to add a new element to a collection
      # @todo
      def add(path)
        element = form.find_element_by(path: path).prototype
        show_popup(element.name, form_builder.build(element))
      end

    private

      attr_reader :form, :data

      # Returns the form builder
      #
      # @return [Y2ConfigurationManagement::Salt::FormBuilder]
      def form_builder
        @form_builder ||= Y2ConfigurationManagement::Salt::FormBuilder.new(self)
      end

      # Displays a form dialog
      #
      # @param title    [String] Dialog title
      # @param contents [Array<CWM::AbstractWidget>] Popup content (as an array of CWM widgets)
      def show_dialog(title, contents)
        next_handler = proc { Yast::Popup.YesNo("Exit?") }
        Yast::Wizard.CreateDialog
        Yast::CWM.show(
          VBox(*contents), caption: title, next_handler: next_handler
        )
        Yast::Wizard.CloseDialog
      end

      # Displays a popup
      #
      # @param title    [String] Popup title
      # @param contents [Array<CWM::AbstractWidget>] Popup content (as an array of CWM widgets)
      def show_popup(title, contents)
        Widgets::FormPopup.new(title, contents).run
      end
    end
  end
end
