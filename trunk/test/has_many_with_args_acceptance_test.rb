require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), '../../../../config/environment')
require 'has_many_with_args'
require 'mocha'

class User < ActiveRecord::Base
  attr_accessor :name
end

class Whisper < ActiveRecord::Base
end

class HasManyWithArgsAcceptanceTest < Test::Unit::TestCase

  # Harness for testing ClassMethods internal functions without mixing into ActiveRecord::Base
  class ClassHarness
    include Dweebd::HasManyWithArgs::ClassMethods
  end

  def test_should_require_class_name
    exception = assert_raise(ArgumentError) do
      User.has_many_with_args :whispers_for, :user
    end

    assert_equal 'Must specify class name of association objects.  Use :class_name in has_many_with_args options', exception.message
  end

  def test_should_require_at_least_one_argument
    exception = assert_raise ArgumentError do
      User.has_many_with_args :whispers_for
    end

    assert_equal 'Must specify at least one argument for association to take', exception.message
  end

  def test_should_require_dynamic_interpolation_of_argument
    exception = assert_raise ArgumentError do
      User.has_many_with_args :whispers_for, :user, :class_name => 'Whisper'
    end

    assert_equal 'At least one option must include a dynamic interpolation of the user argument', exception.message
  end

  def test_should_allow_direct_interpolation_of_argument
    User.has_many_with_args :whispers_for, :user,  :class_name => 'Whisper',
      :conditions => '#{user}'
  end

  def test_interpolate_single_value
    harness = ClassHarness.new
    assert_equal '#{replacement}', harness.interpolate_value('#{original}', 'original', 'replacement')
  end

  def test_interpolate_multiple_values
    harness = ClassHarness.new
    assert_equal '#{replacement} #{replacement}', harness.interpolate_value('#{original} #{original}', 'original', 'replacement')
  end

  def test_interpolate_mixed_values
    harness = ClassHarness.new
    assert_equal '#{replacement} #{replacement.method}', harness.interpolate_value('#{original} #{original.method}', 'original', 'replacement')
  end

  def test_should_not_interpolate_non_dynamic_values
    harness = ClassHarness.new
    assert_equal nil, harness.interpolate_value('#{original', 'original', 'replacement')
  end

  def test_remapped_options
    harness = ClassHarness.new
    input = { :class_name => 'Whisper', :conditions => '#{user}' }
    output = { :class_name => 'Whisper', :conditions=> '#{has_many_with_args_whispers_for_reader_user}' }
    args_and_accessors = { 'user' => 'has_many_with_args_whispers_for_reader_user' }
    assert_equal output, harness.remapped_options( input, args_and_accessors )
  end

  def test_should_allow_array_conditions
    assert_nothing_raised do
      User.has_many_with_args :whispers_for, :user, :class_name => 'Whisper',
        :conditions => [ 'sender_id = ?', '#{user.id}' ]
    end
  end

  def test_should_allow_hash_conditions
    assert_nothing_raised do
      User.has_many_with_args :whispers_for, :user, :class_name => 'Whisper',
        :conditions => { :sender_id => '#{user.id}' }
    end
  end

  def test_should_allow_methods_on_interpolated_argument
    assert_nothing_raised do
      User.has_many_with_args :whispers_for, :user, :class_name => 'Whisper',
        :conditions => '#{user.id}'
    end
  end

  def test_should_support_association_extensions
    User.has_many_with_args(:whispers_for, :user,
      :class_name => 'Whisper', :conditions => '#{user.name}') do
      def recent
      end
    end
    assert User.new.whispers_for(User.new).respond_to?(:recent)
  end

  def test_generated_sql
    User.has_many_with_args(:whispers_for, :user,
      :class_name => 'Whisper', :conditions => [ 'sender_id = ?', '#{user.id}' ]
    )
    user1 = User.new(:name => 'user 1')
    user2 = User.new(:name => 'user 2')

    # TODO: Where does the SQL come out?
    user1.whispers_for(user2)
  end

end
