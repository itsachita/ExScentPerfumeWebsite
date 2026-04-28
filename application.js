const express = require('express');
const path = require('path');
const dotenv = require("dotenv");
const mysql = require('mysql2');
const FragellaService = require('./services/fragellaService');

const app = express();
const router = express.Router();

require('dotenv').config();

app.use(express.json());
app.use(express.static('html'));
app.use(express.urlencoded({ extended: true }));
app.use(router)

var connection = mysql.createConnection({
    host        : process.env.MYSQL_HOST,
    user        : process.env.MYSQL_USERNAME,
    password    : process.env.MYSQL_PASSWORD,
    database    : process.env.MYSQL_DATABASE
});

connection.connect(function(err){
    if(err) throw err;
    console.log(`Connected DB: ${process.env.MYSQL_DATABASE}`);
});

const fragellaService = new FragellaService(process.env.FRAGELLA_API_KEY);

router.get('/', (req, res) => {
    res.statusCode = 200;
    console.log("Request at " + req.url);
    res.sendFile(path.join(`${__dirname}/html/main.html`))
})

router.get('/search', (req, res) => {
    res.statusCode = 200;
    console.log("Request at " + req.url);
    res.sendFile(path.join(`${__dirname}/html/search.html`))
})

router.get('/about-us', (req, res) => {
    res.statusCode = 200;
    console.log("Request at " + req.url);
    res.sendFile(path.join(`${__dirname}/html/about-us.html`))
})

router.get('/product', (req, res) => {
    res.sendFile(path.join(__dirname, 'html', 'product.html'));
});

router.get('/api/perfume/:id', (req, res) => {
    const productId = req.params.id;
    const query = `
        SELECT p.*, pf.brand, pf.concentration, pf.gender, pf.rating, pf.votes, pf.perfume_id
        FROM Product p
        JOIN Perfume pf ON p.product_id = pf.product_id
        WHERE p.product_id = ?
    `;
    
    connection.query(query, [productId], (err, results) => {
        if (err) return res.status(500).json({ error: "Database error" });
        if (results.length === 0) return res.status(404).json({ success: false, error: "Not found" });
        
        const product = results[0];
            connection.query('SELECT image_url, is_primary FROM Product_Image WHERE product_id = ? ORDER BY is_primary DESC', [productId], (err, images) => {
                if (err) return res.status(500).json({ error: "Database error" });
                
                connection.query('SELECT * FROM Product_Variant WHERE product_id = ? ORDER BY volume ASC', [productId], (err, variants) => {
                    if (err) return res.status(500).json({ error: "Database error" });
                    
                    res.json({
                        success: true,
                        product: product,
                        images: images,
                        variants: variants
                    });
                });
            });
    });
});

router.get('/api/search', (req, res) => {
    const { q, scopes, sort, concentration, gender, status } = req.query;
    
    let query = `
        SELECT p.product_id, pf.perfume_id, p.product_name, p.product_price, p.product_status, pf.brand, pf.rating, pi.image_url
        FROM Product p
        JOIN Perfume pf ON p.product_id = pf.product_id
        LEFT JOIN Product_Image pi ON p.product_id = pi.product_id AND pi.is_primary = TRUE
        WHERE 1=1
    `;
    const params = [];

    if (status) {
        query += ` AND p.product_status = ?`;
        params.push(status);
    }
    
    if (q) {
        let scopeConditions = [];
        const searchScopes = scopes ? scopes.split(',') : ['products'];
        
        if (searchScopes.includes('brands')) {
            scopeConditions.push(`pf.brand LIKE ?`);
            params.push(`%${q}%`);
        }
        if (searchScopes.includes('products')) {
            scopeConditions.push(`p.product_name LIKE ?`);
            params.push(`%${q}%`);
        }
        if (searchScopes.includes('notes')) {
            scopeConditions.push(`p.product_detail LIKE ?`);
            params.push(`%${q}%`);
        }
        
        if (scopeConditions.length > 0) {
            query += ` AND (${scopeConditions.join(' OR ')})`;
        }
    }
    
    if (concentration && concentration !== 'Filter By' && concentration !== '') {
        let conc = concentration;
        if (conc === 'EDT') conc = 'EAU DE TOILETTE';
        if (conc === 'EDP') conc = 'EAU DE PARFUM';
        if (conc === 'Parfum') conc = 'PARFUM';
        query += ` AND pf.concentration = ?`;
        params.push(conc);
    }
    
    if (gender && gender !== 'Filter By' && gender !== '') {
        query += ` AND pf.gender = ?`;
        params.push(gender);
    }
    
    if (sort === 'Price') {
        query += ` ORDER BY p.product_price ASC`;
    } else if (sort === 'A-Z') {
        query += ` ORDER BY p.product_name ASC`;
    } else if (sort === 'Rating') {
        query += ` ORDER BY pf.rating DESC`;
    } else {
        query += ` ORDER BY p.product_name ASC`;
    }
    
    connection.query(query, params, (err, results) => {
        if (err) {
            console.error("Search API error:", err);
            return res.status(500).json({ error: "Database error" });
        }
        res.json(results);
    });
});

router.post('/admin/sync-perfume', async (req, res) => {
    const { product_id } = req.body;

    if (!product_id) {
        return res.status(400).json({ error: 'Product ID is required' });
    }

    connection.query('SELECT product_name FROM Product WHERE product_id = ?', [product_id], async (err, results) => {
        if (err || results.length === 0) {
            return res.status(404).json({ error: 'Product not found' });
        }

        const productName = results[0].product_name;
        const fragData = await fragellaService.searchFragrance(productName);

        if (!fragData) {
            return res.status(404).json({ error: 'No data found on Fragella for this perfume' });
        }

        const rating = fragData.rating || 0;
        const brand = fragData.Brand || 'Unknown';
        
        let gender = 'Unisex';
        if (fragData.Gender === 'men') gender = 'Masculine';
        else if (fragData.Gender === 'women') gender = 'Feminine';

        const imageUrl = fragData['Image URL'];
        const detail = fragData['General Notes'] ? fragData['General Notes'].join(', ') : '';
        
        let concentration = 'PARFUM';
        const oilType = fragData.OilType || '';
        if (oilType.toLowerCase().includes('toilette')) concentration = 'EAU DE TOILETTE';
        else if (oilType.toLowerCase().includes('parfum')) concentration = 'EAU DE PARFUM';
        else if (oilType.toLowerCase().includes('cologne')) concentration = 'EAU DE COLOGNE';

        const updatePerfume = 'UPDATE Perfume SET rating = ?, brand = ?, concentration = ?, gender = ? WHERE product_id = ?';
        const updateProduct = 'UPDATE Product SET product_detail = ? WHERE product_id = ?';
        const updateImage = 'UPDATE Product_Image SET image_url = ? WHERE product_id = ? AND is_primary = TRUE';

        connection.query(updatePerfume, [rating, brand, concentration, gender, product_id], (err) => {
            if (err) console.error('Sync Perfume error:', err);
        });

        connection.query(updateProduct, [detail, product_id], (err) => {
            if (err) console.error('Sync Product error:', err);
        });

        if (imageUrl) {
            connection.query(updateImage, [imageUrl, product_id], (err, results) => {
                if (err) console.error('Sync Image error:', err);
                if (results && results.affectedRows === 0) {
                    connection.query('INSERT INTO Product_Image (image_url, is_primary, product_id) VALUES (?, TRUE, ?)', [imageUrl, product_id]);
                }
            });
        }

        res.json({ success: true, message: 'Synced with Fragella!', data: { brand, rating, gender, concentration } });
    });
});

router.get('/admin/search-fragella', async (req, res) => {
    const { name } = req.query;
    if (!name) return res.status(400).json({ error: 'Name is required' });

    try {
        const fragData = await fragellaService.searchFragrance(name);
        if (fragData) {
            // Normalize field names for the frontend
            res.json({
                success: true,
                data: {
                    brand: fragData.Brand || fragData.brand || '',
                    rating: fragData.Rating || fragData.rating || 0,
                    votes: fragData.Votes || fragData.votes || 0,
                    concentration: fragData.OilType || fragData.concentration || '',
                    gender: fragData.Gender || fragData.gender || '',
                    notes: Array.isArray(fragData['General Notes']) ? fragData['General Notes'].join(', ') : (fragData.notes || fragData.description || ''),
                    imageUrl: fragData.ImageURL || fragData.imageUrl || null
                }
            });
        } else {
            res.status(404).json({ success: false, error: 'No fragrance found' });
        }
    } catch (err) {
        console.error('Fragella search error:', err);
        res.status(500).json({ success: false, error: 'Search failed' });
    }
});

router.patch('/api/perfume/:id/status', (req, res) => {
    const productId = req.params.id;
    const { status } = req.body;
    
    connection.query('UPDATE Product SET product_status = ? WHERE product_id = ?', [status, productId], (err, results) => {
        if (err) return res.status(500).json({ error: "Database error" });
        res.json({ success: true });
    });
});

router.delete('/api/perfume/:id', (req, res) => {
    const productId = req.params.id;
    
    // Deleting from Product will cascade to Perfume, Product_Image due to foreign key constraints
    connection.query('DELETE FROM Product WHERE product_id = ?', [productId], (err, results) => {
        if (err) {
            console.error("Delete API error:", err);
            return res.status(500).json({ error: "Database error" });
        }
        if (results.affectedRows === 0) {
            return res.status(404).json({ error: "Product not found" });
        }
        res.json({ success: true, message: "Product deleted successfully" });
    });
});

router.post('/api/perfume', (req, res) => {
    const { product_id, product_name, product_price, product_detail, product_status, brand, rating, votes, concentration, gender, images, variants, isEdit } = req.body;
    const admin_id = '000035'; 

    const finalProductId = product_id || Math.floor(1000000000000 + Math.random() * 9000000000000).toString();
    const displayPrice = (variants && variants.length > 0) ? variants[0].price : product_price;

    const saveProduct = () => {
        if (isEdit) {
            const updateQuery = 'UPDATE Product SET product_name = ?, product_price = ?, product_detail = ?, product_status = ? WHERE product_id = ?';
            connection.query(updateQuery, [product_name, displayPrice, product_detail, product_status, finalProductId], (err) => {
                if (err) return res.status(500).json({ error: "Update Product error: " + err.message });
                updatePerfume();
            });
        } else {
            const insertQuery = 'INSERT INTO Product (product_id, product_name, product_price, product_detail, product_status, admin_id) VALUES (?, ?, ?, ?, ?, ?)';
            connection.query(insertQuery, [finalProductId, product_name, displayPrice, product_detail, product_status, admin_id], (err) => {
                if (err) return res.status(500).json({ error: "Insert Product error: " + err.message });
                updatePerfume();
            });
        }
    };

    const updatePerfume = () => {
        const perfume_id = (brand || 'UN').substring(0, 2).toUpperCase() + '-' + Math.floor(10000 + Math.random() * 90000);
        if (isEdit) {
            const updatePerfQuery = 'UPDATE Perfume SET concentration = ?, brand = ?, gender = ?, rating = ?, votes = ? WHERE product_id = ?';
            connection.query(updatePerfQuery, [concentration, brand, gender, rating || 0, votes || 0, finalProductId], (err) => {
                if (err) return res.status(500).json({ error: "Update Perfume error: " + err.message });
                updateImages();
            });
        } else {
            const insertPerfQuery = 'INSERT INTO Perfume (perfume_id, concentration, rating, votes, brand, gender, product_id) VALUES (?, ?, ?, ?, ?, ?, ?)';
            connection.query(insertPerfQuery, [perfume_id, concentration, rating || 0, votes || 0, brand, gender, finalProductId], (err) => {
                if (err) return res.status(500).json({ error: "Insert Perfume error: " + err.message });
                updateImages();
            });
        }
    };

    const updateImages = () => {
        connection.query('DELETE FROM Product_Image WHERE product_id = ?', [finalProductId], (err) => {
            if (err) return res.status(500).json({ error: "Image cleanup error" });
            
            if (images && images.length > 0) {
                const values = images.map((url, index) => [url, index === 0, finalProductId]);
                connection.query('INSERT INTO Product_Image (image_url, is_primary, product_id) VALUES ?', [values], (err) => {
                    updateVariants();
                });
            } else {
                updateVariants();
            }
        });
    };

    const updateVariants = () => {
        connection.query('DELETE FROM Product_Variant WHERE product_id = ?', [finalProductId], (err) => {
            if (err) return res.status(500).json({ error: "Variant cleanup error" });
            
            if (variants && variants.length > 0) {
                const values = variants.map(v => [finalProductId, v.volume, v.price, v.stock]);
                connection.query('INSERT INTO Product_Variant (product_id, volume, price, stock) VALUES ?', [values], (err) => {
                    if (err) return res.status(500).json({ error: "Insert Variants error: " + err.message });
                    res.json({ success: true, product_id: finalProductId });
                });
            } else {
                res.json({ success: true, product_id: finalProductId });
            }
        });
    };

    saveProduct();
});

router.put('/api/perfume', (req, res) => {
    const productId = req.query.id;
    if (!productId) return res.status(400).json({ error: "Product ID is required in query parameter" });

    const { product_name, product_price, product_detail, product_status, brand, rating, votes, concentration, gender, images, variants } = req.body;

    const updateProduct = () => {
        const query = 'UPDATE Product SET product_name = ?, product_price = ?, product_detail = ?, product_status = ? WHERE product_id = ?';
        connection.query(query, [product_name, product_price, product_detail, product_status, productId], (err) => {
            if (err) return res.status(500).json({ error: "Update Product error: " + err.message });
            updatePerfume();
        });
    };

    const updatePerfume = () => {
        const query = 'UPDATE Perfume SET concentration = ?, brand = ?, gender = ?, rating = ?, votes = ? WHERE product_id = ?';
        connection.query(query, [concentration, brand, gender, rating || 0, votes || 0, productId], (err) => {
            if (err) return res.status(500).json({ error: "Update Perfume error: " + err.message });
            
            // Only update images/variants if they are provided in the request body
            if (images !== undefined || variants !== undefined) {
                updateImages();
            } else {
                res.json({ success: true, message: "Product updated successfully" });
            }
        });
    };

    const updateImages = () => {
        if (images === undefined) return updateVariants();
        connection.query('DELETE FROM Product_Image WHERE product_id = ?', [productId], (err) => {
            if (err) return res.status(500).json({ error: "Image cleanup error" });
            if (images.length > 0) {
                const values = images.map((url, index) => [url, index === 0, productId]);
                connection.query('INSERT INTO Product_Image (image_url, is_primary, product_id) VALUES ?', [values], (err) => {
                    updateVariants();
                });
            } else {
                updateVariants();
            }
        });
    };

    const updateVariants = () => {
        if (variants === undefined) return res.json({ success: true, message: "Product updated successfully" });
        connection.query('DELETE FROM Product_Variant WHERE product_id = ?', [productId], (err) => {
            if (err) return res.status(500).json({ error: "Variant cleanup error" });
            if (variants.length > 0) {
                const values = variants.map(v => [productId, v.volume, v.price, v.stock]);
                connection.query('INSERT INTO Product_Variant (product_id, volume, price, stock) VALUES ?', [values], (err) => {
                    if (err) return res.status(500).json({ error: "Insert Variants error: " + err.message });
                    res.json({ success: true, message: "Product updated successfully" });
                });
            } else {
                res.json({ success: true, message: "Product updated successfully" });
            }
        });
    };

    updateProduct();
});

router.get('/admin_login', (req, res) => {
    res.statusCode = 200;
    console.log("Request at " + req.url);
    res.sendFile(path.join(`${__dirname}/html/login.html`))
})

router.post('/admin_login', (req, res) => {
    const { username, password } = req.body;
    
    let admins = [];
    try {
        admins = JSON.parse(process.env.ADMIN_CREDENTIALS || '[]');
    } catch (e) {
        console.error("Failed to parse ADMIN_CREDENTIALS from .env:", e);
        return res.status(500).send("Server configuration error");
    }

    const match = admins.find(a => a.username === username && a.password === password);

    if (match) {
        console.log("Login successful for user:", username);
        res.redirect('/prod-admin');
    } else {
        console.log("Login failed for user:", username);
        res.status(401).send(`
            <script>
                alert('Invalid username or password');
                window.location.href = '/admin_login';
            </script>
        `);
    }
})

router.get('/prod-admin', (req, res) => {
    res.statusCode = 200;
    console.log("Request at " + req.url);
    res.sendFile(path.join(`${__dirname}/html/prod-admin.html`))
})

router.get('/prod-config', (req, res) => {
    res.statusCode = 200;
    console.log("Request at " + req.url);
    res.sendFile(path.join(`${__dirname}/html/prod-config.html`))
})

router.get('/prod-config-delete', (req, res) => {
    res.statusCode = 200;
    console.log("Request at " + req.url);
    res.sendFile(path.join(`${__dirname}/html/prod-admin-delete.html`))
})

router.use((req, res, next) => {
    console.log("Request at " + req.url);
    console.log("404: Invalid accessed");
    res.sendFile(path.join(`${__dirname}/html/error.html`))
    res.status(404);
})

app.listen(process.env.PORT, function () {
    console.log(`Server listening on port: ` + process.env.PORT);
})