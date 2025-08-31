# Contributing to Zotero Ruby Gem

First off, thank you for considering contributing to zotero-rb! It's people like you that make this gem a great tool for the Ruby community.

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues as you might find out that you don't need to create one. When you are creating a bug report, please include as many details as possible:

- **Use a clear and descriptive title**
- **Describe the exact steps which reproduce the problem**
- **Provide specific examples to demonstrate the steps**
- **Describe the behavior you observed after following the steps**
- **Explain which behavior you expected to see instead and why**
- **Include Ruby version, gem version, and OS information**

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

- **Use a clear and descriptive title**
- **Provide a step-by-step description of the suggested enhancement**
- **Provide specific examples to demonstrate the steps**
- **Describe the current behavior and explain which behavior you expected to see instead**
- **Explain why this enhancement would be useful**

### Pull Requests

1. Fork the repo and create your branch from `main`
2. If you've added code that should be tested, add tests
3. If you've changed APIs, update the documentation
4. Ensure the test suite passes
5. Make sure your code lints
6. Issue that pull request!

## Development Process

### Setting Up Your Development Environment

1. Fork and clone the repository
2. Install dependencies:
   ```bash
   bin/setup
   ```
3. Run the tests to make sure everything is working:
   ```bash
   bundle exec rake
   ```

### Development Workflow

1. **Create a new branch** for your feature or bug fix:
   ```bash
   git checkout -b feature/my-new-feature
   ```

2. **Write your code** following our coding standards (see below)

3. **Add or update tests** for your changes:
   ```bash
   bundle exec rspec spec/path/to/your_spec.rb
   ```

4. **Run the full test suite** to ensure nothing is broken:
   ```bash
   bundle exec rake spec
   ```

5. **Run the linter** to ensure code quality:
   ```bash
   bundle exec rubocop
   ```

6. **Generate documentation** to ensure it builds correctly:
   ```bash
   bundle exec yard doc
   ```

7. **Run all quality checks**:
   ```bash
   bundle exec rake quality
   ```

### Coding Standards

We follow standard Ruby conventions and use RuboCop to enforce code style:

- **Follow the Ruby Style Guide**
- **Use meaningful variable and method names**
- **Write clear, concise comments for complex logic**
- **Keep methods small and focused**
- **Write comprehensive tests for new functionality**

#### Code Style

- Use 2 spaces for indentation
- Keep lines under 120 characters
- Use double quotes for strings
- Follow RuboCop rules (see `.rubocop.yml`)

#### Documentation

- Use YARD documentation format
- Document all public methods and classes
- Include usage examples where helpful
- Update README.md for user-facing changes

### Testing

We use RSpec for testing and aim for comprehensive test coverage:

- **Unit tests** for individual classes and methods
- **Integration tests** for API interactions (using VCR)
- **Test edge cases** and error conditions
- **Mock external dependencies** appropriately

#### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/zotero/client_spec.rb

# Run tests with coverage
bundle exec rspec --format documentation

# Run quality checks (tests + linting + docs)
bundle exec rake quality
```

### Git Workflow

1. **Keep your fork up to date** with the upstream repository
2. **Create feature branches** from `main`
3. **Write clear commit messages** following conventional commit format:
   - `feat: add new API endpoint for collections`
   - `fix: resolve rate limiting issue`
   - `docs: update installation instructions`
   - `test: add specs for authentication`
4. **Keep commits focused** - one logical change per commit
5. **Rebase your branch** before submitting PR if needed

### Development Tasks

We track all development work in [TASKS.md](TASKS.md). If you're looking for something to work on:

1. Check the current phase we're working on
2. Look for unchecked items in that phase
3. Consider starting with smaller, well-defined tasks
4. Ask questions if anything is unclear

Current development phases:
- ✅ **Phase 1: Foundation** - Complete
- 🚧 **Phase 2: Core API Client** - Next up
- 📋 **Phase 3: Zotero API Features** - Coming soon

## Release Process

Releases are managed by maintainers following semantic versioning:

1. Update version in `lib/zotero/version.rb`
2. Update `CHANGELOG.md`
3. Create release PR
4. Tag release after merge
5. Publish to RubyGems

## Recognition

Contributors are recognized in:
- GitHub contributors list
- Changelog entries
- Release notes

## Questions?

Don't hesitate to ask questions by:
- Opening an issue for discussion
- Joining the Zotero community forums
- Contacting the maintainers

## License

By contributing to zotero-rb, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to zotero-rb! 🙏