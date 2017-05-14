# HttpHook

require 'jsonclient'

PROTO='http'
HOST='localhost'
PORT=3000
PATH='hookhandler'

def hh(action , msg)

  uri = "#{PROTO}://#{HOST}:#{PORT}/#{PATH}/#{msg['exid']}/#{action}"
  JSONClient.new.put(uri, { message: msg, })

  logger = Logger.new($stdout)
  logger.level = Logger::DEBUG
  logger.datetime_format = "%Y-%m-%d %H:%M:%S"

  logger.info("HttpHook: #{action} for #{msg['exid']}")
end

class LaunchedHook
  def on(msg)

    hh('launched', msg)

    [] # return empty list of new messages
  end
end

class ReturnedHook
  def on(msg)

    hh('returned', msg)

    [] # return empty list of new messages
  end
end

class TerminatedHook

  def on(msg)

    hh('terminated', msg)

    [] # return empty list of new messages
  end
end

class ErrorHook
  def on(msg)

    hh('error', msg)

    [] # return empty list of new messages
  end
end
