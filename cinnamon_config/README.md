# Instructions

## Backup/restore settings

To backup settings, use the following command
```sh
$ dconf dump /org/cinnamon/ > dconf-settings
``` 
This backs up your settings to a file named `dconf-settings` in whatever directory you executed this from.

To restore the settings:

```sh
$ dconf load /org/cinnamon/ < dconf-settings.conf
```

Note that you need to make sure the `dconf-cli` package is installed.

## Application Menu (Cinnamon's equivalent to the Start Menu)

To backup your settings for the Application Menu:
1. Go to "System Settings" (open the Application Menu and search for "System Settings")
2. Go to "Applets", it might take a few seconds to load, you will see a list of different "Applets", different elements of CInnamon
3. Scroll down to the "Menu" applet and click on the little gear icon on the right side of the "Menu" entry in the list.
4. Click the hamburger menu button on the upper-right of the window and here you have settings for both importing configuration from a file and exporting configuration to a file.
5. Click "Export to file" and enter the name of the file and where you want it to be saved.
6. Repeat the same steps when importing the config for this and any other applet