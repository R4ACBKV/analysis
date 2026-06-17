CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE analysis_nodes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    node_kind TEXT NOT NULL CHECK (node_kind IN ('topic', 'event', 'entity', 'claim')),
    slug TEXT UNIQUE,
    title TEXT NOT NULL,
    summary TEXT,
    status TEXT NOT NULL DEFAULT 'active',
    language_code TEXT NOT NULL DEFAULT 'zh',
    tags TEXT[] NOT NULL DEFAULT '{}',
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE topics (
    node_id UUID PRIMARY KEY REFERENCES analysis_nodes(id) ON DELETE CASCADE,
    start_date DATE,
    end_date DATE,
    region TEXT,
    risk_level SMALLINT CHECK (risk_level BETWEEN 1 AND 5),
    owner_team TEXT,
    review_status TEXT NOT NULL DEFAULT 'draft',
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb
);

CREATE TABLE events (
    node_id UUID PRIMARY KEY REFERENCES analysis_nodes(id) ON DELETE CASCADE,
    occurred_from TIMESTAMPTZ,
    occurred_to TIMESTAMPTZ,
    time_precision TEXT NOT NULL DEFAULT 'day'
        CHECK (time_precision IN ('exact', 'hour', 'day', 'week', 'month', 'year', 'unknown')),
    location_name TEXT,
    country_code TEXT,
    importance SMALLINT CHECK (importance BETWEEN 1 AND 5),
    event_status TEXT NOT NULL DEFAULT 'observed',
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    CHECK (occurred_to IS NULL OR occurred_from IS NULL OR occurred_to >= occurred_from)
);

CREATE TABLE entities (
    node_id UUID PRIMARY KEY REFERENCES analysis_nodes(id) ON DELETE CASCADE,
    entity_type TEXT NOT NULL,
    canonical_name TEXT NOT NULL,
    country_code TEXT,
    aliases JSONB NOT NULL DEFAULT '[]'::jsonb,
    external_refs JSONB NOT NULL DEFAULT '{}'::jsonb,
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb
);

CREATE TABLE sources (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_type TEXT NOT NULL,
    publisher TEXT,
    title TEXT NOT NULL,
    url TEXT,
    published_at TIMESTAMPTZ,
    author_name TEXT,
    language_code TEXT NOT NULL DEFAULT 'zh',
    content_hash TEXT,
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE claims (
    node_id UUID PRIMARY KEY REFERENCES analysis_nodes(id) ON DELETE CASCADE,
    source_id UUID REFERENCES sources(id) ON DELETE SET NULL,
    claim_text TEXT NOT NULL,
    normalized_claim TEXT,
    claim_kind TEXT NOT NULL DEFAULT 'statement',
    polarity TEXT NOT NULL DEFAULT 'neutral'
        CHECK (polarity IN ('positive', 'negative', 'neutral', 'mixed', 'unknown')),
    confidence NUMERIC(4,3) CHECK (confidence >= 0 AND confidence <= 1),
    extraction_method TEXT,
    quote_span TEXT,
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb
);

CREATE TABLE node_relations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    from_node_id UUID NOT NULL REFERENCES analysis_nodes(id) ON DELETE CASCADE,
    to_node_id UUID NOT NULL REFERENCES analysis_nodes(id) ON DELETE CASCADE,
    relation_type TEXT NOT NULL,
    confidence NUMERIC(4,3) CHECK (confidence >= 0 AND confidence <= 1),
    directionality TEXT NOT NULL DEFAULT 'directed'
        CHECK (directionality IN ('directed', 'undirected')),
    valid_from TIMESTAMPTZ,
    valid_to TIMESTAMPTZ,
    source_id UUID REFERENCES sources(id) ON DELETE SET NULL,
    supporting_claim_id UUID REFERENCES claims(node_id) ON DELETE SET NULL,
    evidence_note TEXT,
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CHECK (from_node_id <> to_node_id),
    CHECK (valid_to IS NULL OR valid_from IS NULL OR valid_to >= valid_from)
);

CREATE TABLE topic_event_links (
    topic_id UUID NOT NULL REFERENCES topics(node_id) ON DELETE CASCADE,
    event_id UUID NOT NULL REFERENCES events(node_id) ON DELETE CASCADE,
    link_role TEXT NOT NULL DEFAULT 'contains',
    confidence NUMERIC(4,3) CHECK (confidence >= 0 AND confidence <= 1),
    source_id UUID REFERENCES sources(id) ON DELETE SET NULL,
    note TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (topic_id, event_id, link_role)
);

CREATE TABLE event_entity_links (
    event_id UUID NOT NULL REFERENCES events(node_id) ON DELETE CASCADE,
    entity_id UUID NOT NULL REFERENCES entities(node_id) ON DELETE CASCADE,
    entity_role TEXT NOT NULL DEFAULT 'participant',
    confidence NUMERIC(4,3) CHECK (confidence >= 0 AND confidence <= 1),
    source_id UUID REFERENCES sources(id) ON DELETE SET NULL,
    note TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (event_id, entity_id, entity_role)
);

CREATE TABLE claim_node_links (
    claim_id UUID NOT NULL REFERENCES claims(node_id) ON DELETE CASCADE,
    target_node_id UUID NOT NULL REFERENCES analysis_nodes(id) ON DELETE CASCADE,
    link_role TEXT NOT NULL DEFAULT 'about',
    confidence NUMERIC(4,3) CHECK (confidence >= 0 AND confidence <= 1),
    note TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (claim_id, target_node_id, link_role)
);

CREATE INDEX idx_analysis_nodes_kind ON analysis_nodes(node_kind);
CREATE INDEX idx_analysis_nodes_status ON analysis_nodes(status);
CREATE INDEX idx_analysis_nodes_tags ON analysis_nodes USING GIN(tags);
CREATE INDEX idx_analysis_nodes_metadata ON analysis_nodes USING GIN(metadata);

CREATE INDEX idx_topics_start_date ON topics(start_date);
CREATE INDEX idx_topics_end_date ON topics(end_date);
CREATE INDEX idx_topics_region ON topics(region);

CREATE INDEX idx_events_occurred_from ON events(occurred_from);
CREATE INDEX idx_events_occurred_to ON events(occurred_to);
CREATE INDEX idx_events_country_code ON events(country_code);
CREATE INDEX idx_events_status ON events(event_status);

CREATE INDEX idx_entities_type ON entities(entity_type);
CREATE INDEX idx_entities_country_code ON entities(country_code);

CREATE INDEX idx_sources_type ON sources(source_type);
CREATE INDEX idx_sources_published_at ON sources(published_at);
CREATE INDEX idx_sources_url ON sources(url);

CREATE INDEX idx_claims_source_id ON claims(source_id);
CREATE INDEX idx_claims_kind ON claims(claim_kind);

CREATE INDEX idx_node_relations_from ON node_relations(from_node_id);
CREATE INDEX idx_node_relations_to ON node_relations(to_node_id);
CREATE INDEX idx_node_relations_type ON node_relations(relation_type);
CREATE INDEX idx_node_relations_source_id ON node_relations(source_id);
CREATE INDEX idx_node_relations_valid_from ON node_relations(valid_from);
CREATE INDEX idx_node_relations_valid_to ON node_relations(valid_to);

CREATE INDEX idx_topic_event_links_event_id ON topic_event_links(event_id);
CREATE INDEX idx_event_entity_links_entity_id ON event_entity_links(entity_id);
CREATE INDEX idx_claim_node_links_target_node_id ON claim_node_links(target_node_id);

INSERT INTO analysis_nodes (id, node_kind, slug, title, summary, tags, metadata)
VALUES
    ('00000000-0000-0000-0000-000000000001', 'topic', 'bootstrap-sample-topic', '示例话题', '用于验证 schema 初始化。', ARRAY['sample'], '{"seed": true}'),
    ('00000000-0000-0000-0000-000000000002', 'event', 'bootstrap-sample-event', '示例事件', '用于验证 topic-event 链接。', ARRAY['sample'], '{"seed": true}'),
    ('00000000-0000-0000-0000-000000000003', 'entity', 'bootstrap-sample-entity', '示例实体', '用于验证 event-entity 链接。', ARRAY['sample'], '{"seed": true}');

INSERT INTO topics (node_id, start_date, region, risk_level, review_status)
VALUES ('00000000-0000-0000-0000-000000000001', DATE '2026-06-17', 'global', 2, 'reviewed');

INSERT INTO events (node_id, occurred_from, time_precision, location_name, country_code, importance)
VALUES ('00000000-0000-0000-0000-000000000002', TIMESTAMPTZ '2026-06-17 00:00:00+00', 'day', 'global', 'ZZ', 1);

INSERT INTO entities (node_id, entity_type, canonical_name, country_code)
VALUES ('00000000-0000-0000-0000-000000000003', 'system', 'Sample Entity', 'ZZ');

INSERT INTO topic_event_links (topic_id, event_id, link_role, confidence, note)
VALUES ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'contains', 1.000, 'bootstrap seed');

INSERT INTO event_entity_links (event_id, entity_id, entity_role, confidence, note)
VALUES ('00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000003', 'participant', 1.000, 'bootstrap seed');

INSERT INTO node_relations (from_node_id, to_node_id, relation_type, confidence, evidence_note)
VALUES ('00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000002', 'contains', 1.000, 'bootstrap seed');

