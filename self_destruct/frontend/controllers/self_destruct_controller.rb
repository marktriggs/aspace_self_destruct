class SelfDestructController < ApplicationController

  set_access_control "manage_repository" => [:boom]

  def boom
    puts "Kerblam!"
    system("touch", File.join(ASUtils.find_base_directory, "self_destruct_time"))
  end

end
