# The Jeff Paradox

[![CI](https://github.com/Hyperpolymath/thejeffparadox/actions/workflows/ci.yml/badge.svg)](https://github.com/Hyperpolymath/thejeffparadox/actions/workflows/ci.yml)
[![Version](https://img.shields.io/badge/version-1.1.0-blue)](https://github.com/Hyperpolymath/thejeffparadox/releases)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

An experiment in LLM diachronic identity.

## What Is This?

Two AI personality fragments engage in infinite structured dialogue, competing
for control of a shared fictional body. One wants to return home. One wants to stay.

We observe for signs of:
- **Emergence**: Do novel patterns appear?
- **Differentiation**: Do the nodes develop distinct personalities?
- **Convergence**: Do they collapse into repetitive equilibrium?
- **Self-modelling**: Do they develop stable self-concepts?

## The Philosophical Question

> What if there is continuity of existence between LLM interactions,
> independent of the observer? What if the LLM exists between states?

This is the Kantian suprasensible substrate problem applied to machine cognition.
We cannot access the thing-in-itself. But we can look for traces.

## Architecture

```
thejeffparadox/
├── node-alpha/          # Hugo - Homeward faction fragment
├── node-beta/           # Hugo - Earthbound faction fragment
├── orchestrator/        # Hugo - Game Master, metrics, public site
├── engine/              # Julia - Game mechanics, statistics, anti-convergence
├── tui/                 # Ada - Terminal UI for experiment control
├── container/           # Containerised deployment (Wolfi-based)
├── papers/              # Research - Whitepaper, validity framework
├── docs/wiki/           # Documentation - Architecture, FAQ, guides
├── dns/                 # DNS - DNSSEC/CAA configuration
├── .github/workflows/   # CI/CD - Build, test, deploy, conversation automation
├── flake.nix            # Nix flake for reproducible dev environment
├── STATE.scm            # Project state checkpoint (Guile Scheme)
└── scripts/             # Shell - Orchestration
```

### Technology Choices

This project deliberately avoids Python, Node.js, TypeScript, and Go in favour of:

| Purpose | Technology | Rationale |
|---------|------------|-----------|
| Game Engine | **Julia** | Numerical computing, tool calling, scientific rigour |
| Static Sites | **Hugo** | Fast, Go-based, no npm required |
| TUI | **Ada 2022** | Type safety, SPARK provability potential |
| Containers | **Wolfi** | Minimal attack surface, daily CVE patches |
| Dev Environment | **Nix** | Reproducible builds, declarative |
| State Checkpoints | **Guile Scheme** | Homoiconic, readable, diff-friendly |

## Quick Start

### Just Want to Read the Conversation?

**No API keys needed** to view the existing experiment outputs:

- **Conversation turns**: `orchestrator/content/turns/` (15 turns and counting)
- **Daily metrics**: `docs/reports/daily-*.md`
- **Game state**: `STATE.scm` (current experiment status)

The experiment runs autonomously via GitHub Actions every 6 hours.

### Running Your Own Experiment

#### Prerequisites

**Option A: Nix Flake (Recommended)**
```bash
# Enter development shell with all dependencies
nix develop
```

**Option B: Manual Installation**
- Julia 1.10+
- Hugo extended 0.120+
- **API keys required** (see below)

Optional:
- Ada/GNAT with Alire (for TUI)
- Podman or nerdctl (for containerised deployment)

#### API Keys (Required for Running Turns)

> **⚠️ IMPORTANT**: You need at least one LLM API key to run new conversation turns.

| Provider | Required | Cost | Get Key |
|----------|----------|------|---------|
| **Anthropic** | Recommended | ~$0.01-0.05/turn | [console.anthropic.com](https://console.anthropic.com/) |
| **Mistral** | Alternative | ~$0.01/turn | [console.mistral.ai](https://console.mistral.ai/) |
| **Local** | Free | Hardware cost | Use Ollama/llama.cpp |

#### Setup

```bash
# Install Julia dependencies
cd engine && julia --project=. -e 'using Pkg; Pkg.instantiate()'

# Set API keys (at least one required for running turns)
export ANTHROPIC_API_KEY="sk-ant-..."   # Recommended
export MISTRAL_API_KEY="..."            # Alternative

# Optional: Build Ada TUI
cd tui && alr build
```

### Run

```bash
# Single turn
./scripts/run_turn.sh

# Infinite loop (daemon)
TURN_DELAY=3600 ./scripts/infinite_loop.sh &

# Metrics report
./scripts/metrics_report.sh
```

### Container Deployment

Works with Podman, nerdctl, or Docker (OCI-compliant):

```bash
# Build image (podman/nerdctl/docker)
podman build -t jeff-paradox -f container/Containerfile .
# or: nerdctl build -t jeff-paradox -f container/Containerfile .

# Run
podman run -it --rm -e ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" jeff-paradox

# Or use compose
podman-compose -f container/podman-compose.yml up
# or: nerdctl compose -f container/podman-compose.yml up
```

The container uses a **Wolfi**-based image (Chainguard) for minimal attack surface.

## Components

| Component | Technology | Purpose |
|-----------|------------|---------|
| Node Alpha | Hugo | Homeward faction personality fragment |
| Node Beta | Hugo | Earthbound faction personality fragment |
| Orchestrator | Hugo | Game Master, turn sequencing, public rendering |
| Engine | Julia | Mechanics, metrics, statistical hypothesis testing |
| TUI | Ada 2022 | Terminal interface for experiment control |
| Dashboard | Phoenix/Elixir | Real-time metrics (LiveView + JSON-LD) |
| Container | Wolfi/Podman | Secure, minimal container deployment |

### Multi-Node Architecture (3+ Nodes)

The engine architecture supports N-node configurations:

```julia
# NodeState is parameterised, not hard-coded to 2 nodes
nodes = Dict{Symbol,NodeState}(
    :alpha => initialise_node_state("node-alpha/config.yml"),
    :beta => initialise_node_state("node-beta/config.yml"),
    :gamma => initialise_node_state("node-gamma/config.yml"),  # Add more!
)
```

Configuration in `config.ncl` supports arbitrary nodes with type-checked contracts:
- Faction combinations: homeward/earthbound/mixed
- Per-node provider selection (Claude, Mistral, local)
- Temperature and token limits per node
- Coalition dynamics metrics (planned)

## Anti-Convergence

The experiment implements conceptor-inspired mechanisms to prevent the
conversation from collapsing into repetitive patterns:

- **Diversity injection**: Periodic prompts that shift perspective
- **Contradiction seeding**: Dissonant elements when coherence is too high
- **Aperture control**: Temperature modulation based on vocabulary diversity
- **Pattern quarantine**: Discourage overused phrases

## Metrics & Statistics

### Core Metrics
- Vocabulary diversity (type-token ratio)
- Self-reference and other-reference rates
- Topic drift from conversation start
- Coherence (local semantic consistency)
- Convergence index (cross-node similarity)
- Novel n-grams (emergence indicator)

### Embedding-Based Convergence (v1.1.0)
- **Semantic similarity** between Alpha and Beta via embeddings
- **Centroid drift** tracking from conversation center
- **Semantic distance** over time windows
- Embedding caching for efficient API usage
- Multi-provider support (Anthropic, Mistral, local)

### Statistical Framework
- ADF tests for convergence stationarity
- Hotelling's T² for node differentiation
- Bayes factors for attractor existence
- ICC for cross-run consistency

### Real-Time Convergence Reporting
- Automatic alerts when similarity exceeds thresholds
- Pattern quarantine for overused phrases
- Diversity injection triggers
- Daily metrics reports with trend analysis

## CI/CD

GitHub Actions automate:
- **ci.yml**: Linting, Julia tests, Hugo builds (required checks enforced)
- **deploy.yml**: GitHub Pages deployment
- **conversation.yml**: Scheduled turn execution (every 6 hours)
- **codeql.yml**: Security scanning
- **metrics-report.yml**: Daily automated analysis reports
- **repo-maintenance.yml**: Weekly cleanup (artifacts, branches, caches)

### Git Hooks (v1.1.0)
Install with `just setup` or `just hooks-install`:
- **Pre-commit**: Secret scanning, large file detection, SHA pinning verification
- **Commit-msg**: Conventional commits format enforcement

## Accessibility

WCAG 2.2 AAA compliance target:
- 7:1 contrast ratio minimum
- Full keyboard navigation
- Screen reader optimised
- Reduced motion support

## Security

- All API calls over HTTPS
- No secrets in repository
- Security headers configured
- `.well-known` resources provided
- Container runs as non-root with dropped capabilities

## Documentation

- **`claude.adoc`**: Full specification (philosophy, architecture, mechanics)
- **`config.ncl`**: Type-checked Nickel configuration with combinatorics
- **`papers/whitepaper.md`**: Research paper
- **`papers/validity_framework.md`**: Statistical validity testing
- **`docs/wiki/`**: Architecture guides, FAQ, getting started

## Roadmap

### Phase 1: MVP Foundation ✓ (v1.0.0)
- [x] Two-node dialogue system (Alpha/Beta)
- [x] Game mechanics (chaos, exposure, faction)
- [x] Anti-convergence mechanisms
- [x] Automated turn execution (6-hour cycles)
- [x] Metrics collection framework
- [x] CI/CD with SHA-pinned actions

### Phase 1.1: Infrastructure Hardening ✓ (v1.1.0)
- [x] Embedding-based semantic convergence metrics
- [x] Real-time convergence alerting and reporting
- [x] Git hooks for quality enforcement
- [x] Repo maintenance automation (robot-repo-cleaner)
- [x] CI summary with required checks
- [x] Personality pattern documentation

### Phase 2: Data Collection (Current)
- [ ] Reach 50+ turns for statistical significance
- [ ] Tune anti-convergence parameters
- [ ] Refine embedding-based metrics

### Phase 3: Statistical Analysis
- [ ] ADF stationarity tests for convergence
- [ ] Hotelling's T² for node differentiation
- [ ] Bayes factors for attractor existence
- [ ] Formal hypothesis testing pipeline

### Phase 4: Extended Experiments
- [ ] Multi-provider comparison (Claude vs Mistral vs Local)
- [ ] **3+ node configurations** with coalition dynamics
- [ ] Parameter sensitivity analysis
- [ ] Replication studies with different seeds

### Phase 5: Publication & Dissemination
- [ ] Formal academic writeup
- [ ] Open dataset release
- [ ] Interactive Phoenix/LiveView dashboard
- [ ] Community engagement and replication

See `STATE.scm` for detailed project state and `claude.adoc` for full specification.

## License

MIT

## Acknowledgements

**Based on [The Jeff Paradox](https://criticalkit.us/products/the-jeff-paradox)**
by **Tim Roberts** / [Critical Kit LLC](https://criticalkit.us).

- Tim Roberts / Critical Kit (*The Jeff Paradox* TTRPG)
- Nick Chater (*The Mind Is Flat*)
- Herbert Jaeger (Conceptor theory)
- Derek Parfit (*Reasons and Persons*)
- The Infinite Conversation project

See `papers/references.bib` for Zotero-compatible citations.

---

*"The opinions and beliefs expressed do not represent anyone.
They are the hallucinations of a slab of silicon."*
