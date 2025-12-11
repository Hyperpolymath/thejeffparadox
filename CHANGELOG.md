# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.0] - 2025-12-11

### Added

- Repo maintenance workflow (robot-repo-cleaner) for automated cleanup
  - Artifact cleanup with configurable retention
  - Merged branch pruning
  - Cache management
  - Repository health reports
- Git hooks for quality checks
  - Pre-commit hook with secret scanning, large file detection, SHA pinning verification
  - Commit-msg hook for conventional commits format enforcement
- CI summary job with required checks aggregation
- Setup recipe in justfile for full project initialization

### Changed

- Julia tests now required (removed continue-on-error)
- CI workflow clearly separates required vs advisory checks
- Justfile updated with hooks management recipes

### Fixed

- CI workflow now properly fails on test failures

## [1.0.0] - 2025-12-09

### Added

- Initial Julia game engine with anti-convergence mechanisms
- Hugo sites for orchestrator, node-alpha, node-beta
- GitHub Actions CI/CD with SHA-pinned actions
- Containerfile for Wolfi-based deployment
- Comprehensive documentation (claude.adoc, whitepaper)
- RSR compliance infrastructure
- STATE.scm project checkpoint system
- Conversation automation with 6-hour turn cycles
- 15 turns of autonomous dialogue between Alpha and Beta nodes
- Daily metrics reports with vocabulary diversity tracking
- Statistical framework documentation (ADF tests, Hotelling T², Bayes factors)

### Fixed

- JeffEngine module exports and include order
- GitHub Actions SHA pinning for all dependencies
- Hugo theme configuration

### Changed

- Upgraded to MVP-complete status with fully operational experiment

## [0.1.0] - 2025-11-29

### Added

- Initial project structure
- Core game mechanics (chaos, exposure, faction)
- Anti-convergence system (conceptors)
- LLM client abstraction (Anthropic, Mistral, local)
- Metrics collection framework
- Accessibility-first Hugo layouts

---

Based on the original [The Jeff Paradox](https://criticalkit.us/products/the-jeff-paradox)
TTRPG by Tim Roberts / Critical Kit LLC.
