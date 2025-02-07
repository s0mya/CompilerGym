# CompilerGym UI

This is the frontend to run compiler gym on the browser.

## Install dependencies
If Node.js and npm are not installed in your machine yet, we strongly recommend using [nvm](https://github.com/nvm-sh/nvm) to manage and install node versions, another way is to install via [`homebrew`](https://brew.sh/).

Afer installing node.js and npm, go to the folder `frontends/compiler_gym` and run the below command to install dependencies for the GUI.
```sh
$ npm install
```

## Setup
[TO DO]: Create a file named `.env` in the folder `frontends/compiler_gym` with a copy the .env.example file.


## Development
Run application in local [http://localhost:3000/](http://localhost:3000/)
```sh
$ npm start
```
## Enabling backend

Make sure to follow CompilerGym installations instructions [here](https://github.com/facebookresearch/CompilerGym/blob/development/INSTALL.md) before running the flask server. Go to the folder www in the root directory and run

```sh
$ FLASK_APP=demo_api.py flask run
```

## Deployment
Make sure to you have updated the .env file and build the current application.
```sh
$ npm run build
```
## Contributing

We welcome contributions to CompilerGym. If you are interested in contributing please see [this document](https://github.com/facebookresearch/CompilerGym/blob/development/CONTRIBUTING.md).
