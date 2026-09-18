# pg_debver: Debian Version Support for PostgreSQL

`pg_debver` provides the `debversion` data type for PostgreSQL, implementing native storage, comparison, hashing, and indexing for Debian package version strings in full compliance with the [Debian Policy Manual §5.6.12](https://www.debian.org/doc/debian-policy/ch-controlfields.html#version).

The version comparison algorithm is derived from Novell's `libsolv` (`solv_vercmp_deb`), ensuring exact fidelity with `dpkg --compare-versions`.

## Features

- **EVR Support**: Handles `[epoch:]upstream_version[-debian_revision]` format.
- **Strict Validation**: Strict syntax checking during input (`debversion_in`), lax constructor (`to_debversion`), and non-throwing validator (`is_debversion`).
- **Operators**: `=`, `<>`, `<`, `<=`, `>=`, `>` with B-tree index support.
- **Normalized Hashing**: 32-bit (`hash_debversion`) and 64-bit (`hash_debversion_extended`) hash functions normalize equivalent epochs (`0:1.0` vs `1.0`) and leading zeros, ensuring hash index correctness and declarative hash partitioning compatibility.
- **Aggregates**: `min()` and `max()`.
- **Range Type**: Built-in `debversionrange` range type.
- **Accessors**:
  - `get_debversion_epoch(debversion) -> integer`
  - `get_debversion_upstream(debversion) -> text`
  - `get_debversion_revision(debversion) -> text`
- **Compatibility**: Aliased as both `pg_debver` and `debversion` extensions.

## Building and Installation

Build and install using PGXS:

```bash
make PG_CONFIG=/path/to/pg_config
make PG_CONFIG=/path/to/pg_config install
```

Run regression tests:

```bash
make PG_CONFIG=/path/to/pg_config installcheck
```

## Usage

```sql
CREATE EXTENSION pg_debver;

-- Basic comparison
SELECT '2:1.0-1'::debversion > '1:2.0-1'::debversion; -- true (epoch takes precedence)
SELECT '1.0~rc1-1'::debversion < '1.0-1'::debversion; -- true (~ sorts before empty)
SELECT '0:1.0'::debversion = '1.0'::debversion;       -- true (omitted epoch equals 0)

-- Accessor functions
SELECT get_debversion_epoch('2:1.4.0-1ubuntu1'::debversion);    -- 2
SELECT get_debversion_upstream('2:1.4.0-1ubuntu1'::debversion); -- 1.4.0
SELECT get_debversion_revision('2:1.4.0-1ubuntu1'::debversion); -- 1ubuntu1

-- Indexing
CREATE TABLE packages (
    id serial PRIMARY KEY,
    name text NOT NULL,
    version debversion NOT NULL
);

CREATE INDEX idx_packages_ver_btree ON packages USING btree (version);
CREATE INDEX idx_packages_ver_hash ON packages USING hash (version);
```

## License

PostgreSQL License (extension scaffolding and PostgreSQL bindings) and Novell BSD-3-Clause License (`src/debver_evr.*` libsolv comparison algorithm). See [LICENSE](LICENSE) for details.
