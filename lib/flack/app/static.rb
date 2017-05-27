
# /static/+
#
class Flack::App

  RACK_FILE = Rack::File.new(
    File.absolute_path(
      File.join(
        File.dirname(__FILE__), '..')))

  def get_static_plus(env)

    RACK_FILE.call(env)
  end
end

