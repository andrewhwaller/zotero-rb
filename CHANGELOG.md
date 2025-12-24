# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0](https://github.com/andrewhwaller/zotero-rb/compare/v0.2.0...v0.3.0) (2025-12-24)


### Features

* Add automatic retry with exponential backoff ([bb78859](https://github.com/andrewhwaller/zotero-rb/commit/bb7885948d388445b156bb69a560134875923fb5))
* Add library ID validation ([b667267](https://github.com/andrewhwaller/zotero-rb/commit/b6672671d6d1141c900466547ffe5125757fb542))
* Add ParseError and enhance RateLimitError ([813c533](https://github.com/andrewhwaller/zotero-rb/commit/813c533c0892b8286617ac9e0cef39dc5452d4e4))


### Bug Fixes

* Resolve file handle leak in file uploads ([75f8319](https://github.com/andrewhwaller/zotero-rb/commit/75f8319b6a43b7902d32781beeca3987cce73dbf))

## [0.1.5](https://github.com/andrewhwaller/zotero-rb/compare/v0.1.4...v0.1.5) (2025-09-11)


### Bug Fixes

* correct test expectations for refactored parameter signature ([eaad0bb](https://github.com/andrewhwaller/zotero-rb/commit/eaad0bbd0ce87cbe640b4ca7190759170ac11494))
* Correct test method calls to match API signatures ([76dd63e](https://github.com/andrewhwaller/zotero-rb/commit/76dd63e4d6e36c18629c377d7084efc8c6159560))

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
