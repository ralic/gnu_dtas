# Copyright (C) 2013-2015 all contributors <dtas-all@nongnu.org>
# License: GPLv3 or later (https://www.gnu.org/licenses/gpl-3.0.txt)
# workaround for older Rubies: https://bugs.ruby-lang.org/issues/8770
module DTAS::SpawnFix # :nodoc:
  def spawn(*args)
    super(*args)
  rescue Errno::EINTR
    retry
  end if RUBY_VERSION.to_f <= 2.1
end
