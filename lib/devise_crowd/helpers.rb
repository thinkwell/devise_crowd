module DeviseCrowd
  # Executes the given block, returning nil if a SimpleCrowd::CrowdError
  # ocurrs.
  def self.crowd_fetch
    begin
      yield
    rescue SimpleCrowd::CrowdError => e
      DeviseCrowd::Logger.send "#{caller[1][/`.*'/][1..-2]}: #{e.message}"
      nil
    end
  end
end
