# frozen_string_literal: true

require_relative "lib/zotero/version"

Gem::Specification.new do |spec|
  spec.name = "zotero-rb"
  spec.version = Zotero::VERSION
  spec.authors = ["Andrew Waller"]
  spec.email = ["48367637+andrewhwaller@users.noreply.github.com"]

  spec.summary = "A Ruby client for the Zotero Web API v3"
  spec.description = "A Ruby client for the Zotero Web API v3, supporting authentication and library management."
  spec.homepage = "https://github.com/andrewhwaller/zotero-rb"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/andrewhwaller/zotero-rb"
  spec.metadata["changelog_uri"] = "https://github.com/andrewhwaller/zotero-rb/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "faraday", "~> 2.0"
  spec.add_dependency "faraday-retry", "~> 2.0"
  spec.add_dependency "oauth", "~> 1.1"
end
