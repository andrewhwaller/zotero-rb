# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 1.0.0 (2025-09-04)


### Bug Fixes

* add id-token permission for release-please ([dda7149](https://github.com/andrewhwaller/zotero-rb/commit/dda71492c73adc428e6b2ccbdca1665455c8dc9c))
* update release workflow to use Ruby 3.2 for ERB compatibility ([5698182](https://github.com/andrewhwaller/zotero-rb/commit/56981828d0c242b674059526afb81dc2f99071fc))
* update Ruby version requirements for ERB compatibility ([c6262fb](https://github.com/andrewhwaller/zotero-rb/commit/c6262fb43c49ebc2b615bca641d02c752eb9fd71))

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
