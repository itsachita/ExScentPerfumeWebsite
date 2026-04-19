# ExScent Perfume Website

This project is part of ITCS223: Introduction to Web Development, Faculty of Information and Communication Technology, Mahidol University.

## Prerequisites

Before setting up this project, ensure you have the following installed on your system:

- **Node.js** (v14 or higher) - [Download](https://nodejs.org/)
- **npm** (v6 or higher) - Comes bundled with Node.js

To verify installations, run:
```bash
node --version
npm --version
```

## Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/itsachita/ExScentPerfumeWebsite.git
   cd ExScentPerfumeWebsite
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```
   This will install all required npm packages listed in `package.json`:
   - express (web framework)
   - mysql2 (MySQL database driver)
   - dotenv (environment variable management)
   - nodemon (development auto-reload)

3. **Configure environment variables:**
   Create a `.env` file in the root directory with the following variables:
   ```
   DB_HOST=your_database_host
   DB_USER=your_database_user
   DB_PASSWORD=your_database_password
   DB_NAME=your_database_name
   PORT=3000
   ```
   Replace the values with your actual database credentials and desired port.

## Running the Project

Start the development server:
```bash
npm start
```

This will run the application using nodemon, which automatically restarts the server when files change. The server will be available at `http://localhost:3000` (or the port specified in your `.env` file).

## Project Structure

```
ExScentPerfumeWebsite/
├── application.js         # Main application entry point
├── package.json           # Project dependencies and scripts
├── README.md              # This file
├── html/
│   ├── main.html          # Main page
│   ├── error.html         # Error page
│   ├── style.css          # Stylesheet
│   └── images/            # Image assets
│       ├── header/        # Header images
│       ├── footer/        # Footer images
│       ├── products/      # Product images
│       └── product-ad/    # Product advertisement images
```

## Notes

- The `.env` file, `node_modules/`, and `package-lock.json` are not included in the repository. These will be generated locally after running `npm install`.
- Always keep your `.env` file secure and never commit it to version control.
- For production deployment, ensure you update your database credentials and environment variables appropriately.


## Remarks

- This README.md file is wrote via AI to ensure that no detail is missing out.
