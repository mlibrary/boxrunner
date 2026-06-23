# boxrunner

## Local development startup

`compose.yml` now starts infrastructure services by default and requires starting `app` explicitly.

```zsh
docker compose up -d
/bin/bash ./solr/dev-init.sh
docker compose up -d app
```

To stop only the Rails container while leaving services running:

```zsh
docker compose stop app
```

## Shared configuration dependency

`config/repositories.yml` is sourced from `mlibrary/boxwalker` and kept in sync by the GitHub Actions workflow at `.github/workflows/sync-repositories-yml.yml`.

- Source file: `https://github.com/mlibrary/boxwalker/blob/main/config/repositories.yml`
- Sync trigger: manual (`workflow_dispatch`) and daily schedule
- Update mechanism: workflow opens/updates a PR when the source file changes

If you need an immediate sync, run the **Sync repositories.yml** workflow from the Actions tab.

