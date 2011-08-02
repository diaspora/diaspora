require File.expand_path(File.join(File.dirname(__FILE__),'..','..','test_helper'))

class NewRelic::Agent::TransationSampleBuilderTest < Test::Unit::TestCase

  def setup
    @builder = NewRelic::Agent::TransactionSampleBuilder.new
  end

  def test_build_sample
    build_segment("a") do
      build_segment("aa") do
        build_segment("aaa")
      end
      build_segment("ab") do
        build_segment("aba") do
          build_segment("abaa")
        end
        build_segment("aba")
        build_segment("abc") do
          build_segment("abca")
          build_segment("abcd")
        end
      end
    end
    build_segment "b"
    build_segment "c" do
      build_segment "ca"
      build_segment "cb" do
        build_segment "cba"
      end
    end

    @builder.finish_trace(Time.now.to_f)
    validate_builder
  end

  def test_freeze
    build_segment "a" do
      build_segment "aa"
    end

    begin
      builder.sample
      assert false
    rescue Exception => e
      # expected
    end

    @builder.finish_trace(Time.now.to_f)

    validate_builder

    begin
      build_segment "b"
      assert_false
    rescue TypeError => e
      # expected
    end
  end

  # this is really a test for transaction sample
  def test_omit_segments_with
    build_segment "Controller/my_controller/index" do
      sleep 0.010

      build_segment "Rails/Application Code Loading" do
        sleep 0.020

        build_segment "foo/bar" do
          sleep 0.010
        end
      end

      build_segment "a" do
        build_segment "ab"
        sleep 0.010
      end
      build_segment "b" do
        build_segment "ba"
        sleep 0.05
        build_segment "bb"
        build_segment "bc" do
          build_segment "bca"
          sleep 0.05
        end
      end
      build_segment "c"
    end
    @builder.finish_trace(Time.now.to_f)

    validate_builder false

    sample = @builder.sample

    should_be_a_copy = sample.omit_segments_with('OMIT NOTHING')
    validate_segment should_be_a_copy.root_segment, false

    assert sample.to_s == should_be_a_copy.to_s

    without_code_loading = sample.omit_segments_with('Rails/Application Code Loading')
    validate_segment without_code_loading.root_segment, false

    # after we take out code loading, the delta should be approximately
    # 30 milliseconds
    delta = (sample.duration - without_code_loading.duration) * 1000

    # Need to allow substantial headroom on the upper bound to prevent
    # spurious errors.
    assert delta >= 28, "delta #{delta} should be between 28 and 100"
    # disable this test for a couple days:
    assert delta <= 100, "delta #{delta} should be between 28 and 100"

    # ensure none of the segments have this regex
    without_code_loading.each_segment do |segment|
      assert_nil segment.metric_name =~ /Rails\/Application Code Loading/
    end
  end
  def test_unbalanced_handling
    assert_raise RuntimeError do
      build_segment("a") do
        begin
          build_segment("aa") do
            build_segment("aaa") do
              raise "a problem"
            end
          end
          rescue; end
      end
    end
  end
  def test_marshal
    build_segment "a" do
      build_segment "ab"
    end
    build_segment "b" do
      build_segment "ba"
      build_segment "bb"
      build_segment "bc" do
        build_segment "bca"
      end
    end
    build_segment "c"

    @builder.finish_trace(Time.now.to_f)
    validate_builder

    dump = Marshal.dump @builder.sample
    sample = Marshal.restore(dump)
    validate_segment(sample.root_segment)
  end

  def test_parallel_first_level_segments
    build_segment "a" do
      build_segment "ab"
    end
    build_segment "b"
    build_segment "c"

    @builder.finish_trace(Time.now.to_f)
    validate_builder
  end

  def validate_builder(check_names = true)
    validate_segment @builder.sample.root_segment, check_names
  end

  def validate_segment(s, check_names = true)
    p = s.parent_segment

    unless p.nil? || p.metric_name == 'ROOT'
      assert p.called_segments.include?(s)
      assert_equal p.metric_name.length, s.metric_name.length - 1, "p: #{p.metric_name}, s: #{s.metric_name}" if check_names
      assert p.metric_name < s.metric_name if check_names
      assert p.entry_timestamp <= s.entry_timestamp
    end

    assert s.exit_timestamp >= s.entry_timestamp

    children = s.called_segments
    last_segment = s
    children.each do |child|
      assert child.metric_name > last_segment.metric_name if check_names
      assert child.entry_timestamp >= last_segment.entry_timestamp
      last_metric = child

      validate_segment(child, check_names)
    end
  end

  def build_segment(metric, time = 0, &proc)
    @builder.trace_entry(metric, Time.now.to_f)
    proc.call if proc
    @builder.trace_exit(metric, Time.now.to_f)
  end
end
