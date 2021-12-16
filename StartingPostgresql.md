# Starting Postgresql

Since postgresql@9.6 is EoL and deprecated by Homebrew, an alternative is to use the PostgresApp. The app comes bundled with a handful of versions of postrgresql. 

## Initializing a 9.6 DB

After installing the app via the [mac.sh](./mach.sh) script, you will need to initialize the DB manually. Follow this guide for how to do that.

1. Open the PostgresApp however you like. It should be in your `/Applications` directory

![](./images/postgresql-9.6-create-screen.png)

2. Select the `+` button on the bottom left of the Left Sidebar

![](./images/postgresql-startup-screen_add-button-highlight.png)

3. Name the server `local` (or whatever name you want) and then choose `9.6` for the version

4. Click `Create Server`

![](./images/postgresql-9.6-create-screen.png)

5. Click `Initialize`

![](./images/postgresql-9.6-init-screen.png)

6. You're Done!

![](./images/postgresql-9.6-finished-screen.png)