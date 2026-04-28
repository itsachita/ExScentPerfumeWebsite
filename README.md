# ExScent Perfume Website 🌟

A premium, full-stack web application for an exclusive perfume boutique. This project features a dynamic customer-facing storefront and a comprehensive administrative dashboard for product management.

Built as part of **ITCS223: Introduction to Web Development**, Faculty of Information and Communication Technology, Mahidol University.

---

## ✨ Features

### 🛍️ Customer Storefront
- **Dynamic Homepage**: High-performance display of products with "More to Explore" sections.
- **Smart Recommendations**: "You Might Be Interested In" section showing top-rated fragrances.
- **Advanced Filtering**: Sort and filter products by brand, concentration (EDT/EDP/Parfum), gender, and price.
- **Responsive Design**: Elegant, mobile-first UI with smooth transitions and premium aesthetics.

### 🛡️ Admin Dashboard
- **Secure Authentication**: Environment-based login for administrators.
- **Product Management**: Full CRUD (Create, Read, Update, Delete) operations for perfumes.
- **Real-time Configuration**: Update product details, pricing, and stock status instantly.
- **Image Management**: Support for multiple product images with primary image selection.

---

## 🛠️ Technology Stack

- **Frontend**: HTML5, Vanilla CSS3 (Custom Design System), JavaScript (ES6+)
- **Backend**: Node.js, Express.js
- **Database**: MySQL
- **Environment**: Dotenv for secure configuration
- **Dev Tools**: Nodemon for hot reloading

---

## 🚀 Getting Started

### Prerequisites

- **Node.js** (v18.0.0 or higher)
- **npm** (v9.0.0 or higher)
- **MySQL Server** (v8.0 or higher)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/itsachita/ExScentPerfumeWebsite.git
   cd ExScentPerfumeWebsite
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Database Setup**
   - Create a new MySQL database named `ExScent`.
   - Import the schema and seed data from `database/ExScent.sql`.
   ```bash
   mysql -u your_user -p ExScent < database/ExScent.sql
   ```

4. **Environment Configuration**
   Create a `.env` file in the root directory:
   ```env
   PORT=3000
   MYSQL_HOST=localhost
   MYSQL_USERNAME=your_username
   MYSQL_PASSWORD=your_password
   MYSQL_DATABASE=ExScent
   
   # Admin Credentials (JSON format)
   ADMIN_CREDENTIALS=[{"username":"admin","password":"password123"}]
   
   # Optional: Fragella API Key for external sync
   FRAGELLA_API_KEY=your_api_key
   ```

---

## 🏃‍♂️ Running the Application

Start the development server with auto-reload:
```bash
npm start
```

The application will be available at `http://localhost:3000`.

---

## 📂 Project Structure

```text
ExScentPerfumeWebsite/
├── application.js         # Express server & API routes
├── database/
│   └── ExScent.sql        # Database schema and seed data
├── html/                  # Frontend assets
│   ├── css/               # Custom CSS design systems
│   ├── images/            # Product and UI assets
│   ├── main.html          # Storefront entry
│   ├── login.html         # Admin login portal
│   ├── prod-admin.html    # Admin dashboard
│   └── product.html       # Product detail page
├── .env                   # Environment variables (Private)
└── package.json           # Dependencies and scripts
```

---
