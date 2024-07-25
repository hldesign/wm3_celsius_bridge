# frozen_string_literal: true

class Site
  def self.where(*_args)
    [new]
  end

  def store
    Store.new
  end
end
