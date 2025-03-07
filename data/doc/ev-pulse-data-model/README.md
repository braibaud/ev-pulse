Here's a `README.md` file for the Docusaurus documentation project, including instructions on how to build and serve the static website using `npm`:

```markdown
# EV Pulse Documentation

Welcome to the EV Pulse documentation site! This project uses Docusaurus to generate static websites for documentation. Below are the instructions to set up, build, and serve the documentation locally.

## Prerequisites

- Node.js (version 18)
- npm (comes with Node.js)

## Getting Started

### Installation

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/braibaud/ev-pulse-docs.git
   cd data
   cd doc
   cd ev-pulse-docs
   ```

2. **Install Dependencies**:
   ```bash
   npm install
   ```

### Running Locally

To start the development server and see the documentation in action:

```bash
npm start
```

This command starts a local development server and opens the documentation site in your default web browser. Most changes are reflected live without having to restart the server.

### Building the Static Site

To build the static website for production:

```bash
npm run build
```

This command generates the static files in the `build` directory. You can serve these files using any static file server.

### Serving the Static Site

To serve the static site locally after building:

```bash
npm run serve
```

This command serves the static files from the `build` directory using a simple static file server.

## Contributing

We welcome contributions to improve the documentation! Please follow these steps:

1. **Fork the Repository**: Create your own copy of the repository.
2. **Create a Branch**: Make your changes in a new branch.
3. **Commit Your Changes**: Commit your changes with a descriptive message.
4. **Push to Your Fork**: Push your branch to your forked repository.
5. **Submit a Pull Request**: Open a pull request to the main repository.

## Directory Structure

- `blog`: Contains the Blog posts in Markdown format.
- `docs`: Contains the documentation files in Markdown format.
- `src`: Contains custom React components and styles.
- `static`: Contains static assets like images.
- `docusaurus.config.js`: Configuration file for Docusaurus.
- `sidebars.js`: Configuration for the sidebar navigation.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contact

If you have any questions or need further assistance, please feel free to [contact us](contact.md).

Happy documenting!

*The EV Pulse Team*
