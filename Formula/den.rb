class Den < Formula
  desc "Den is a CLI utility for working with docker-compose environments"
  version "1.0.0-beta.5"
  url "https://github.com/swiftotter/den/archive/1.0.0-beta.5.tar.gz"
  sha256 "48fdac72cd1528bd9cd8574cb0b2d0185c1b3cc1fbdb4feb2debaaefb69deec5"
  head "https://github.com/swiftotter/den.git", :branch => "main"
  
  def install
    prefix.install Dir["*"]
  end
  
  def caveats
    <<~EOS
      Den manages a set of global services on the docker host machine. You
      will need to have Docker installed and docker-compose available in your
      local $PATH configuration prior to starting Den.

      To start warden simply run:

        den svc up

      This command will automatically run "den install" to setup a trusted
      local root certificate and sign an SSL certificate for use by services
      managed by warden via the "warden sign-certificate warden.test" command.

      To print a complete list of available commands simply run "den" without
      any arguments.
    EOS
  end
end
