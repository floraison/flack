
$: << 'lib'
require 'flack'


run Flack::App.new('envs/dev')

#map '/flack' do
#  run Flack::App.new('envs/dev')
#end
  # to "mount" the Flack app on /flack

