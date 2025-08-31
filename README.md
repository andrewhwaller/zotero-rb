# Zotero Ruby Gem

[![Gem Version](https://badge.fury.io/rb/zotero-rb.svg)](https://badge.fury.io/rb/zotero-rb)
[![CI](https://github.com/andrewhwaller/zotero-rb/actions/workflows/main.yml/badge.svg)](https://github.com/andrewhwaller/zotero-rb/actions/workflows/main.yml)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop/rubocop)

A comprehensive Ruby client for the [Zotero Web API v3](https://www.zotero.org/support/dev/web_api/v3/start). This gem provides a clean, idiomatic Ruby interface for interacting with Zotero libraries, items, collections, tags, and more.

## Features

- 🔐 **Full Authentication Support** - API keys and OAuth flow
- 📚 **Complete API Coverage** - Items, collections, tags, searches, and file attachments
- 🔄 **Rate Limiting & Retries** - Built-in handling of API limits with exponential backoff
- 🧪 **Comprehensive Testing** - Extensive test suite with VCR for API mocking
- 📖 **Rich Documentation** - Detailed docs with examples and best practices
- 🚀 **Modern Ruby** - Supports Ruby 3.1+ with modern features
- 🔧 **Developer Friendly** - Great error messages and debugging tools

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'zotero-rb'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install zotero-rb
```

## Quick Start

```ruby
require 'zotero'

# Configure the client
Zotero.configure do |config|
  config.api_key = 'your-api-key-here'
end

# Create a client instance
client = Zotero.new

# Or pass the API key directly
client = Zotero.new(api_key: 'your-api-key')
```

## Authentication

### API Key Authentication (Recommended)

1. Go to [Zotero Settings](https://www.zotero.org/settings/keys) and create a new private key
2. Set the permissions you need (read library, write library, etc.)
3. Use the key in your configuration:

```ruby
Zotero.configure do |config|
  config.api_key = 'your-private-api-key'
end
```

### OAuth Authentication

For applications that need to authenticate on behalf of users:

```ruby
# This will be implemented in Phase 2
# OAuth flow will be available for web applications
```

## Usage Examples

### Working with Libraries

```ruby
# Get user library info
client = Zotero.new(api_key: 'your-key')

# This functionality will be available in Phase 3
# library = client.library.get(user_id: 12345)
```

### Managing Items

```ruby
# This functionality will be available in Phase 3
# items = client.items.list
# item = client.items.get('ABCD1234')
# new_item = client.items.create(title: 'My Paper', item_type: 'journalArticle')
```

### Collections and Tags

```ruby
# This functionality will be available in Phase 3
# collections = client.collections.list
# tags = client.tags.list
```

## Configuration

```ruby
Zotero.configure do |config|
  config.api_key = 'your-api-key'           # Your Zotero API key
  config.base_url = 'https://api.zotero.org' # API base URL (default)
  config.timeout = 30                       # Request timeout in seconds
  config.logger = Logger.new(STDOUT)        # Custom logger (optional)
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies.

### Running Tests

```bash
# Run the test suite
bundle exec rake spec

# Run with coverage
bundle exec rspec

# Run linting
bundle exec rubocop
```

### Running Quality Checks

```bash
# Run all quality checks (tests, linting, documentation)
bundle exec rake quality
```

### Interactive Console

```bash
# Start an interactive console with the gem loaded
bundle exec rake console
```

### Documentation

Generate documentation locally:

```bash
bundle exec yard doc
open doc/index.html
```

## Roadmap

This gem is under active development. Here's what's planned:

### ✅ Phase 1: Foundation (Current)
- [x] Basic gem structure and configuration
- [x] Authentication support
- [x] Error handling framework
- [x] Testing and CI setup
- [x] Documentation foundation

### 🚧 Phase 2: Core API Client (Next)
- [ ] HTTP client with rate limiting
- [ ] Request/response handling
- [ ] Retry logic and error recovery

### 📋 Phase 3: Zotero API Features (Planned)
- [ ] Items management (CRUD)
- [ ] Collections support
- [ ] Tags functionality  
- [ ] Search capabilities
- [ ] Library operations

### 🚀 Phase 4: Advanced Features (Future)
- [ ] File uploads and attachments
- [ ] Syncing capabilities
- [ ] Full-text content access
- [ ] Streaming API support
- [ ] Pagination handling

### 💎 Phase 5: Polish & Optimization (Future)
- [ ] Performance optimizations
- [ ] Advanced configuration options
- [ ] Comprehensive documentation
- [ ] Ruby 3+ specific features

See [TASKS.md](TASKS.md) for detailed development tasks and progress tracking.

## API Reference

Full API documentation is available at: [https://rubydoc.info/gems/zotero-rb](https://rubydoc.info/gems/zotero-rb)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/andrewhwaller/zotero-rb.

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## Versioning

We use [Semantic Versioning](https://semver.org/) for releases. For the versions available, see the [tags on this repository](https://github.com/andrewhwaller/zotero-rb/tags).

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed list of changes and releases.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Related Projects

- [zotero-api-client](https://github.com/zotero/zotero-api-client-js) - Official JavaScript client
- [pyzotero](https://github.com/urschrei/pyzotero) - Python client
- [libZotero](https://github.com/fcheslack/libZotero) - PHP client

## Support

- 📖 [Documentation](https://rubydoc.info/gems/zotero-rb)
- 🐛 [Issue Tracker](https://github.com/andrewhwaller/zotero-rb/issues)
- 💬 [Zotero Forums](https://forums.zotero.org/)
- 📧 [Zotero Dev Mailing List](https://groups.google.com/g/zotero-dev)

---

**Built with ❤️ for the Zotero community**