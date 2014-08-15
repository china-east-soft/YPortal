module DebugLog
  # get log message
  def DebugLog.log_message
    @log_message ||= {}
  end

  # write the log information to log file
  def DebugLog.write_log
    Logger.new("#{Rails.root}/log/debug.log").add Logger::INFO, log_message.pretty_inspect
    @log_message = {}
  end

  # add log message
  def DebugLog.add_to_log need_log_message = {}
    log_message.merge! need_log_message
  end
end

