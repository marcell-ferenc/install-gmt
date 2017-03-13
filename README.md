# Install & update [GMT](http://gmt.soest.hawaii.edu) (Generic Mapping Tools) on Ubuntu

A simple script that install [GMT5](http://gmt.soest.hawaii.edu) :earth_americas: (together with all its dependencies, download the latest [GSHHG](https://www.soest.hawaii.edu/pwessel/gshhg) and [DCW](http://www.soest.hawaii.edu/wessel/dcw) databases, etc.) onto a freshly installed Ubuntu. Eventually it can be used to update to its latest version.

## Getting Started

These instructions will get you a copy of the **install-gmt** script to install and update **GMT5** on your local machine.

### Prerequisites

A machine that runs [Ubuntu](https://www.ubuntu.com/download/desktop).

### Installing

1. Open a terminal

1. Type the following to get a copy of the script
    ```
    cd $HOME && git clone https://github.com/marcell-ferenc/install-gmt.git
    ```

1. Make the script executable

    ```
    chmod 0700 $HOME/install-gmt/bin/install-gmt.sh
    ```

## Running the script

Running the script without any argument will show the usage for You.

```
$HOME/install-gmt/bin/install-gmt.sh
```

Install GMT5

```
sudo $HOME/install-gmt/bin/install-gmt.sh -i
```

Update GMT5

```
sudo $HOME/install-gmt/bin/install-gmt.sh -u
```

## Author

* **Marcell Ferenc** - *Initial work* - [marcell-ferenc](https://github.com/marcell-ferenc)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Acknowledgments

* The developers of GMT providing such a great tool for the scientific community
