# Copyright (C) 2013-2015 all contributors <dtas-all@nongnu.org>
# License: GPLv3 or later (https://www.gnu.org/licenses/gpl-3.0.txt)
require './test/helper'
require 'dtas/util'

class TestUtil < Testcase
  include DTAS::Util
  def test_util
    orig = 6.0
    lin = db_to_linear(orig)
    db = linear_to_db(lin)
    assert_in_delta orig, db, 0.00000001
  end
end
