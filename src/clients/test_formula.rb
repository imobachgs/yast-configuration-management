# Simple example to demonstrate object API for CWM

require "yast"
require "cwm"
require "configuration_management/salt/form_builder"
require "configuration_management/widgets/form"
require "byebug"

Yast.import "CWM"
Yast.import "Wizard"

SPEC = {
   "person" => {
   "$type" => "namespace",
   "name" => {
     "$type" => "text",
     "$default" => "Text"
   },
   "email" => {
     "$type" => "email"
   },
   "computers" => {
     "$type" => "edit-group",
     "$minItems" => 1,
     "$maxItems" => 4,
     "$prototype" => {
       "brand" => {
         "$default" => "Dell",
         "$type" => "select",
         "$values" => [
           "ACME", "Acer", "Dell", "Lenovo"
         ],
       },
       "disks" => {
         "$type" => "number",
         "$default" => 1
       }
     }
   }
  }
}.freeze

module Yast
  class ExampleDialog
    include Yast::I18n
    include Yast::UIShortcuts
    def run
      textdomain "example"

      builder = Yast::ConfigurationManagement::Salt::FormBuilder.new(SPEC)

      contents = HBox(*builder.build)

      Yast::Wizard.CreateDialog
      next_handler = proc { Yast::Popup.YesNo("Really go next?") }
      back_handler = proc { Yast::Popup.YesNo("Really go back?") }
      abort_handler = proc { Yast::Popup.YesNo("Really abort?") }
      CWM.show(contents,
        caption:       _("Test formula"),
        next_handler:  next_handler,
        back_handler:  back_handler,
        abort_handler: abort_handler)
      Yast::Wizard.CloseDialog
    end
  end
end

Yast::ExampleDialog.new.run
