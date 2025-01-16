#!/usr/bin/env bash
cd PostgresDbt
dbt deps --profiles-dir .
dbt docs generate --target container --profiles-dir .
dbt docs serve --profiles-dir . --port 80