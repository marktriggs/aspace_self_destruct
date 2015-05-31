ArchivesSpace::Application.routes.draw do

  match('/self_destruct' => 'self_destruct#boom', :via => [:post])

end
