# Technical Challenge E-Commerce
This project implements a simple project for a basic e-commerce. It's composed of a main server, a database and a Redis channel. Its main functions are:
- Exposing routes and maintaining a database for products;
- Exposing routes and maintaining a database for a cart;
- Removing carts once they have been inactive for too long;

## Getting started
### Setup
This project was developed to work with a dev container. It can be run directly on your machine, but the following setup uses dev containers.

#### Installing VSCode and the extension
To install VSCode, follow [these instructions](https://code.visualstudio.com/download) according to what suits your operating system.
To install the extension, follow [these instructions](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers).

#### Installing Docker
To install Docker, follow [these instructions](https://docs.docker.com/get-started/get-docker/) according to what suits your operating system. The benefit of using a dev container is that the operating system does not matter from this point onwards.

#### Download the source code
Clone the project via GitHub.

#### Open the project on VSCode
You will be prompted to re-open the project on a dev container.
Once it re-opens, you will have the environment fully prepared with a migrated database, a Redis channel and the port 3000 waiting for the main server.

### Running the server
To start the server, run:
```bash
bundle exec rails server
```

To start sidekiq, run:
```bash
bundle exec sidekiq
```

To execute the automated tests, run:
```bash
bundle exec rspec
```

## Available Routes
### Products
- **GET** `/products`  
  Fetch a list of all products.

- **GET** `/products/:id`  
  Fetch details of a specific product by ID.

- **POST** `/products`  
  Create a new product.

- **PATCH** `/products/:id`  
  Update a product partially by ID.

- **PUT** `/products/:id`  
  Update a product completely by ID.

- **DELETE** `/products/:id`  
  Delete a product by ID.

### Cart
- **GET** `/cart`  
  Fetch the cart in the current session, and it's products

- **POST** `/cart`  
  Create a new cart if the current session has none, otherwise fetch it.
  Then add an item to it.

- **POST** `/cart/add_item`  
  Adds an item from the cart in the current session.

- **DELETE** `/cart/:product_id`  
  Removes an item from the cart in the current session product by ID.
  If that cart doesn't have that product, returns an error.

## Jobs
- **MarkCartAsAbandonedJob**
  Runs every hour. Mark carts with more than 3 hours of inactivity as abandoned. Delete carts with more than 7 days of inactivity.

## Known issues & possible improvements
### Price in the JSON response
  The challenge has prices returning as numbers in the JSON, but that's not the native JSON parse of floats, due to potential floating point errors. I have kept the native JSON parse as a string.

### POST /cart and POST /cart/add_item
  Both routes are very similar and neither allows you to decrease an item quantity, unless you pass a negative quantity, which is a bit of a hack. I would recommend changing the POST /cart/add_item to PUT /cart/:product_id, which would allow you to directly set the quantity of an item in the cart.

### Total Price
  Since the cart's total price is a field on the database, it does not dynamically change with a change in the product price. The price will be the same until the cart is interacted with. That could either be a feature or a bug, depending on the intentions of the E-Commerce, but it is something worth bringing up regardless.

### Session and spec\requests\carts_spec.rb
 From what I have researched, [session are not easily mockable in rails 7](https://stackoverflow.com/a/74640014). Therefore, the cart integration tests perform the whole path in the test. That is why there are a lot of POST /cart call, since that is the only route that sets the cart session.

### Atomicity
 The routes calls are not atomic currently and with more time, I would change that.

## Final considerations
This project was developed as part of a recruitment process. There is no intent for this project to be open to the public, nor for it to have some real-world applications.

- After the deadline, I implemented a full docker setup. It is on [this branch](https://github.com/John2509/tech-interview-backend-entry-level-main/tree/feat/full-docker)
