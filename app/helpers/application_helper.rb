file 'app/helpers/application_helper.rb', <<-FILE
module ApplicationHelper
  def body_classes
    @body_classes ||= []
  end
end
FILE