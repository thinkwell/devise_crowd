module DeviseCrowdAuthenticatable

  class Logger
    def self.send(message, logger = Rails.logger)
      if logger && ::Devise.crowd_logger
        logger.add 0, "\e[36mCROWD:\e[0m #{message}"
      end
    end
  end

end
