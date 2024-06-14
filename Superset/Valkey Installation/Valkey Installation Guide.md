# Valkey Documentation

## **What is Valkey?**

Valkey is a high-performance data structure server optimized for key/value workloads. It supports a wide array of native data structures, providing flexibility and scalability for various applications. Valkey also features an extensible plugin system, allowing developers to introduce new data structures and access patterns, tailoring the server to specific needs and enhancing its functionality.

## **Forking the Repository**

To get started with Valkey, fork the repository into your local system. Execute the following command in your terminal:

```sh
git clone https://github.com/valkey-io/valkey/tree/6bab2d7968dd9d71f2ce200386ecf4286e333a76
```

This command clones the Valkey repository to your local machine, allowing you to build and customize the server as needed.

## **Building Valkey**

Valkey is cross-platform, compatible with Linux, OSX, OpenBSD, NetBSD, and FreeBSD. It supports both big endian and little endian architectures, and works on 32-bit and 64-bit systems. Although Valkey may compile on Solaris-derived systems (such as SmartOS), support for these platforms is best-effort.

### Steps to Build Valkey

1. **Navigate to the Valkey Directory:**

   ```sh
   cd valkey
   ```
2. **Compile the Source Code:**

   ```sh
   make
   ```

   This command compiles the source code into executable binaries.
3. **Testing the Build:**

   After building Valkey, run the test suite to ensure everything is functioning correctly:

   ```sh
   make test
   ```

   This will verify the integrity and performance of your build.

## **Running Valkey**

Once Valkey is built, you can run it with the default configuration or customize it to suit your requirements.

### Running with Default Configuration

1. **Navigate to the Source Directory:**

   ```sh
   cd src
   ```
2. **Start the Valkey Server:**

   ```sh
   ./valkey-server
   ```

### Running with a Custom Configuration

1. **Navigate to the Source Directory:**

   ```sh
   cd src
   ```
2. **Start the Valkey Server with Custom Configuration:**

   ```sh
   ./valkey-server /path/to/valkey.conf
   ```

## **Configuring Valkey**

Valkey's behavior can be fine-tuned by modifying its configuration file. Below are examples of common configuration options:

1. **Setting a Password:**

   Add the following line to your configuration file (`valkey.conf`) to secure your Valkey server with a password:

   ```sh
   requirepass your_password
   ```
2. **Changing the Port:**

   To specify a custom port for Valkey, add the following line to the configuration file:

   ```sh
   port 6379
   ```

## **Creating a System Service for Valkey**

To ensure Valkey starts automatically and runs as a background service, create a systemd service unit.

1. **Create a Service File:**

   Create a file named `valkey.service` with the following content:

   ```ini
   [Unit]
   Description=Valkey Server
   After=network.target

   [Service]
   Type=simple
   ExecStart=/home/ubuntu/valkey/src/valkey-server /home/ubuntu/valkey/valkey.conf
   Restart=on-failure

   [Install]
   WantedBy=multi-user.target
   ```
2. **Place the Service File:**

   Move the `valkey.service` file to the `/etc/systemd/system/` directory:

   ```sh
   sudo mv valkey.service /etc/systemd/system/
   ```
3. **Reload systemd Configuration:**

   Reload the systemd configuration to recognize the new service:

   ```sh
   sudo systemctl daemon-reload
   ```
4. **Enable and Start the Service:**

   Enable the service to start on boot and start it immediately:

   ```sh
   sudo systemctl enable valkey
   sudo systemctl start valkey
   ```
5. **Check the Service Status:**

   Verify that the Valkey service is running correctly:

   ```sh
   sudo systemctl status valkey
   ```

## **Managing Valkey**

To interact with Valkey, you might need to install the Valkey client. You can install it via pip:

```bash
pip install valkey-client
```

To install a specific version of the Valkey client, use:

```bash
pip install valkey-client==1.0.0
```

Another way to interact with Valkey is using Redis-Insight UI tool:

1. Download Redis-Insight using below [link](https://redis.io/insight/).
2. Install Redis-Insight by clicking on downloaded exe file.
3. Open Redis-Insight tool and login using hostname, port and password.
4. Monitor Valkey logs.

### Starting and Stopping Valkey

Manage the Valkey service using systemctl commands. For example:

```bash
sudo systemctl stop valkey
sudo systemctl start valkey
sudo systemctl status valkey
```

If using Redis alongside Valkey, ensure there are no conflicts. You can stop Redis with:

```bash
sudo systemctl stop redis
```

### Data Migration

To migrate data from Redis to Valkey, copy the `dump.rdb` file from Redis to the Valkey data directory:

```bash
sudo cp /var/lib/redis/dump.rdb /var/lib/valkey/valkey.rdb
```

### Troubleshooting and Debugging

Start Valkey in debug mode for more detailed logging output:

```bash
./valkey-server /home/ubuntu/valkey/valkey.conf --loglevel debug
```

### Additional Commands

- **Check if Valkey server is running on a specific port:**

  ```bash
  sudo lsof -i :6379
  ```
- **Connect to Valkey using the command-line interface (CLI):**

  ```bash
  valkey-cli connect --host localhost --port 6380
  ```
- **Restart Valkey:**

  ```bash
  sudo systemctl restart valkey
  ```

By following these detailed steps, you can successfully build, configure, and run Valkey, ensuring it meets your specific needs and integrates seamlessly with your system.
