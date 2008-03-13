require 'net/ssh'
require 'net/sftp/session'

module Net
  
  module SFTP
    # A convenience method for starting a standalone SFTP session. It will
    # start up an SSH session using the given arguments (see the documentation
    # for Net::SSH::Session for details), and will then start a new SFTP session
    # with the SSH session. This will block until the new SFTP is fully open
    # and initialized before returning it.
    #
    #   sftp = Net::SFTP.start("localhost", "user")
    #   sftp.upload! "/local/file.tgz", "/remote/file.tgz"
    #
    # If a block is given, it will be passed to the SFTP session and will be
    # called once the SFTP session is fully open and initialized. When the
    # block terminates, the new SSH session will automatically be closed.
    #
    #   Net::SFTP.start("localhost", "user") do |sftp|
    #     sftp.upload! "/local/file.tgz", "/remote/file.tgz"
    #   end
    def self.start(host, user, options={}, &block)
      session = Net::SSH.start(host, user, options)
      sftp = Net::SFTP::Session.new(session, &block).connect!

      sftp.loop if block_given?

      sftp
    ensure
      session.close if session && block_given?
    end
  end

end

class Net::SSH::Connection::Session
  # A convenience method for starting up a new SFTP connection on the current
  # SSH session. Blocks until the SFTP session is fully open, and then
  # returns the SFTP session.
  #
  #   Net::SSH.start("localhost", "user", "password") do |ssh|
  #     ssh.sftp.upload!("/local/file.tgz", "/remote/file.tgz")
  #     ssh.exec! "cd /some/path && tar xf /remote/file.tgz && rm /remote/file.tgz"
  #   end
  def sftp
    @sftp ||= Net::SFTP::Session.new(self).connect!
  end
end