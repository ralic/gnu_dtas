# Copyright (C) 2013-2015 all contributors <dtas-all@nongnu.org>
# License: GPLv3 or later (https://www.gnu.org/licenses/gpl-3.0.txt)
require_relative 'helper'
begin
  require 'dtas/mlib'
  require 'sequel/no_core_ext'
  require 'sqlite3'
rescue LoadError => err
  warn "skipping mlib test: #{err.message}"
  exit 0
end

class TestMlib < Testcase
  def setup
    @db = Sequel.sqlite(':memory:')
  end

  def test_migrate
    ml = DTAS::Mlib.new(@db)
    begin
      $-w = false
      ml.migrate
      tables = @db.tables
    ensure
      $-w = true
    end
    [ :nodes, :tags, :vals, :comments ].each do |t|
      assert tables.include?(t), "missing #{t}"
    end
  end
end