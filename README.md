# CT-Backup

Backup & Restore scripts for Control Tower Concii

## Usage

These scripts are designed primarily for DR where a Concourse is being backed up then restored to a different, empty Concourse.

It is not designed for use cases such as selectively restoring teams, secrets, or pipelines. You may encounter data loss or unexpected results if you try restoring to a non-empty Concourse.

## Backup Teams, Credhub, and Pipelines

1. Set the following env vars for the Concourse you want to backup

    ```yaml
    ADMIN_PASSWORD:
    CONCOURSE_URL:
    CREDHUB_CA_CERT:
    CREDHUB_CLIENT:
    CREDHUB_SECRET:
    CREDHUB_SERVER:
    ```

1. Fly execute the task

    ```sh
    $ fly -t some-target execute -c examples/backup.yml -o out=./out
    ...
    exporting teams
    setting admin on all teams
    exporting pipelines
    setting correct auth on all teams
    Key: <KEY>
    out: 1.66 MiB/s 0s
    succeeded
    ```

1. Take note of the key from the output and store the files in `out` securely somewhere

## Restore Teams, Credhub, and Pipelines

1. Set the following env vars for the Concourse you want to restore to

    ```yaml
    ADMIN_PASSWORD:
    CONCOURSE_URL:
    CREDHUB_CA_CERT:
    CREDHUB_CLIENT:
    CREDHUB_SECRET:
    CREDHUB_SERVER:
    ENCRYPTION_KEY:
    ```

    > NOTE: `ENCRYPTION_KEY` comes from the output at the end of the backup task (see above)

1. Fly execute the task

    ```sh
    $ fly -t some-target execute -c examples/restore.yml -i backup_source=<path/to/backup/output/dir> --include-ignored
    ...
    setting admin on all teams
    importing pipelines
    setting correct auth on all teams
    beginning credhub import - this may take a while
    ...
    succeeded
    ```

    > NOTE: `--include-ignored` is needed if your backup dir is `out` in this repo since it is in `.gitignore`

## Upausing and Exposing

Against origin Concourse:

```sh
fly -t origin login
# For each team
fly -t origin pipelines --json > pipelines.json
```

Against target Concourse:

```sh
fly -t target login
# For each team
examples/unpause_expose.rb ebci pipelines.json
```

## Tests

`bundle exec rspec`
