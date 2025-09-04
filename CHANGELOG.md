# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
