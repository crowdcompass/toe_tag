# `toe_tag`

Ruby's default exception handling is strictly based on module and class inheritance. `toe_tag` provides
additional utilities for creating your own exception groups, narrowing exceptions based on message, and
executing arbitrary blocks to determine whether an exception should be caught -- all within the familiar
rescue syntax.

## Usage

    require 'toe_tag'

    # Exception grouping:
    # Note that not all of the constants have to be defined. Missing ones will be ignored.
    DatabaseError = ToeTag.category %w[ActiveRecord::JDBCError PG::Error ActiveRecord::StatementInvalid]

    begin
      leaky_database_call
    rescue DatabaseError => err
      # err could be any of the listed classes
    end

    # Filtering by message:
    SpuriousError = DatabaseError.with_message(/spurious|pointless|meaningless/)

    begin
      boring_database_call # ! raises PG::Error, "something spurious happened"
    rescue SpuriousError
      log "something spurious happened, ignore it"
    rescue DatabaseError
      log "watch out, something bad happened"
    end

    # Filtering by proc
    class FancyError
      attr_reader :error_code

      def initialize(message, error_code)
        super message
        @error_code = error_code
      end
    end

    FancierError = FancyError.with_proc{|e| e.error_code = 123 }

    begin
      fancy_api_call
    rescue FancierError
      log "it's one of those 123 errors again"
    rescue FancyError
      log "some unknown error, reraising"
      raise
    end

## Installation

Add this line to your application's Gemfile:

    gem 'toe_tag'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install toe_tag

## Contributing

1. Fork it.
2. Create your feature branch (`git checkout -b my-new-feature`).
3. Commit your changes (`git commit -am 'Add some feature'`).
4. Push to the branch (`git push origin my-new-feature`).
5. Submit a pull request.
