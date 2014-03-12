require "toe_tag/version"

module ToeTag

  module Util
    def self.try_constantize(name)
      if RUBY_VERSION >= "2.0.0"
        Object.const_get name
      else
        eval name
      end
    rescue NameError
      # const doesn't exist, just return nil
    end
  end

  module ExceptionBehavior
    def with_message(message)
      MessageSpec.new(message, self)
    end
  end

  class ExceptionSpec < Module
    include ExceptionBehavior
  end

  # Aggregates multiple exception classes into one single logical type. Intended
  # to be used in rescue clauses, for cases where different underlying implementations
  # may bubble up different exceptions meaning the same thing.
  #
  # The recommended usage is to assign these to constants and treat them as a sort of
  # meta-exception. This may be useful in combination with ExceptionMessageCatcher.
  # 
  # @example
  #   ErrorA = Class.new(StandardError)
  #   ErrorB = Class.new(StandardError)
  #   ErrorC = Class.new(StandardError)
  #
  class CategorySpec < ExceptionSpec
    attr_reader :exceptions

    def initialize(*exceptions)
      self.exceptions = exceptions.flatten.freeze
    end

    def ===(except)
      exceptions.any?{|exc| exc === except }
    end

    # Accepts a list of exception classes or names of exception classes and returns
    # an ExceptionCategory covering those exception classes. If a name is provided,
    # it is converted to a constant. If the constant doesn't exist, the name is ignored.
    # This allows the creation of an ExceptionCategory covering multiple exception
    # types that may not all be loaded in a given environment.
    #
    # @example
    #   DatabaseError = ExceptionCategory.category %w[ActiveRecord::JDBCError PG::Error]
    def self.category(*names)
      names = names.flatten.map{|except_name|
        if except_name.kind_of?(String)
          Util.try_constantize(except_name)
        else
          except_name
        end
      }.compact
      new(*names)
    end

    private

    attr_writer :exceptions
  end

  def self.category(*names)
    CategorySpec.category(*names)
  end

  # Wraps an exception class to allow matching against the message, too. Intended
  # to be used in rescue clauses, for cases where one exception class 
  # (ActiveRecord::StatementInvalid, I'm looking at you) represents a host of 
  # underlying issues.
  #
  # The recommended usage is to assign these to constants and treat them as a sort
  # of meta-exception. This may be useful in combination with ExceptionCategory.
  #
  # @example
  #   BogusError = ExceptionMessageCatcher.new(/bogus/)
  #
  #   begin
  #     raise "bogus error man"
  #   rescue BogusError => err
  #     p err
  #   end
  #
  class MessageSpec < ExceptionSpec
    
    def initialize(message, exception = StandardError)
      self.exception = exception
      self.message   = message
    end

    def ===(except)
      exception === except && message === except.message
    end

    private

    attr_accessor :exception, :message

    def message=(val)
      if val.kind_of?(String)
        @message = /#{val}/
      else
        @message = val
      end
    end

  end

  def self.with_message(message)
    MessageSpec.new(message)
  end

end

class Exception
  extend ToeTag::ExceptionBehavior
end
