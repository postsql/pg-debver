EXTENSION    = pg_debver debversion
EXTVERSION   = 1.0.0
MODULE_big   = pg_debver
OBJS         = src/debversion.o src/debver_evr.o

DATA         = sql/pg_debver--1.0.0.sql sql/debversion--1.0.0.sql
DOCS         = README.md
REGRESS      = debversion upstream_debversion
REGRESS_OPTS = --inputdir=test
EXTRA_CLEAN  = debversion_binary_copy.bin

PG_CONFIG   ?= pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
