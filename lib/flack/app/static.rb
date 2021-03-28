# frozen_string_literal: true

# /*.html
# /*.css
# /*.js
#
class Flack::App

  STATIC_FILE = Rack::File.new(
    File.absolute_path(
      File.join(
        File.dirname(__FILE__), '..', 'static')))

  def serve_file(env)

    STATIC_FILE.call(env)
  end

  alias get_html_suffix serve_file
  alias get_css_suffix serve_file
  alias get_js_suffix serve_file
end

