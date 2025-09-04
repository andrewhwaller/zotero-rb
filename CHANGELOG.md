# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0](https://github.com/andrewhwaller/zotero-rb/compare/v0.1.2...v1.0.0) (2025-09-04)


### ⚠ BREAKING CHANGES

* Internal HTTP implementation migrated from HTTParty to Net::HTTP

### Features

* replace HTTParty with Net::HTTP to eliminate dependencies ([f1af7cc](https://github.com/andrewhwaller/zotero-rb/commit/f1af7ccd27cf401bd963062763b701f2b32ea923))


### Bug Fixes

* avoid Digest mocking to resolve CI RSpec environment issues ([94adc4a](https://github.com/andrewhwaller/zotero-rb/commit/94adc4a7edd6fd8362c9794f1b1826fd8dda5ec9))
* move digest require to top level for test compatibility ([c88a64b](https://github.com/andrewhwaller/zotero-rb/commit/c88a64b8972018b9e01682cd9f405f0d3b5f4fec))

## [0.1.2](https://github.com/andrewhwaller/zotero-rb/compare/v0.1.1...v0.1.2) (2025-09-04)


### Bug Fixes

* ensure Release Please only runs after CI passes ([eaf2493](https://github.com/andrewhwaller/zotero-rb/commit/eaf2493faf9f937b4b05af4afb5c09bbae41d3f7))
* remove HTTParty format :json and update dependencies ([894f090](https://github.com/andrewhwaller/zotero-rb/commit/894f090251a5a9add33cfc5cba8c39868e338070))

## [Unreleased]

## [0.1.0](https://github.com/andrewhwaller/zotero-rb/compare/v0.0.0...v0.1.0) (2025-09-04)

### Added
- Initial release of zotero-rb gem
- Full Zotero Web API v3 client with API key authentication
- Complete CRUD operations for items, collections, tags, and searches
- File upload and download support
- Fulltext content access
- Library synchronization features
- Metadata retrieval (item types, fields, creator types)
- Comprehensive error handling with custom exception classes
- Support for both user and group libraries
- Ruby 3.2+ compatibility
