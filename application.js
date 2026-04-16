const express = require('express');
const path = require('path');
const dotenv = require("dotenv");
const mysql = require('mysql2');

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

router.get('/', (req, res) => {
    res.statusCode = 200;
    console.log("Request at " + req.url);
    res.sendFile(path.join(`${__dirname}/html/main.html`))
})

router.get('/about-us', (req, res) => {
    res.statusCode = 200;
    console.log("Request at " + req.url);
    res.sendFile(path.join(`${__dirname}/html/about-us.html`))
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