# frozen_string_literal: true

class Site
  def self.where(*args)
    [new]
  end

  def store
    Store.new
  end
end
