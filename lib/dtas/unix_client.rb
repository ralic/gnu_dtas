# Copyright (C) 2013, Eric Wong <normalperson@yhbt.net> and all contributors
# License: GPLv3 or later (https://www.gnu.org/licenses/gpl-3.0.txt)
require_relative '../dtas'
require_relative 'xs'
require 'socket'
require 'io/wait'
require 'shellwords'
require_relative 'compat_rbx'

class DTAS::UNIXClient # :nodoc:
  attr_reader :to_io

  include DTAS::XS

  def self.default_path
    (ENV["DTAS_PLAYER_SOCK"] || File.expand_path("~/.dtas/player.sock")).b
  end

  def initialize(path = self.class.default_path)
    @to_io = Socket.new(:UNIX, :SEQPACKET, 0)
    @to_io.connect(Socket.pack_sockaddr_un(path))
  end

  def req_start(args)
    args = xs(args) if Array === args
    @to_io.send(args, Socket::MSG_EOR)
  end

  def req_ok(args, timeout = nil)
    res = req(args, timeout)
    res == "OK" or raise "Unexpected response: #{res}"
    res
  end

  def req(args, timeout = nil)
    req_start(args)
    res_wait(timeout)
  end

  def res_wait(timeout = nil)
    @to_io.wait(timeout)
    nr = @to_io.nread
    nr > 0 or raise EOFError, "unexpected EOF from server"
    @to_io.recvmsg[0]
  end
end
