# Copyright (C) 2013-2015 all contributors <dtas-all@nongnu.org>
# License: GPLv3 or later (https://www.gnu.org/licenses/gpl-3.0.txt)
require_relative '../dtas'
require 'shellwords'

# We always escape binary strings because paths on POSIX filesystems are
# encoding agnostic.  Shellwords.split does give UTF-8 strings, but nothing
# cares at that point if the encoding isn't valid (and it's right to not care,
# again, filesystems can use any byte value in names except '\0'.
module DTAS::XS # :nodoc:
  def xs(ary)
    Shellwords.join(ary.map(&:b))
  end
end
