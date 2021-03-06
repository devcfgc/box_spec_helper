# -*- encoding : utf-8 -*-

# This source file contains copied and modified source file snippets from
# rspec-core 3.1.7, which is available under an MIT Expat license.
# For details, see:
#
# - <https://github.com/rspec/rspec-core/tree/v3.1.7>
# - LICENSE-rspec-core-3.1.7 or <https://github.com/rspec/rspec-core/blob/v3.1.7/License.txt>
# - <https://github.com/rspec/rspec-core/blob/v3.1.7/spec/support/matchers.rb>
#
# Snippets are noted in the comments.


# Copy of `pass` from <https://github.com/rspec/rspec-core/blob/v3.1.7/spec/support/matchers.rb>,
# but with a more verbose `failure_reason`.
RSpec::Matchers.define :pass do
  match do |example|
    failure_reason(example).nil?
  end

  failure_message do |example|
    "expected example to pass, but #{failure_reason(example)}"
  end

  def failure_reason(example)
    result = example.metadata[:execution_result]
    case
      when example.metadata[:pending] then "was pending with message: #{result.pending_message}"
      when result.status != :passed then
        exception = unless result.exception.nil?
          ": #{result.exception}"
        else
          ''
        end
        result.status.to_s + exception
      else nil
    end
  end
end

#Based on `fail_with` from <https://github.com/rspec/rspec-core/blob/v3.1.7/spec/support/matchers.rb>
RSpec::Matchers.define :fail_with_regexp do |message|
  message = Regexp.escape(message) if message.is_a?(String)

  match do |example|
    failure_reason(example, message).nil?
  end

  failure_message do |example|
    "expected example to fail with exception message #{message.inspect}\n    but #{failure_reason(example, message)}"
  end

  def failure_reason(example, message)
    result = example.metadata[:execution_result]
    case
      when example.metadata[:pending] then "was pending with message: #{result.pending_message}"
      when result.status != :failed then result.status.to_s
      when got_failure_message(example).match(message).nil? then "got: #{got_failure_message(example)}"
      else nil
    end
  end

  def got_failure_message(example)
    unless example.exception.nil? then example.exception.message else '' end
  end
end

#Based on `be_skipped_with` from <https://github.com/rspec/rspec-core/blob/v3.1.7/spec/support/matchers.rb>
RSpec::Matchers.define :be_skipped_with_regexp do |message|
  message = Regexp.escape(message) if message.is_a?(String)

  match do |example|
    failure_reason(example, message).nil?
  end

  failure_message do |example|
    "expected: example skipped with #{message.inspect}\n     got: #{failure_reason(example, message)}"
  end

  def failure_reason(example, message)
    result = example.metadata[:execution_result]
    if !example.pending?
      if result.status == :passed then 'passed' else result.exception.message end
    elsif !example.skipped? then result.status
    elsif result.pending_message.match(message).nil? then result.pending_message
    else nil
    end
  end
end

# Remainder of file copied from <https://github.com/rspec/rspec-core/blob/v3.1.7/spec/support/matchers.rb>

RSpec::Matchers.define :map_specs do |specs|
  match do |autotest|
    @specs = specs
    @autotest = prepare(autotest)
    autotest.test_files_for(@file) == specs
  end

  chain :to do |file|
    @file = file
  end

  failure_message do
    "expected #{@autotest.class} to map #{@specs.inspect} to #{@file.inspect}\ngot #{@actual.inspect}"
  end

  def prepare(autotest)
    find_order = @specs.dup << @file
    autotest.instance_exec { @find_order = find_order }
    autotest
  end
end

RSpec::Matchers.define :fail_with do |exception_klass|
  match do |example|
    failure_reason(example, exception_klass).nil?
  end

  failure_message do |example|
    "expected example to fail with a #{exception_klass} exception, but #{failure_reason(example, exception_klass)}"
  end

  def failure_reason(example, exception_klass)
    result = example.execution_result
    case
      when example.metadata[:pending] then "was pending"
      when result.status != :failed then result.status
      when !result.exception.is_a?(exception_klass) then "failed with a #{result.exception.class}"
      else nil
    end
  end
end

RSpec::Matchers.module_exec do
  alias_method :have_failed_with, :fail_with
  alias_method :have_passed, :pass
end

RSpec::Matchers.define :be_pending_with do |message|
  match do |example|
    example.pending? &&
    example.execution_result.status == :pending &&
    example.execution_result.pending_message == message
  end

  failure_message do |example|
    "expected: example pending with #{message.inspect}\n     got: #{example.execution_result.pending_message.inspect}"
  end
end

RSpec::Matchers.define :be_skipped_with do |message|
  match do |example|
    example.skipped? &&
    example.pending? &&
    example.execution_result.pending_message == message
  end

  failure_message do |example|
    "expected: example skipped with #{message.inspect}\n     got: #{example.execution_result.pending_message.inspect}"
  end
end

RSpec::Matchers.define :contain_files do |*expected_files|
  contain_exactly_matcher = RSpec::Matchers::BuiltIn::ContainExactly.new(expected_files.map { |f| File.expand_path(f) })

  match do |actual_files|
    files = actual_files.map { |f| File.expand_path(f) }
    contain_exactly_matcher.matches?(files)
  end

  failure_message { contain_exactly_matcher.failure_message }
  failure_message_when_negated { contain_exactly_matcher.failure_message_when_negated }
end

RSpec::Matchers.alias_matcher :a_file_collection, :contain_files
