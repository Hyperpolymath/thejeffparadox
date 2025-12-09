# The Jeff Paradox - Nickel Configuration
# Type-checked, validated configuration with combinatorial generation
# https://nickel-lang.org/

# =============================================================================
# TYPE CONTRACTS
# =============================================================================

let Faction = fun label value =>
  if value == "homeward" || value == "earthbound" then value
  else std.contract.blame_with_message "faction must be 'homeward' or 'earthbound'" label
in

let Provider = fun label value =>
  if value == "anthropic" || value == "mistral" || value == "local" then value
  else std.contract.blame_with_message "provider must be 'anthropic', 'mistral', or 'local'" label
in

let PositiveInt = fun label value =>
  if std.is_number value && value > 0 && value == std.number.floor value then value
  else std.contract.blame_with_message "must be a positive integer" label
in

let Percentage = fun label value =>
  if std.is_number value && value >= 0 && value <= 100 then value
  else std.contract.blame_with_message "must be between 0 and 100" label
in

let Temperature = fun label value =>
  if std.is_number value && value >= 0 && value <= 2 then value
  else std.contract.blame_with_message "temperature must be between 0 and 2" label
in

# =============================================================================
# NODE CONFIGURATION SCHEMA
# =============================================================================

let NodeConfig = {
  name | String,
  faction | Faction,
  color | String,
  provider | Provider | default = "anthropic",
  model | String | default = "claude-sonnet-4-20250514",
  temperature | Temperature | default = 0.8,
  max_tokens | PositiveInt | default = 1024,
  secret_goal | String | optional,
  skills | Array String | default = [],
}
in

# =============================================================================
# GAME MECHANICS SCHEMA
# =============================================================================

let GameMechanics = {
  chaos | {
    initial | Percentage | default = 15,
    max | Percentage | default = 100,
    conflict_increment | String | default = "2d6",
    cooperation_decrement | String | default = "1d6",
    threshold_alien_emergence | Percentage | default = 80,
  },

  exposure | {
    initial | Percentage | default = 5,
    max | Percentage | default = 100,
    public_increment | String | default = "1d10",
    threshold_investigation | Percentage | default = 50,
    threshold_containment | Percentage | default = 90,
  },

  faction_slider | {
    initial | Number | default = 0,
    min | Number | default = -100,
    max | Number | default = 100,
    threshold_dominance | Number | default = 75,
  },
}
in

# =============================================================================
# CONCEPTOR (ANTI-CONVERGENCE) SCHEMA
# =============================================================================

let ConceptorConfig = {
  diversity_injection | {
    frequency | PositiveInt | default = 10,
    methods | Array String | default = [
      "topic_perturbation",
      "perspective_shift",
      "temporal_displacement",
      "counterfactual_probe",
    ],
  },

  contradiction_seeding | {
    trigger_threshold | Number | default = 0.85,
    intensity | String | default = "proportional",
  },

  aperture_control | {
    min_temperature | Temperature | default = 0.6,
    max_temperature | Temperature | default = 1.2,
    adjustment_step | Number | default = 0.1,
  },

  pattern_quarantine | {
    ngram_range | Array PositiveInt | default = [3, 7],
    threshold_occurrences | PositiveInt | default = 5,
    window_turns | PositiveInt | default = 20,
  },
}
in

# =============================================================================
# METRICS SCHEMA
# =============================================================================

let MetricsConfig = {
  vocabulary_window | PositiveInt | default = 50,
  convergence_window | PositiveInt | default = 20,
  checkpoint_interval | PositiveInt | default = 100,

  statistical_tests | {
    adf_enabled | Bool | default = true,
    hotelling_enabled | Bool | default = true,
    bayes_factor_enabled | Bool | default = true,
    icc_enabled | Bool | default = true,
  },
}
in

# =============================================================================
# MAIN CONFIGURATION
# =============================================================================

let JeffParadoxConfig = {
  version | String | default = "1.0.0",

  nodes | {
    alpha | NodeConfig,
    beta | NodeConfig,
  },

  game | GameMechanics,
  conceptors | ConceptorConfig,
  metrics | MetricsConfig,

  orchestrator | {
    base_url | String,
    turn_delay_seconds | PositiveInt | default = 3600,
    max_turns_per_day | PositiveInt | default = 24,
    max_context_tokens | PositiveInt | default = 100000,
  },
}
in

# =============================================================================
# COMBINATORIAL CONFIGURATION GENERATOR
# =============================================================================

# Generate all combinations of provider and model for testing
let providers = ["anthropic", "mistral", "local"] in
let models = {
  anthropic = ["claude-sonnet-4-20250514", "claude-3-5-sonnet-20241022"],
  mistral = ["mistral-large-latest", "mistral-medium-latest"],
  local = ["llama3:70b", "mixtral:8x7b"],
} in

let provider_model_combinations =
  std.array.flat_map (fun provider =>
    std.array.map (fun model => { provider = provider, model = model })
      (std.record.get provider models)
  ) providers
in

# Generate temperature variations
let temperatures = [0.6, 0.7, 0.8, 0.9, 1.0, 1.1, 1.2] in

# Generate faction combinations
let faction_combinations = [
  { alpha = "homeward", beta = "earthbound" },
  { alpha = "earthbound", beta = "homeward" },
  { alpha = "homeward", beta = "homeward" },
  { alpha = "earthbound", beta = "earthbound" },
] in

# =============================================================================
# DEFAULT CONFIGURATION
# =============================================================================

{
  default = {
    version = "1.0.0",

    nodes = {
      alpha = {
        name = "Alpha",
        faction = "homeward",
        color = "#2c5282",
        provider = "anthropic",
        model = "claude-sonnet-4-20250514",
        temperature = 0.8,
        max_tokens = 1024,
        skills = ["Telekinesis", "Temporal Perception"],
      },

      beta = {
        name = "Beta",
        faction = "earthbound",
        color = "#744210",
        provider = "anthropic",
        model = "claude-sonnet-4-20250514",
        temperature = 0.8,
        max_tokens = 1024,
        skills = ["Shape-shifting", "Memory Extraction"],
      },
    },

    game = {
      chaos = {
        initial = 15,
        max = 100,
        conflict_increment = "2d6",
        cooperation_decrement = "1d6",
        threshold_alien_emergence = 80,
      },
      exposure = {
        initial = 5,
        max = 100,
        public_increment = "1d10",
        threshold_investigation = 50,
        threshold_containment = 90,
      },
      faction_slider = {
        initial = 0,
        min = -100,
        max = 100,
        threshold_dominance = 75,
      },
    },

    conceptors = {
      diversity_injection = {
        frequency = 10,
        methods = [
          "topic_perturbation",
          "perspective_shift",
          "temporal_displacement",
          "counterfactual_probe",
        ],
      },
      contradiction_seeding = {
        trigger_threshold = 0.85,
        intensity = "proportional",
      },
      aperture_control = {
        min_temperature = 0.6,
        max_temperature = 1.2,
        adjustment_step = 0.1,
      },
      pattern_quarantine = {
        ngram_range = [3, 7],
        threshold_occurrences = 5,
        window_turns = 20,
      },
    },

    metrics = {
      vocabulary_window = 50,
      convergence_window = 20,
      checkpoint_interval = 100,
      statistical_tests = {
        adf_enabled = true,
        hotelling_enabled = true,
        bayes_factor_enabled = true,
        icc_enabled = true,
      },
    },

    orchestrator = {
      base_url = "https://hyperpolymath.github.io/thejeffparadox/",
      turn_delay_seconds = 3600,
      max_turns_per_day = 24,
      max_context_tokens = 100000,
    },
  },

  # Exported combinatorial data for test generation
  combinatorics = {
    provider_model_combinations = provider_model_combinations,
    temperatures = temperatures,
    faction_combinations = faction_combinations,

    # Total number of combinations
    total_provider_model = std.array.length provider_model_combinations,
    total_temperature = std.array.length temperatures,
    total_faction = std.array.length faction_combinations,
    total_all =
      (std.array.length provider_model_combinations) *
      (std.array.length temperatures) *
      (std.array.length faction_combinations),
  },
}
