# CT-Backup

Backup & Restore scripts for Control Tower Concii

## Backup Teams and Pipelines

1. Log in to your Concourse as the admin user

    ```sh
    fly -t <target> login
    ```

1. Export the necessary env vars

    ```sh
    export FLY_TARGET=<target>
     export ADMIN_PASSWORD=<admin_password_for_your_concourse>
    # You must create OUTPUT_DIR if you set this variable
    # Defaults to (and creates) ./out if not set
    export OUTPUT_DIR=<dir_for_backups>
    ```

1. Run the script

    ```sh
    ./backup.rb
    ```

## Restore Teams and Pipelines

1. Set env vars

    ```sh
    export FLY_TARGET=<target>
     export ADMIN_PASSWORD=<admin_password_for_your_new_concourse>
    # Defaults to ./out if not set
    export OUTPUT_DIR=<dir_containing_backed_up_things>
    ```

1. Run the script

    ```sh
    ./restore.rb
    ```

## Backing up Credhub

1. Log in to your credhub

    ```sh
    eval "$(control-tower info --iaas <aws|gcp> --region <region> --env <deployment>)"
    ```

1. Set env vars

    ```sh
    # You must create OUTPUT_DIR if you set this variable
    # Defaults to (and creates) ./out if not set
    export OUTPUT_DIR=<dir_for_backups>
    ```

1. Run the script

    ```sh
    ./credhub_export
    ```

    This will write `creds.encrypted` to your `OUTPUT_DIR`. It will also output a decryption key for your creds. Take note of this as you will need it to decrypt them later.

## Restoring Credhub

1. Set env vars

    ```sh
    # Defaults to ./out if not set
    export OUTPUT_DIR=<dir_containing_creds.encrypted>
    export ENCRYPTION_KEY=<key_outputted_by_credhub_export>
    ```

1. Run the script

    ```sh
    ./credhub_import.rb
    ```

