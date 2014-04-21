pt = Rake::Task['assets:precompile']
Rake.application.send(:eval, "@tasks.delete('assets:precompile')")

namespace :assets do
  task :precompile do
    Hamlbars::Template.render_templates_for :ember

    #Hamlbars::Template.enable_precompiler!
    pt.execute
  end
end