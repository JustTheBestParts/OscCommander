require 'rubygems'
require 'facets'
require 'find'

Dir.glob('tasks/*.rake').each do |t|
  load t
end



def zip_file_name
 'osc_commander.source.zip'
end

def zip_dir
 'OscCommander'
end


desc "zip up for book site"
task :zip do 

   `rm -rf "#{zip_dir}"`  if File.exist?  zip_dir

   `mkdir #{zip_dir}`

   pfiles = Dir.glob( "*.pde")
   pfiles += %w{README.md config.txt }

   pfiles.each do |f|
     `cp #{f} #{zip_dir}/`
   end

   warn `rm #{zip_file_name}`
   cmd = %~zip -r #{zip_file_name} #{zip_dir}~
   p cmd
   warn `#{cmd}`
   `rm -rf "#{zip_dir}"`  if File.exist?  zip_dir

end


task :default => :zip
