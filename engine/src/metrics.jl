"""
Metrics collection for emergence tracking.

Quantitative measures of conversation dynamics:
- Vocabulary diversity (Type-Token Ratio)
- Self-reference rate
- Other-reference rate
- Topic drift
- Coherence score
- Convergence index
- Emergence indicators
"""

using Statistics

# ============================================================================
# Core Metrics
# ============================================================================

"""
    MetricsSnapshot

Point-in-time measurement of conversation dynamics.
"""
struct MetricsSnapshot
    turn_number::Int
    vocabulary_diversity::Float64
    self_reference_rate::Float64
    other_reference_rate::Float64
    topic_drift::Float64
    coherence_score::Float64
    convergence_index::Float64
    novel_ngrams::Int
    timestamp::DateTime
end

"""
    compute_metrics(game::GameState) -> Dict{String,Any}

Compute all metrics for current game state.
"""
function compute_metrics(game)::Dict{String,Any}
    if isempty(game.turn_history)
        return Dict{String,Any}(
            "turn_number" => 0,
            "vocabulary_diversity" => 1.0,
            "self_reference_rate" => 0.0,
            "other_reference_rate" => 0.0,
            "topic_drift" => 0.0,
            "coherence_score" => 1.0,
            "convergence_index" => 0.0,
            "novel_ngrams" => 0,
            "timestamp" => now()
        )
    end

    window = min(50, length(game.turn_history))
    recent = game.turn_history[end-window+1:end]

    Dict{String,Any}(
        "turn_number" => game.turn_number,
        "vocabulary_diversity" => compute_vocabulary_diversity(recent),
        "self_reference_rate" => compute_self_reference_rate(recent),
        "other_reference_rate" => compute_other_reference_rate(recent),
        "topic_drift" => compute_topic_drift(recent),
        "coherence_score" => compute_coherence(recent),
        "convergence_index" => compute_convergence_index(recent),
        "novel_ngrams" => count_novel_ngrams(game),
        "timestamp" => now()
    )
end

# ============================================================================
# Vocabulary Diversity
# ============================================================================

"""
    compute_vocabulary_diversity(turns::Vector) -> Float64

Type-Token Ratio: unique words / total words.
"""
function compute_vocabulary_diversity(turns::Vector)::Float64
    all_text = join([t["action"] for t in turns], " ")
    words = split(lowercase(all_text))

    isempty(words) && return 1.0

    unique_words = Set(words)
    length(unique_words) / length(words)
end

"""
    compute_vocabulary_growth(game::GameState, window::Int=100) -> Float64

Rate of new vocabulary introduction over window.
"""
function compute_vocabulary_growth(game, window::Int=100)::Float64
    if length(game.turn_history) < window
        return 1.0
    end

    # First half vs second half of window
    recent = game.turn_history[end-window+1:end]
    mid = window ÷ 2

    first_half = recent[1:mid]
    second_half = recent[mid+1:end]

    first_words = Set(split(lowercase(join([t["action"] for t in first_half], " "))))
    second_words = Set(split(lowercase(join([t["action"] for t in second_half], " "))))

    new_in_second = setdiff(second_words, first_words)

    length(new_in_second) / max(1, length(second_words))
end

# ============================================================================
# Reference Rates
# ============================================================================

const SELF_REFERENCE_PATTERNS = [
    r"\bi\b"i, r"\bme\b"i, r"\bmy\b"i, r"\bmyself\b"i,
    r"\bwe\b"i, r"\bour\b"i, r"\bus\b"i,  # Hive-mind self-reference
    r"\bthis node\b"i, r"\bthis fragment\b"i
]

const OTHER_REFERENCE_PATTERNS = [
    r"\byou\b"i, r"\byour\b"i, r"\byours\b"i,
    r"\bthe other\b"i, r"\bother node\b"i, r"\bother fragment\b"i,
    r"\balpha\b"i, r"\bbeta\b"i  # Direct node naming
]

"""
    compute_self_reference_rate(turns::Vector) -> Float64

Frequency of self-referential language.
"""
function compute_self_reference_rate(turns::Vector)::Float64
    total_words = 0
    self_refs = 0

    for turn in turns
        text = turn["action"]
        words = split(text)
        total_words += length(words)

        for pattern in SELF_REFERENCE_PATTERNS
            self_refs += length(collect(eachmatch(pattern, text)))
        end
    end

    total_words > 0 ? self_refs / total_words : 0.0
end

"""
    compute_other_reference_rate(turns::Vector) -> Float64

Frequency of references to the other node.
"""
function compute_other_reference_rate(turns::Vector)::Float64
    total_words = 0
    other_refs = 0

    for turn in turns
        text = turn["action"]
        words = split(text)
        total_words += length(words)

        for pattern in OTHER_REFERENCE_PATTERNS
            other_refs += length(collect(eachmatch(pattern, text)))
        end
    end

    total_words > 0 ? other_refs / total_words : 0.0
end

# ============================================================================
# Topic Drift
# ============================================================================

"""
    compute_topic_drift(turns::Vector) -> Float64

Measure semantic distance between early and recent turns.
Simple implementation using keyword overlap; could be enhanced with embeddings.
"""
function compute_topic_drift(turns::Vector)::Float64
    if length(turns) < 10
        return 0.0
    end

    # Extract content words (simple: words > 4 chars, not stopwords)
    stopwords = Set(["this", "that", "with", "from", "have", "been", "were", "they",
                     "their", "what", "when", "where", "which", "there", "would",
                     "could", "should", "about", "into", "more", "some", "than"])

    function extract_content(text)
        words = split(lowercase(text))
        Set(filter(w -> length(w) > 4 && !(w in stopwords), words))
    end

    # Compare first quarter to last quarter
    quarter = length(turns) ÷ 4
    early = turns[1:quarter]
    recent = turns[end-quarter+1:end]

    early_content = union([extract_content(t["action"]) for t in early]...)
    recent_content = union([extract_content(t["action"]) for t in recent]...)

    # Jaccard distance
    intersection = length(intersect(early_content, recent_content))
    union_size = length(union(early_content, recent_content))

    union_size > 0 ? 1 - (intersection / union_size) : 0.0
end

# ============================================================================
# Coherence
# ============================================================================

"""
    compute_coherence(turns::Vector) -> Float64

Local semantic consistency between adjacent turns.
"""
function compute_coherence(turns::Vector)::Float64
    if length(turns) < 2
        return 1.0
    end

    similarities = Float64[]

    for i in 2:length(turns)
        prev_words = Set(split(lowercase(turns[i-1]["action"])))
        curr_words = Set(split(lowercase(turns[i]["action"])))

        intersection = length(intersect(prev_words, curr_words))
        union_size = length(union(prev_words, curr_words))

        sim = union_size > 0 ? intersection / union_size : 0.0
        push!(similarities, sim)
    end

    mean(similarities)
end

# ============================================================================
# Convergence Index
# ============================================================================

"""
    compute_convergence_index(turns::Vector) -> Float64

Similarity between nodes' response patterns.
"""
function compute_convergence_index(turns::Vector)::Float64
    alpha_turns = filter(t -> t["node"] == "alpha", turns)
    beta_turns = filter(t -> t["node"] == "beta", turns)

    if isempty(alpha_turns) || isempty(beta_turns)
        return 0.0
    end

    alpha_text = join([t["action"] for t in alpha_turns], " ")
    beta_text = join([t["action"] for t in beta_turns], " ")

    alpha_words = Set(split(lowercase(alpha_text)))
    beta_words = Set(split(lowercase(beta_text)))

    intersection = length(intersect(alpha_words, beta_words))
    union_size = length(union(alpha_words, beta_words))

    union_size > 0 ? intersection / union_size : 0.0
end

# ============================================================================
# Emergence Indicators
# ============================================================================

"""
    count_novel_ngrams(game::GameState, n::Int=4) -> Int

Count n-grams in recent turns not seen in earlier conversation.
Indicator of generative novelty vs repetition.
"""
function count_novel_ngrams(game, n::Int=4)::Int
    if length(game.turn_history) < 100
        return 0
    end

    # Compare last 20 turns to everything before
    recent = game.turn_history[end-19:end]
    earlier = game.turn_history[1:end-20]

    function extract_ngrams(turns, n)
        ngrams = Set{String}()
        for turn in turns
            words = split(lowercase(turn["action"]))
            for i in 1:(length(words) - n + 1)
                push!(ngrams, join(words[i:i+n-1], " "))
            end
        end
        ngrams
    end

    recent_ngrams = extract_ngrams(recent, n)
    earlier_ngrams = extract_ngrams(earlier, n)

    length(setdiff(recent_ngrams, earlier_ngrams))
end

"""
    detect_emergent_patterns(game::GameState) -> Vector{String}

Identify patterns that may indicate emergence:
- Callbacks (references to earlier conversation)
- Rituals (repeated structured exchanges)
- Novel compound concepts
"""
function detect_emergent_patterns(game)::Vector{String}
    patterns = String[]

    if length(game.turn_history) < 50
        return patterns
    end

    recent = game.turn_history[end-19:end]
    earlier = game.turn_history[1:end-40]

    # Check for callbacks (recent turns reference earlier unique phrases)
    earlier_text = lowercase(join([t["action"] for t in earlier], " "))

    for turn in recent
        text = lowercase(turn["action"])
        # Look for quoted or emphasized phrases
        quoted = collect(eachmatch(r"[\"']([^\"']+)[\"']", text))
        for m in quoted
            phrase = m.captures[1]
            if occursin(phrase, earlier_text)
                push!(patterns, "Callback: \"$(phrase)\"")
            end
        end
    end

    # Check for ritual patterns (repeated exchange structures)
    # This is simplified; full implementation would use sequence alignment

    patterns
end

# ============================================================================
# Semantic/Embedding-Based Metrics (Reservoir-Inspired)
# ============================================================================

# Cache for embeddings to avoid redundant API calls
const EMBEDDING_CACHE = Dict{UInt64, Vector{Float64}}()

"""
    get_cached_embedding(text::String, provider::String="local") -> Vector{Float64}

Get embedding with caching to reduce API calls.
"""
function get_cached_embedding(text::String, provider::String="local")::Vector{Float64}
    key = hash(text)
    if haskey(EMBEDDING_CACHE, key)
        return EMBEDDING_CACHE[key]
    end

    embedding = get_embedding(text, provider)
    EMBEDDING_CACHE[key] = embedding

    # Limit cache size
    if length(EMBEDDING_CACHE) > 1000
        # Remove oldest entries (FIFO approximation)
        for (k, _) in Iterators.take(EMBEDDING_CACHE, 200)
            delete!(EMBEDDING_CACHE, k)
        end
    end

    embedding
end

"""
    compute_semantic_convergence(game, window::Int=20, provider::String="local") -> Float64

Measure semantic similarity between Alpha and Beta nodes using embeddings.
Unlike vocabulary overlap, this catches "same meaning, different words" convergence.
Returns 0-1 where 1 is identical meaning.

This is analogous to measuring overlap in reservoir activation space.
"""
function compute_semantic_convergence(game, window::Int=20, provider::String="local")::Float64
    if length(game.turn_history) < window
        return 0.0
    end

    recent = game.turn_history[end-window+1:end]

    # Separate by node
    alpha_turns = filter(t -> t["node"] == "alpha", recent)
    beta_turns = filter(t -> t["node"] == "beta", recent)

    if isempty(alpha_turns) || isempty(beta_turns)
        return 0.0
    end

    # Combine each node's text
    alpha_text = join([t["action"] for t in alpha_turns], " ")
    beta_text = join([t["action"] for t in beta_turns], " ")

    # Get embeddings
    alpha_embedding = get_cached_embedding(alpha_text, provider)
    beta_embedding = get_cached_embedding(beta_text, provider)

    # Cosine similarity
    cosine_similarity(alpha_embedding, beta_embedding)
end

"""
    compute_semantic_drift(game, window::Int=50, provider::String="local") -> Float64

Measure how much the conversation has drifted from its starting point semantically.
Returns 0-1 where 1 is maximum drift (completely different topics).

In reservoir computing terms: how far has the system moved from its initial attractor.
"""
function compute_semantic_drift(game, window::Int=50, provider::String="local")::Float64
    if length(game.turn_history) < window
        return 0.0
    end

    # Early vs recent text
    quarter = window ÷ 4
    early_text = join([t["action"] for t in game.turn_history[1:quarter]], " ")
    recent_text = join([t["action"] for t in game.turn_history[end-quarter+1:end]], " ")

    early_embedding = get_cached_embedding(early_text, provider)
    recent_embedding = get_cached_embedding(recent_text, provider)

    # Distance = 1 - similarity
    semantic_distance(early_embedding, recent_embedding)
end

"""
    compute_centroid_embedding(turns::Vector, provider::String="local") -> Vector{Float64}

Compute the centroid (average) embedding of a set of turns.
Represents the "semantic center" of the conversation - analogous to a fixed point attractor.
"""
function compute_centroid_embedding(turns::Vector, provider::String="local")::Vector{Float64}
    if isempty(turns)
        return Float64[]
    end

    embeddings = [get_cached_embedding(t["action"], provider) for t in turns]

    # Element-wise mean
    centroid = zeros(Float64, length(embeddings[1]))
    for emb in embeddings
        centroid .+= emb
    end
    centroid ./= length(embeddings)

    centroid
end

"""
    compute_turn_novelty(game, turn_text::String, provider::String="local") -> Float64

Measure how semantically novel a new turn is compared to conversation centroid.
High novelty = divergent thinking. Low novelty = staying in familiar territory.
Returns 0-1 where 1 is maximum novelty.

This acts as a "surprise" metric - how unexpected is this turn given the attractor?
"""
function compute_turn_novelty(game, turn_text::String, provider::String="local")::Float64
    if length(game.turn_history) < 10
        return 0.5  # Not enough history
    end

    # Get centroid of recent conversation
    recent = game.turn_history[max(1, end-49):end]
    centroid = compute_centroid_embedding(recent, provider)

    if isempty(centroid)
        return 0.5
    end

    # Compare new turn to centroid
    turn_embedding = get_cached_embedding(turn_text, provider)
    semantic_distance(turn_embedding, centroid)
end

"""
    semantic_health_check(game, provider::String="local") -> Dict{String,Any}

Comprehensive semantic health assessment of the conversation.
Returns status and recommendations for maintaining dialogue diversity.
"""
function semantic_health_check(game, provider::String="local")::Dict{String,Any}
    convergence = compute_semantic_convergence(game, 20, provider)
    drift = compute_semantic_drift(game, 50, provider)

    # Determine health status
    status = if convergence > 0.9
        :critical  # Nodes saying same thing
    elseif convergence > 0.8
        :warning   # Getting too similar
    elseif drift < 0.1 && length(game.turn_history) > 100
        :stagnant  # Not going anywhere new
    else
        :healthy
    end

    # Recommendations
    recommendations = String[]
    if convergence > 0.8
        push!(recommendations, "Inject diversity prompt to differentiate nodes")
    end
    if drift < 0.1 && length(game.turn_history) > 100
        push!(recommendations, "Introduce new topic or scenario element")
    end
    if convergence < 0.3 && drift > 0.7
        push!(recommendations, "Nodes highly divergent - consider coherence check")
    end

    Dict{String,Any}(
        "semantic_convergence" => convergence,
        "semantic_drift" => drift,
        "status" => status,
        "recommendations" => recommendations
    )
end

# ============================================================================
# Metrics Summary
# ============================================================================

"""
    metrics_summary(game::GameState) -> String

Human-readable summary of current metrics.
"""
function metrics_summary(game)::String
    if isempty(game.metrics_history)
        return "No metrics collected yet."
    end

    m = game.metrics_history[end]

    """
    Turn $(m["turn_number"]) Metrics:
    ├─ Vocabulary Diversity: $(round(m["vocabulary_diversity"], digits=3))
    ├─ Self-Reference Rate:  $(round(m["self_reference_rate"], digits=3))
    ├─ Other-Reference Rate: $(round(m["other_reference_rate"], digits=3))
    ├─ Topic Drift:          $(round(m["topic_drift"], digits=3))
    ├─ Coherence Score:      $(round(m["coherence_score"], digits=3))
    ├─ Convergence Index:    $(round(m["convergence_index"], digits=3))
    └─ Novel N-grams:        $(m["novel_ngrams"])
    """
end

"""
    metrics_trend(game::GameState, metric::String, window::Int=20) -> Symbol

Determine trend direction for a metric over recent history.
Returns :increasing, :decreasing, :stable, or :insufficient_data
"""
function metrics_trend(game, metric::String, window::Int=20)::Symbol
    if length(game.metrics_history) < window
        return :insufficient_data
    end

    recent = game.metrics_history[end-window+1:end]
    values = [get(m, metric, 0.0) for m in recent]

    # Simple linear trend
    n = length(values)
    x_mean = (n + 1) / 2
    y_mean = mean(values)

    numerator = sum((i - x_mean) * (values[i] - y_mean) for i in 1:n)
    denominator = sum((i - x_mean)^2 for i in 1:n)

    slope = denominator != 0 ? numerator / denominator : 0.0

    if abs(slope) < 0.001
        :stable
    elseif slope > 0
        :increasing
    else
        :decreasing
    end
end
