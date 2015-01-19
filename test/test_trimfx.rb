# Copyright (C) 2013-2015 all contributors <dtas-all@nongnu.org>
# License: GPLv3 or later (https://www.gnu.org/licenses/gpl-3.0.txt)
require './test/helper'
require 'dtas/trimfx'
require 'dtas/format'
require 'yaml'

class TestTrimFX < Testcase
  def rate
    44100
  end

  def test_example
    ex = YAML.load(File.read("examples/trimfx.sample.yml"))
    effects = []
    ex["effects"].each do |line|
      words = Shellwords.split(line)
      case words[0]
      when "trim"
        tfx = DTAS::TrimFX.new(words)
        assert_equal 52 * rate, tfx.tbeg
        assert_equal rate, tfx.tlen
        effects << tfx
      end
    end
    assert_equal 4, effects.size
  end

  def test_all
    tfx = DTAS::TrimFX.new(%w(all))
    assert_equal 0, tfx.tbeg
    assert_nil tfx.tlen
    assert_equal [], tfx.to_sox_arg
  end

  def test_time
    tfx = DTAS::TrimFX.new(%w(trim 2:30 3.1))
    assert_equal 150 * rate, tfx.tbeg
    assert_equal((3.1 * rate).round, tfx.tlen)
  end

  def test_to_sox_arg
    tfx = DTAS::TrimFX.new(%w(trim 1 0.5))
    assert_equal %w(trim 44100s 22050s), tfx.to_sox_arg

    tfx = DTAS::TrimFX.new(%w(trim 1 sox vol -1dB))
    assert_equal %w(trim 44100s), tfx.to_sox_arg
  end

  def test_tfx_effects
    tfx = DTAS::TrimFX.new(%w(trim 1 sox vol -1dB))
    assert_equal %w(sox $SOXIN $SOXOUT $TRIMFX vol -1dB), tfx.cmd
  end

  def test_schedule_simple
    fx = [
      DTAS::TrimFX.new(%w(trim 1 0.3)),
      DTAS::TrimFX.new(%w(trim 2 0.2)),
      DTAS::TrimFX.new(%w(trim 0.5 0.5)),
    ].shuffle
    ary = DTAS::TrimFX.schedule(fx)
    assert_operator 1, :==, ary.size
    assert_equal [ 22050, 44100, 88200 ], ary[0].map(&:tbeg)
    assert_equal [ 22050, 13230, 8820 ], ary[0].map(&:tlen)
  end

  def test_schedule_overlaps
    fx = [
      DTAS::TrimFX.new(%w(trim 1 0.3 sox)),
      DTAS::TrimFX.new(%w(trim 1.1 0.2 sox)),
      DTAS::TrimFX.new(%w(trim 0.5 0.5 sox)),
    ]
    ary = DTAS::TrimFX.schedule(fx)
    assert_equal 2, ary.size
    assert_equal [ 22050, 44100 ], ary[0].map(&:tbeg)
    assert_equal [ 48510 ], ary[1].map(&:tbeg)

    ex = DTAS::TrimFX.expand(fx, 10 * rate)
    assert_equal 2, ex.size
    assert_equal 0, ex[0][0].tbeg
    assert_equal 3, ex[0].size
    assert_equal 0, ex[1][0].tbeg
    assert_equal 3, ex[1].size
  end
end
