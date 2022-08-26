class Den < Formula
  desc "Den is a CLI utility for working with docker-compose environments"
  version "1.0.0-beta.2"
  url "https://github.com/swiftotter/den/archive/1.0.0-beta.2.tar.gz"
  sha256 "79ad302af1fc87a7eeb4162b1da21527dd9218113ca4e9bed02a14c1838ea8b5"
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
