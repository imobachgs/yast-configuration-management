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

 module Yast
   module ConfigurationManagement
     module Widgets
       class Text < ::CWM::InputField
         attr_reader :name

         def initialize(name:, spec:)
           @name = name
           self.widget_id = "text_#{name}"
         end

         def label
           widget_id.to_s
         end

         def duplicate(suffix)
           self.class.new(name: "#{name}_#{suffix}", spec: {})
         end
       end

       class Select < ::CWM::ComboBox
         attr_reader :name, :items, :spec

         def initialize(name:, spec:)
           @name = name
           @items = spec["$values"].map { |v| [v, v] }
           @spec = spec
           self.widget_id = "text_#{name}"
         end

         def label
           widget_id.to_s
         end

         def duplicate(index)
           self.class.new(name: name, spec: spec)
         end
       end

       # Represents a group of elements
       class Group < ::CWM::CustomWidget
         attr_reader :name, :children

         def initialize(name:, children:)
           textdomain "configuration_management"
           @name = name
           @children = children
         end

         def label
           name
         end

         def contents
           VBox(*children)
         end
       end

       # This class represents a row in a collection
       class Row < ::CWM::CustomWidget
         attr_reader :children, :name

         def initialize(children, name: nil, index: nil)
           textdomain "configuration_management"
           @children = children
           @name = name
           self.widget_id = index ? "#{name}_#{index}" : "#{name}_master"
         end

         def contents
           HBox(*children)
         end

         def duplicate(index)
           self.class.new(children.map { |c| c.duplicate(index) }, index: index, name: name)
         end
       end

       # This is just an auxiliary class to be able to put all the rows inside a replace point
       class List < ::CWM::CustomWidget
         attr_reader :rows

         def initialize(name:, rows:)
           textdomain "configuration_management"
           @rows = rows
           self.widget_id = "#{name}_list"
         end

         def contents
           VBox(*rows)
         end
       end

       # Represents a collection of elements
       #
       # NOTE: I would rather prefer a table with some kind of dialog to add new elements. But this
       # solution is OK for a PoC.
       class Collection < ::CWM::CustomWidget
         attr_reader :name, :min_items, :max_items, :prototype, :rows

         def initialize(name:, spec:, prototype:)
           textdomain "configuration_management"
           @name = name
           @min_items = spec["minItems"]
           @max_items = spec["maxItems"]
           @prototype = prototype
           @rows = [prototype.duplicate(0), prototype.duplicate(1)]
           self.widget_id = "collection_#{name}"
         end

         def label
           name
         end

         def contents
           VBox(
             replace_point,
             Right(PushButton(Id("add_#{name}"), _("Add")))
           )
         end

         def handle_all_events
           true
         end

         def handle(event)
           case event["ID"]
           when "add_#{name}"
             add_row
           end
           nil
         end

       private

         def replace_point
           @replace_point ||= ::CWM::ReplacePoint.new(id: name, widget: rows_list)
         end

         def rows_list
           List.new(name: name, rows: rows)
         end

         def add_row
           @rows << prototype.duplicate(@rows.size)
           replace_point.replace(rows_list)
         end
       end
     end
   end
 end
